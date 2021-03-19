// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
