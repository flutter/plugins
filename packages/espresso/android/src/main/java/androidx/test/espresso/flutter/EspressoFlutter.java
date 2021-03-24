// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.flutter.common.Constants.DEFAULT_INTERACTION_TIMEOUT;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isFlutterView;
import static com.google.common.base.Preconditions.checkNotNull;
import static org.hamcrest.Matchers.any;

import android.util.Log;
import android.view.View;
import androidx.test.espresso.UiController;
import androidx.test.espresso.ViewAction;
import androidx.test.espresso.flutter.action.FlutterViewAction;
import androidx.test.espresso.flutter.action.WidgetInfoFetcher;
import androidx.test.espresso.flutter.api.FlutterAction;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetAssertion;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.assertion.FlutterViewAssertion;
import androidx.test.espresso.flutter.common.Duration;
import androidx.test.espresso.flutter.exception.NoMatchingWidgetException;
import androidx.test.espresso.flutter.internal.idgenerator.IdGenerator;
import androidx.test.espresso.flutter.internal.idgenerator.IdGenerators;
import androidx.test.espresso.flutter.model.WidgetInfo;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import javax.annotation.Nonnull;
import okhttp3.OkHttpClient;
import org.hamcrest.Matcher;

/** Entry point to the Espresso testing APIs on Flutter. */
public final class EspressoFlutter {

  private static final String TAG = EspressoFlutter.class.getSimpleName();

  private static final OkHttpClient okHttpClient;
  private static final IdGenerator<Integer> idGenerator;
  private static final ExecutorService taskExecutor;

  static {
    okHttpClient = new OkHttpClient();
    idGenerator = IdGenerators.newIntegerIdGenerator();
    taskExecutor = Executors.newCachedThreadPool();
  }

  /**
   * Creates a {@link WidgetInteraction} for the Flutter widget matched by the given {@code
   * widgetMatcher}, which is an entry point to perform actions or asserts.
   *
   * @param widgetMatcher the matcher used to uniquely match a Flutter widget on the screen.
   */
  public static WidgetInteraction onFlutterWidget(@Nonnull WidgetMatcher widgetMatcher) {
    return new WidgetInteraction(isFlutterView(), widgetMatcher);
  }

  /**
   * Provides fluent testing APIs for test authors to perform actions or asserts on Flutter widgets,
   * similar to {@code ViewInteraction} and {@code WebInteraction}.
   */
  public static final class WidgetInteraction {

    /**
     * Adds a little delay to the interaction timeout so that we make sure not to time out before
     * the action or assert does.
     */
    private static final Duration INTERACTION_TIMEOUT_DELAY = new Duration(1, TimeUnit.SECONDS);

    private final Matcher<View> flutterViewMatcher;
    private final WidgetMatcher widgetMatcher;
    private final Duration timeout;

    private WidgetInteraction(Matcher<View> flutterViewMatcher, WidgetMatcher widgetMatcher) {
      this(
          flutterViewMatcher,
          widgetMatcher,
          DEFAULT_INTERACTION_TIMEOUT.plus(INTERACTION_TIMEOUT_DELAY));
    }

    private WidgetInteraction(
        Matcher<View> flutterViewMatcher, WidgetMatcher widgetMatcher, Duration timeout) {
      this.flutterViewMatcher = checkNotNull(flutterViewMatcher);
      this.widgetMatcher = checkNotNull(widgetMatcher);
      this.timeout = checkNotNull(timeout);
    }

    /**
     * Executes the given action(s) with synchronization guarantees: Espresso ensures Flutter's in
     * an idle state before interacting with the Flutter UI.
     *
     * <p>If more than one action is provided, actions are executed in the order provided.
     *
     * @param widgetActions one or more actions that shall be performed. Cannot be {@code null}.
     * @return this interaction for further perform/verification calls.
     */
    public WidgetInteraction perform(@Nonnull final WidgetAction... widgetActions) {
      checkNotNull(widgetActions);
      for (WidgetAction widgetAction : widgetActions) {
        // If any error occurred, an unchecked exception will be thrown that stops execution of
        // following actions.
        performInternal(widgetAction);
      }
      return this;
    }

    /**
     * Evaluates the given widget assertion.
     *
     * @param assertion a widget assertion that shall be made on the matched Flutter widget. Cannot
     *     be {@code null}.
     */
    public WidgetInteraction check(@Nonnull WidgetAssertion assertion) {
      checkNotNull(
          assertion,
          "Assertion cannot be null. You must specify an assertion on the matched Flutter widget.");
      WidgetInfo widgetInfo = performInternal(new WidgetInfoFetcher());
      if (widgetInfo == null) {
        Log.w(TAG, String.format("Widget info that matches %s is null.", widgetMatcher));
        throw new NoMatchingWidgetException(
            String.format("Widget info that matches %s is null.", widgetMatcher));
      }
      FlutterViewAssertion flutterViewAssertion = new FlutterViewAssertion(assertion, widgetInfo);
      onView(flutterViewMatcher).check(flutterViewAssertion);
      return this;
    }

    @SuppressWarnings("unchecked")
    private <T> T performInternal(FlutterAction<T> flutterAction) {
      checkNotNull(
          flutterAction,
          "The action cannot be null. You must specify an action to perform on the matched"
              + " Flutter widget.");
      FlutterViewAction<T> flutterViewAction =
          new FlutterViewAction(
              widgetMatcher, flutterAction, okHttpClient, idGenerator, taskExecutor);
      onView(flutterViewMatcher).perform(flutterViewAction);
      T result;
      try {
        if (timeout != null && timeout.getQuantity() > 0) {
          result = flutterViewAction.waitUntilCompleted(timeout.getQuantity(), timeout.getUnit());
        } else {
          result = flutterViewAction.waitUntilCompleted();
        }
        return result;
      } catch (ExecutionException e) {
        propagateException(e.getCause());
      } catch (InterruptedException | TimeoutException | RuntimeException e) {
        propagateException(e);
      }
      return null;
    }

    /**
     * Propagates exception through #onView so that it get a chance to be handled by the registered
     * {@code FailureHandler}.
     */
    private void propagateException(Throwable t) {
      onView(flutterViewMatcher).perform(new ExceptionPropagator(t));
    }

    /**
     * An exception wrapper that propagates an exception through {@code #onView}, so that it can be
     * handled by the registered {@code FailureHandler} for the underlying {@code ViewInteraction}.
     */
    static class ExceptionPropagator implements ViewAction {
      private final RuntimeException exception;

      public ExceptionPropagator(RuntimeException exception) {
        this.exception = checkNotNull(exception);
      }

      public ExceptionPropagator(Throwable t) {
        this(new RuntimeException(t));
      }

      @Override
      public String getDescription() {
        return "Propagate: " + exception;
      }

      @Override
      public void perform(UiController uiController, View view) {
        throw exception;
      }

      @SuppressWarnings("unchecked")
      @Override
      public Matcher<View> getConstraints() {
        return any(View.class);
      }
    }
  }
}
