// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import static androidx.test.espresso.flutter.action.ActionUtil.loopUntilCompletion;
import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.util.concurrent.Futures.immediateFailedFuture;
import static com.google.common.util.concurrent.Futures.immediateFuture;

import android.graphics.Rect;
import android.view.InputDevice;
import android.view.MotionEvent;
import android.view.View;
import androidx.test.espresso.UiController;
import androidx.test.espresso.ViewAction;
import androidx.test.espresso.action.GeneralClickAction;
import androidx.test.espresso.action.Press;
import androidx.test.espresso.action.Tap;
import androidx.test.espresso.flutter.api.FlutterTestingProtocol;
import androidx.test.espresso.flutter.api.WidgetAction;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import com.google.common.util.concurrent.ListenableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Future;
import javax.annotation.Nonnull;
import javax.annotation.Nullable;

/** A click on the given Flutter widget by issuing gesture events to the Android system. */
public final class ClickAction implements WidgetAction {

  private static final String GET_LOCAL_RECT_TASK_NAME = "ClickAction#getLocalRect";

  private final ExecutorService executor;

  public ClickAction(@Nonnull ExecutorService executor) {
    this.executor = checkNotNull(executor);
  }

  @Override
  public ListenableFuture<Void> perform(
      @Nullable WidgetMatcher targetWidget,
      @Nonnull View flutterView,
      @Nonnull FlutterTestingProtocol flutterTestingProtocol,
      @Nonnull UiController androidUiController) {

    try {
      Future<Rect> widgetRectFuture = flutterTestingProtocol.getLocalRect(targetWidget);
      Rect widgetRectInDp =
          loopUntilCompletion(
              GET_LOCAL_RECT_TASK_NAME, androidUiController, widgetRectFuture, executor);
      WidgetCoordinatesCalculator coordinatesCalculator =
          new WidgetCoordinatesCalculator(widgetRectInDp);
      // Clicks at the center of the Flutter widget (with no visibility check), with all the default
      // settings of a native View's click action.
      ViewAction clickAction =
          new GeneralClickAction(
              Tap.SINGLE,
              coordinatesCalculator,
              Press.FINGER,
              InputDevice.SOURCE_UNKNOWN,
              MotionEvent.BUTTON_PRIMARY);
      clickAction.perform(androidUiController, flutterView);

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
    return "click";
  }
}
