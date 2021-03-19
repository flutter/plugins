// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.matcher;

import androidx.test.espresso.flutter.model.WidgetInfo;
import org.hamcrest.Description;
import org.hamcrest.TypeSafeMatcher;

/** A matcher that checks the existence of a Flutter widget. */
public final class IsExistingMatcher extends TypeSafeMatcher<WidgetInfo> {

  /** Constructs the matcher. */
  IsExistingMatcher() {}

  @Override
  public String toString() {
    return "is existing";
  }

  @Override
  protected boolean matchesSafely(WidgetInfo widget) {
    return widget != null;
  }

  @Override
  public void describeTo(Description description) {
    description.appendText("should exist.");
  }
}
