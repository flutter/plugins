// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import static androidx.test.espresso.flutter.action.ActionUtil.loopUntilCompletion;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isFlutterView;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Preconditions.checkState;
import static com.google.common.util.concurrent.Futures.transformAsync;
import static com.google.common.util.concurrent.MoreExecutors.directExecutor;

import android.os.Looper;
import android.view.View;
import androidx.test.annotation.Beta;
import androidx.test.espresso.IdlingRegistry;
import androidx.test.espresso.IdlingResource;
import androidx.test.espresso.UiController;
import androidx.test.espresso.ViewAction;
import androidx.test.espresso.flutter.api.FlutterAction;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.internal.idgenerator.IdGenerator;
import androidx.test.espresso.flutter.internal.jsonrpc.JsonRpcClient;
import androidx.test.espresso.flutter.internal.protocol.impl.DartVmService;
import androidx.test.espresso.flutter.internal.protocol.impl.DartVmServiceUtil;
import androidx.test.espresso.flutter.internal.protocol.impl.FlutterProtocolException;
import com.google.common.annotations.VisibleForTesting;
import com.google.common.util.concurrent.AsyncFunction;
import com.google.common.util.concurrent.JdkFutureAdapters;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.SettableFuture;
import io.flutter.embedding.android.FlutterView;
import io.flutter.view.FlutterNativeView;
import java.net.URI;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import okhttp3.OkHttpClient;
import org.hamcrest.Matcher;

/**
 * A {@code ViewAction} which performs an action on the given {@code FlutterView}.
 *
 * <p>This class acts as a bridge to perform {@code WidgetAction} on a Flutter widget on the given
 * {@code FlutterView}.
 */
@Beta
public final class FlutterViewAction<T> implements ViewAction {

  private static final String FLUTTER_IDLE_TASK_NAME = "flutterIdlingResource";

  private final SettableFuture<T> resultFuture = SettableFuture.create();
  private final WidgetMatcher widgetMatcher;
  private final FlutterAction<T> widgetAction;
  private final OkHttpClient webSocketClient;
  private final IdGenerator<Integer> messageIdGenerator;
  private final ExecutorService taskExecutor;

  /**
   * Constructs an instance based on the given params.
   *
   * @param widgetMatcher the matcher that uniquely matches a widget on the {@code FlutterView}.
   *     Could be {@code null} if this is a universal action that doesn't apply to any specific
   *     widget.
   * @param widgetAction the action to be performed on the matched Flutter widget.
   * @param webSocketClient the WebSocket client that shall be used in the {@code
   *     FlutterTestingProtocol}.
   * @param messageIdGenerator an ID generator that shall be used in the {@code
   *     FlutterTestingProtocol}.
   * @param taskExecutor the task executor that shall be used in the {@code WidgetAction}.
   */
  public FlutterViewAction(
      WidgetMatcher widgetMatcher,
      FlutterAction<T> widgetAction,
      OkHttpClient webSocketClient,
      IdGenerator<Integer> messageIdGenerator,
      ExecutorService taskExecutor) {
    this.widgetMatcher = widgetMatcher;
    this.widgetAction = checkNotNull(widgetAction);
    this.webSocketClient = checkNotNull(webSocketClient);
    this.messageIdGenerator = checkNotNull(messageIdGenerator);
    this.taskExecutor = checkNotNull(taskExecutor);
  }

  @Override
  public Matcher<View> getConstraints() {
    return isFlutterView();
  }

  @Override
  public String getDescription() {
    return String.format(
        "Perform a %s action on the Flutter widget matched %s.", widgetAction, widgetMatcher);
  }

  @Override
  public void perform(UiController uiController, View flutterView) {
    // There could be a gap between when the Flutter view is available in the view hierarchy and the
    // engine & Dart isolates are actually up and running. Check whether the first frame has been
    // rendered before proceeding in an unblocking way.
    loopUntilFlutterViewRendered(flutterView, uiController);
    // The url {@code FlutterNativeView} returns is the http url that the Dart VM Observatory http
    // server serves at. Need to convert to the one that the WebSocket uses.
    URI dartVmServiceProtocolUrl =
        DartVmServiceUtil.getServiceProtocolUri(FlutterNativeView.getObservatoryUri());
    String isolateId = DartVmServiceUtil.getDartIsolateId(flutterView);
    final FlutterTestingProtocol flutterTestingProtocol =
        new DartVmService(
            isolateId,
            new JsonRpcClient(webSocketClient, dartVmServiceProtocolUrl),
            messageIdGenerator,
            taskExecutor);

    try {
      // First checks the testing protocol is ready for use and then waits until the Flutter app is
      // idle before executing the action.
      ListenableFuture<Void> testingProtocolReadyFuture =
          JdkFutureAdapters.listenInPoolThread(flutterTestingProtocol.connect());
      AsyncFunction<Void, Void> flutterIdleFunc =
          new AsyncFunction<Void, Void>() {
            public ListenableFuture<Void> apply(Void readyResult) {
              return JdkFutureAdapters.listenInPoolThread(flutterTestingProtocol.waitUntilIdle());
            }
          };
      ListenableFuture<Void> flutterIdleFuture =
          transformAsync(testingProtocolReadyFuture, flutterIdleFunc, taskExecutor);
      loopUntilCompletion(FLUTTER_IDLE_TASK_NAME, uiController, flutterIdleFuture, taskExecutor);
      perform(flutterView, flutterTestingProtocol, uiController);
    } catch (ExecutionException ee) {
      resultFuture.setException(ee.getCause());
    } catch (InterruptedException ie) {
      resultFuture.setException(ie);
    }
  }

  @VisibleForTesting
  void perform(
      View flutterView, FlutterTestingProtocol flutterTestingProtocol, UiController uiController) {
    final ListenableFuture<T> actionResultFuture =
        JdkFutureAdapters.listenInPoolThread(
            widgetAction.perform(widgetMatcher, flutterView, flutterTestingProtocol, uiController));
    actionResultFuture.addListener(
        new Runnable() {
          @Override
          public void run() {
            try {
              resultFuture.set(actionResultFuture.get());
            } catch (ExecutionException | InterruptedException e) {
              resultFuture.setException(e);
            }
          }
        },
        directExecutor());
  }

  /** Blocks until this action has completed execution. */
  public T waitUntilCompleted() throws ExecutionException, InterruptedException {
    checkState(Looper.myLooper() != Looper.getMainLooper(), "On main thread!");
    return resultFuture.get();
  }

  /** Blocks until this action has completed execution with a configurable timeout. */
  public T waitUntilCompleted(long timeout, TimeUnit unit)
      throws InterruptedException, ExecutionException, TimeoutException {
    checkState(Looper.myLooper() != Looper.getMainLooper(), "On main thread!");
    return resultFuture.get(timeout, unit);
  }

  private static void loopUntilFlutterViewRendered(View flutterView, UiController uiController) {
    FlutterViewRenderedIdlingResource idlingResource =
        new FlutterViewRenderedIdlingResource(flutterView);
    try {
      IdlingRegistry.getInstance().register(idlingResource);
      uiController.loopMainThreadUntilIdle();
    } finally {
      IdlingRegistry.getInstance().unregister(idlingResource);
    }
  }

  /**
   * An {@link IdlingResource} that checks whether the Flutter view's first frame has been rendered
   * in an unblocking way.
   */
  static final class FlutterViewRenderedIdlingResource implements IdlingResource {

    private final View flutterView;
    // Written from main thread, read from any thread.
    private volatile ResourceCallback resourceCallback;

    FlutterViewRenderedIdlingResource(View flutterView) {
      this.flutterView = checkNotNull(flutterView);
    }

    @Override
    public String getName() {
      return FlutterViewRenderedIdlingResource.class.getSimpleName();
    }

    @Override
    public boolean isIdleNow() {
      boolean isIdle = false;
      if (flutterView instanceof FlutterView) {
        isIdle = ((FlutterView) flutterView).hasRenderedFirstFrame();
      } else if (flutterView instanceof io.flutter.view.FlutterView) {
        isIdle = ((io.flutter.view.FlutterView) flutterView).hasRenderedFirstFrame();
      } else {
        throw new FlutterProtocolException(
            String.format("This is not a Flutter View instance [id: %d].", flutterView.getId()));
      }
      if (isIdle) {
        resourceCallback.onTransitionToIdle();
      }
      return isIdle;
    }

    @Override
    public void registerIdleTransitionCallback(ResourceCallback callback) {
      resourceCallback = callback;
    }
  }
}
