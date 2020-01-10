// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.matcher;

import static com.google.common.base.Preconditions.checkNotNull;

import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.model.WidgetInfo;
import com.google.gson.annotations.Expose;
import javax.annotation.Nonnull;
import org.hamcrest.Description;

/** A matcher that matches a Flutter widget with a given runtime type. */
public final class WithTypeMatcher extends WidgetMatcher {

  @Expose private final String type;

  /**
   * Constructs the matcher with the given runtime type to be matched with.
   *
   * @param type the runtime type to be matched with.
   */
  public WithTypeMatcher(@Nonnull String type) {
    super("ByType");
    this.type = checkNotNull(type);
  }

  /** Returns the type string that shall be matched for the widget. */
  public String getType() {
    return type;
  }

  @Override
  public String toString() {
    return "with runtime type: " + type;
  }

  @Override
  protected boolean matchesSafely(WidgetInfo widget) {
    return type.equals(widget.getType());
  }

  @Override
  public void describeTo(Description description) {
    description.appendText("with runtime type: ").appendText(type);
  }
}
