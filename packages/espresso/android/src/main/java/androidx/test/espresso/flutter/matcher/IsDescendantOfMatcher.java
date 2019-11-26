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
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import javax.annotation.Nonnull;
import org.hamcrest.Description;

/** A matcher that matches a Flutter widget with a given ancestor. */
public final class IsDescendantOfMatcher extends WidgetMatcher {

  private static final Gson gson =
      new GsonBuilder().excludeFieldsWithoutExposeAnnotation().create();

  private final WidgetMatcher ancestorMatcher;
  private final WidgetMatcher widgetMatcher;

  // Flutter Driver extension APIs only support JSON strings, not other JSON structures.
  // Thus, explicitly convert the matchers to JSON strings.
  @SerializedName("of")
  @Expose
  private final String jsonAncestorMatcher;

  @SerializedName("matching")
  @Expose
  private final String jsonWidgetMatcher;

  IsDescendantOfMatcher(
      @Nonnull WidgetMatcher ancestorMatcher, @Nonnull WidgetMatcher widgetMatcher) {
    super("Descendant");
    this.ancestorMatcher = checkNotNull(ancestorMatcher);
    this.widgetMatcher = checkNotNull(widgetMatcher);
    jsonAncestorMatcher = gson.toJson(ancestorMatcher);
    jsonWidgetMatcher = gson.toJson(widgetMatcher);
  }

  /** Returns the matcher to match the widget's ancestor. */
  public WidgetMatcher getAncestorMatcher() {
    return ancestorMatcher;
  }

  /** Returns the matcher to match the widget itself. */
  public WidgetMatcher getWidgetMatcher() {
    return widgetMatcher;
  }

  @Override
  public String toString() {
    return "matched with " + widgetMatcher + " with ancestor: " + ancestorMatcher;
  }

  @Override
  protected boolean matchesSafely(WidgetInfo widget) {
    // TODO: Using this matcher in the assertion is not supported yet.
    throw new UnsupportedOperationException("IsDescendantMatcher is not supported for assertion.");
  }

  @Override
  public void describeTo(Description description) {
    description
        .appendText("matched with ")
        .appendText(widgetMatcher.toString())
        .appendText(" with ancestor: ")
        .appendText(ancestorMatcher.toString());
  }
}
