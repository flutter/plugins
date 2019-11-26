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
