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
