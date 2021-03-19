// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.matcher;

import static com.google.common.base.Preconditions.checkNotNull;

import androidx.test.espresso.flutter.api.WidgetMatcher;
import androidx.test.espresso.flutter.model.WidgetInfo;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import javax.annotation.Nonnull;
import org.hamcrest.Description;

/** A matcher that matches a Flutter widget with a given tooltip. */
public final class WithTooltipMatcher extends WidgetMatcher {

  @Expose
  @SerializedName("text")
  private final String tooltip;

  /**
   * Constructs the matcher with the given {@code tooltip} to be matched with.
   *
   * @param tooltip the tooltip to be matched with.
   */
  public WithTooltipMatcher(@Nonnull String tooltip) {
    super("ByTooltipMessage");
    this.tooltip = checkNotNull(tooltip);
  }

  /** Returns the tooltip string that shall be matched for the widget. */
  public String getTooltip() {
    return tooltip;
  }

  @Override
  public String toString() {
    return "with tooltip: " + tooltip;
  }

  @Override
  protected boolean matchesSafely(WidgetInfo widget) {
    return tooltip.equals(widget.getTooltip());
  }

  @Override
  public void describeTo(Description description) {
    description.appendText("with tooltip: ").appendText(tooltip);
  }
}
