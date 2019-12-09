// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import static androidx.test.espresso.flutter.action.ActionUtil.loopUntilCompletion;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.util.concurrent.Futures.allAsList;
import static com.google.common.util.concurrent.Futures.immediateFailedFuture;
import static com.google.common.util.concurrent.Futures.immediateFuture;

import android.graphics.Rect;
import android.util.Log;
import android.view.InputDevice;
import android.view.MotionEvent;
import android.view.View;
import androidx.test.espresso.UiController;
import androidx.test.espresso.ViewAction;
import androidx.test.espresso.action.GeneralClickAction;
import androidx.test.espresso.action.Press;
import androidx.test.espresso.action.Tap;
import androidx.test.espresso.action.TypeTextAction;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.SyntheticAction;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import com.google.common.util.concurrent.JdkFutureAdapters;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.gson.annotations.Expose;
import java.util.Locale;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/** An action that types text on a Flutter widget. */
public final class FlutterTypeTextAction implements WidgetAction {

  private static final String TAG = FlutterTypeTextAction.class.getSimpleName();

  private static final String GET_LOCAL_RECT_TASK_NAME = "FlutterTypeTextAction#getLocalRect";
  private static final String FLUTTER_IDLE_TASK_NAME = "FlutterTypeTextAction#flutterIsIdle";

  private final String stringToBeTyped;
  private final boolean tapToFocus;
  private final ExecutorService executor;

  /**
   * Constructs with the given input string. If the string is empty it results in no-op (nothing is
   * typed). By default this action sends a tap event to the center of the widget to attain focus
   * before typing.
   *
   * @param stringToBeTyped String To be typed in.
   */
  FlutterTypeTextAction(@Nonnull String stringToBeTyped, @Nonnull ExecutorService executor) {
    this(stringToBeTyped, executor, true);
  }

  /**
   * Constructs with the given input string. If the string is empty it results in no-op (nothing is
   * typed). By default this action sends a tap event to the center of the widget to attain focus
   * before typing.
   *
   * @param stringToBeTyped String To be typed in.
   * @param tapToFocus indicates whether a tap should be sent to the underlying widget before
   *     typing.
   */
  FlutterTypeTextAction(
      @Nonnull String stringToBeTyped, @Nonnull ExecutorService executor, boolean tapToFocus) {
    this.stringToBeTyped = checkNotNull(stringToBeTyped, "The text to type in cannot be null.");
    this.executor = checkNotNull(executor);
    this.tapToFocus = tapToFocus;
  }

  @Override
  public ListenableFuture<Void> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController) {

    // No-op if string is empty.
    if (stringToBeTyped.length() == 0) {
      Log.w(TAG, "Text string is empty resulting in no-op (nothing is typed).");
      return immediateFuture(null);
    }

    try {
      ListenableFuture<Void> setTextEntryEmulationFuture =
          JdkFutureAdapters.listenInPoolThread(
              flutterTestingProtocol.perform(null, new SetTextEntryEmulationAction(false)));
      ListenableFuture<Rect> widgetRectFuture =
          JdkFutureAdapters.listenInPoolThread(flutterTestingProtocol.getLocalRect(targetWidget));
      // Waits until both Futures return and then proceeds.
      Rect widgetRectInDp =
          (Rect)
              loopUntilCompletion(
                      GET_LOCAL_RECT_TASK_NAME,
                      androidUiController,
                      allAsList(widgetRectFuture, setTextEntryEmulationFuture),
                      executor)
                  .get(0);

      // Clicks at the center of the Flutter widget (with no visibility check).
      //
      // Calls the click action separately so we get a chance to ensure Flutter is idle before
      // typing text.
      WidgetCoordinatesCalculator coordinatesCalculator =
          new WidgetCoordinatesCalculator(widgetRectInDp);
      if (tapToFocus) {
        GeneralClickAction clickAction =
            new GeneralClickAction(
                Tap.SINGLE,
                coordinatesCalculator,
                Press.FINGER,
                InputDevice.SOURCE_UNKNOWN,
                MotionEvent.BUTTON_PRIMARY);
        clickAction.perform(androidUiController, flutterView);
        loopUntilCompletion(
            FLUTTER_IDLE_TASK_NAME,
            androidUiController,
            flutterTestingProtocol.waitUntilIdle(),
            executor);
      }

      // Then types in text.
      ViewAction typeTextAction = new TypeTextAction(stringToBeTyped, false);
      typeTextAction.perform(androidUiController, flutterView);

      // Espresso will wait for the main thread to finish, so nothing else to wait for in the
      // testing thread.
      return immediateFuture(null);
    } catch (InterruptedException ie) {
      return immediateFailedFuture(ie);
    } catch (ExecutionException ee) {
      return immediateFailedFuture(ee.getCause());
    } finally {
      androidUiController.loopMainThreadUntilIdle();
    }
  }

  @Override
  public String toString() {
    return String.format(Locale.ROOT, "type text(%s)", stringToBeTyped);
  }

  /**
   * The {@link SyntheticAction} that configures text entry emulation.
   *
   * <p>If the text entry emulation is enabled, the operating system's configured keyboard will not
   * be invoked when the widget is focused. Explicitly disables the text entry emulation when text
   * input is supposed to be sent using the system's keyboard.
   *
   * <p>By default, the text entry emulation is enabled in the Flutter testing protocol.
   */
  private static final class SetTextEntryEmulationAction extends SyntheticAction {

    @Expose private final boolean enabled;

    /**
     * Constructs with the given text entry emulation setting.
     *
     * @param enabled whether the text entry emulation is enabled. When {@code enabled} is {@code
     *     true}, the system's configured keyboard will not be invoked when the widget is focused.
     */
    public SetTextEntryEmulationAction(boolean enabled) {
      super("set_text_entry_emulation");
      this.enabled = enabled;
    }

    /**
     * Constructs with the given text entry emulation setting and also a timeout setting for this
     * action.
     *
     * @param enabled whether the text entry emulation is enabled. When {@code enabled} is {@code
     *     true}, the system's configured keyboard will not be invoked when the widget is focused.
     * @param timeOutInMillis the timeout setting of this action.
     */
    public SetTextEntryEmulationAction(boolean enabled, long timeOutInMillis) {
      super("set_text_entry_emulation", timeOutInMillis);
      this.enabled = enabled;
    }
  }
}
