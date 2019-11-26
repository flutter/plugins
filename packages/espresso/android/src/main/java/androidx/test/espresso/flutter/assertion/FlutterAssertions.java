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

import static com.google.common.base.Preconditions.checkNotNull;
import static org.hamcrest.MatcherAssert.assertThat;

import android.view.View;
import androidx.test.espresso.flutter.api.WidgetAssertion;
import androidx.test.espresso.flutter.model.WidgetInfo;
import javax.annotation.Nonnull;
import org.hamcrest.Matcher;

/** Collection of common {@link WidgetAssertion} instances. */
public final class FlutterAssertions {

  /**
   * Returns a generic {@link WidgetAssertion} that asserts that a Flutter widget exists and is
   * matched by the given widget matcher.
   */
  public static WidgetAssertion matches(@Nonnull Matcher<WidgetInfo> widgetMatcher) {
    return new MatchesWidgetAssertion(checkNotNull(widgetMatcher, "Matcher cannot be null."));
  }

  /** A widget assertion that checks whether a widget is matched by the given matcher. */
  static class MatchesWidgetAssertion implements WidgetAssertion {

    private final Matcher<WidgetInfo> widgetMatcher;

    private MatchesWidgetAssertion(Matcher<WidgetInfo> widgetMatcher) {
      this.widgetMatcher = checkNotNull(widgetMatcher);
    }

    @Override
    public void check(View flutterView, WidgetInfo widgetInfo) {
      assertThat(widgetInfo, widgetMatcher);
    }
  }
}
