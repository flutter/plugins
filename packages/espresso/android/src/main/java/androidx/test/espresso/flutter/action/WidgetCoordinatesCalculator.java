// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.action;

import static com.google.common.base.Preconditions.checkNotNull;

import android.graphics.Rect;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import androidx.test.espresso.action.CoordinatesProvider;
import java.util.Arrays;

/** Provides coordinates of a Flutter widget. */
final class WidgetCoordinatesCalculator implements CoordinatesProvider {

  private static final String TAG = WidgetCoordinatesCalculator.class.getSimpleName();

  private final Rect widgetRectInDp;

  /**
   * Constructs with the local (as relative to the outer Flutter view) coordinates of a Flutter
   * widget in the unit of dp.
   *
   * @param widgetRectInDp the local widget coordinates in dp.
   */
  public WidgetCoordinatesCalculator(Rect widgetRectInDp) {
    this.widgetRectInDp = checkNotNull(widgetRectInDp);
  }

  @Override
  public float[] calculateCoordinates(View flutterView) {
    int deviceDensityDpi = flutterView.getContext().getResources().getDisplayMetrics().densityDpi;
    Rect widgetRectInPixel = convertDpToPixel(widgetRectInDp, deviceDensityDpi);
    float widgetCenterX = (widgetRectInPixel.left + widgetRectInPixel.right) / 2;
    float widgetCenterY = (widgetRectInPixel.top + widgetRectInPixel.bottom) / 2;
    int[] viewCords = new int[] {0, 0};
    flutterView.getLocationOnScreen(viewCords);
    float[] coords = new float[] {viewCords[0] + widgetCenterX, viewCords[1] + widgetCenterY};
    Log.d(
        TAG,
        String.format(
            "Clicks on widget[%s] on Flutter View[%d, %d][width:%d, height:%d] at coordinates"
                + " [%s] on screen",
            widgetRectInPixel,
            viewCords[0],
            viewCords[1],
            flutterView.getWidth(),
            flutterView.getHeight(),
            Arrays.toString(coords)));
    return coords;
  }

  private static Rect convertDpToPixel(Rect rectInDp, int densityDpi) {
    checkNotNull(rectInDp);
    int left = (int) convertDpToPixel(rectInDp.left, densityDpi);
    int top = (int) convertDpToPixel(rectInDp.top, densityDpi);
    int right = (int) convertDpToPixel(rectInDp.right, densityDpi);
    int bottom = (int) convertDpToPixel(rectInDp.bottom, densityDpi);
    return new Rect(left, top, right, bottom);
  }

  private static float convertDpToPixel(float dp, int densityDpi) {
    return dp * ((float) densityDpi / DisplayMetrics.DENSITY_DEFAULT);
  }
}
