// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
