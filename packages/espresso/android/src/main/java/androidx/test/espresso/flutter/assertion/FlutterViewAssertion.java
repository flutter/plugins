// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.assertion;

import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isFlutterView;
import static com.google.common.base.Preconditions.checkNotNull;

import android.view.View;
import androidx.test.espresso.NoMatchingViewException;
import androidx.test.espresso.ViewAssertion;
import androidx.test.espresso.flutter.api.WidgetAssertion;
import androidx.test.espresso.flutter.exception.InvalidFlutterViewException;
import androidx.test.espresso.flutter.model.WidgetInfo;
import androidx.test.espresso.util.HumanReadables;

/**
 * A {@code ViewAssertion} which performs an action on the given Flutter view.
 *
 * <p>This class acts as a bridge to perform {@code WidgetAssertion} on a Flutter widget on the
 * given Flutter view.
 */
public final class FlutterViewAssertion implements ViewAssertion {

  private final WidgetAssertion assertion;
  private final WidgetInfo widgetInfo;

  public FlutterViewAssertion(WidgetAssertion assertion, WidgetInfo widgetInfo) {
    this.assertion = checkNotNull(assertion, "Widget assertion cannot be null.");
    this.widgetInfo = checkNotNull(widgetInfo, "The widget info to be asserted on cannot be null.");
  }

  @Override
  public void check(View view, NoMatchingViewException noViewFoundException) {
    if (view == null) {
      throw noViewFoundException;
    } else if (!isFlutterView().matches(view)) {
      throw new InvalidFlutterViewException(
          String.format("Not a valid Flutter view:%s", HumanReadables.describe(view)));
    } else {
      assertion.check(view, widgetInfo);
    }
  }
}
