/*
 * Copyright (C) 2019 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
