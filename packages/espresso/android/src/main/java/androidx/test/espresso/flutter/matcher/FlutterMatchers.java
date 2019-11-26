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
package androidx.test.espresso.flutter.matcher;

import android.view.View;
import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.model.WidgetInfo;
import io.flutter.embedding.android.FlutterView;
import javax.annotation.Nonnull;
import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;

/** A collection of matchers that match a Flutter view or Flutter widgets. */
public final class FlutterMatchers {

  /**
   * Returns a matcher that matches a {@link FlutterView} or a legacy {@code
   * io.flutter.view.FlutterView}.
   */
  public static Matcher<View> isFlutterView() {
    return new IsFlutterViewMatcher();
  }

  /**
   * Returns a matcher that matches a Flutter widget's tooltip.
   *
   * @param tooltip the tooltip String to match. Cannot be {@code null}.
   */
  public static WidgetMatcher withTooltip(@Nonnull String tooltip) {
    return new WithTooltipMatcher(tooltip);
  }

  /**
   * Returns a matcher that matches a Flutter widget's value key.
   *
   * @param valueKey the value key String to match. Cannot be {@code null}.
   */
  public static WidgetMatcher withValueKey(@Nonnull String valueKey) {
    return new WithValueKeyMatcher(valueKey);
  }

  /**
   * Returns a matcher that matches a Flutter widget's runtime type.
   *
   * <p>Usage:
   *
   * <p>{@code withType("TextField")} can be used to match a Flutter <a
   * href="https://api.flutter.dev/flutter/material/TextField-class.html">TextField</a> widget.
   *
   * @param type the type String to match. Cannot be {@code null}.
   */
  public static WidgetMatcher withType(@Nonnull String type) {
    return new WithTypeMatcher(type);
  }

  /**
   * Returns a matcher that matches a Flutter widget's text.
   *
   * @param text the text String to match. Cannot be {@code null}.
   */
  public static WidgetMatcher withText(@Nonnull String text) {
    return new WithTextMatcher(text);
  }

  /**
   * Returns a matcher that matches a Flutter widget based on the given ancestor matcher.
   *
   * @param ancestorMatcher the ancestor to match on. Cannot be null.
   * @param widgetMatcher the widget to match on. Cannot be null.
   */
  public static WidgetMatcher isDescendantOf(
      @Nonnull WidgetMatcher ancestorMatcher, @Nonnull WidgetMatcher widgetMatcher) {
    return new IsDescendantOfMatcher(ancestorMatcher, widgetMatcher);
  }

  /**
   * Returns a matcher that checks the existence of a Flutter widget.
   *
   * <p>Note, this matcher only guarantees that the widget exists in Flutter's widget tree, but not
   * necessarily displayed on screen, e.g. the widget is in the cache extend of a Scrollable, but
   * not scrolled onto the screen.
   */
  public static Matcher<WidgetInfo> isExisting() {
    return new IsExistingMatcher();
  }

  static final class IsFlutterViewMatcher extends TypeSafeMatcher<View> {

    private IsFlutterViewMatcher() {}

    @Override
    public void describeTo(Description description) {
      description.appendText("is a FlutterView");
    }

    @Override
    public boolean matchesSafely(View flutterView) {
      return flutterView instanceof FlutterView
          || (flutterView instanceof io.flutter.view.FlutterView);
    }
  }
}
