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

/** A matcher that matches a Flutter widget with a given text. */
public final class WithTextMatcher extends WidgetMatcher {

  @Expose private final String text;

  /**
   * Constructs the matcher with the given text to be matched with.
   *
   * @param text the text to be matched with.
   */
  WithTextMatcher(@Nonnull String text) {
    super("ByText");
    this.text = checkNotNull(text);
  }

  /** Returns the text string that shall be matched for the widget. */
  public String getText() {
    return text;
  }

  @Override
  public String toString() {
    return "with text: " + text;
  }

  @Override
  protected boolean matchesSafely(WidgetInfo widget) {
    return text.equals(widget.getText());
  }

  @Override
  public void describeTo(Description description) {
    description.appendText("with text: ").appendText(text);
  }
}
