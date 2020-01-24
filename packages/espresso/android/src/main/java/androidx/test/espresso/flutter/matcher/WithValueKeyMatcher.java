// Copyright 2019 The Chromium Authors. All rights reserved.
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

/** A matcher that matches a Flutter widget with a given value key. */
public final class WithValueKeyMatcher extends WidgetMatcher {

  @Expose
  @SerializedName("keyValueString")
  private final String valueKey;

  @Expose private final String keyValueType = "String";

  /**
   * Constructs the matcher with the given value key String to be matched with.
   *
   * @param valueKey the value key String to be matched with.
   */
  public WithValueKeyMatcher(@Nonnull String valueKey) {
    super("ByValueKey");
    this.valueKey = checkNotNull(valueKey);
  }

  /** Returns the value key string that shall be matched for the widget. */
  public String getValueKey() {
    return valueKey;
  }

  @Override
  public String toString() {
    return "with value key: " + valueKey;
  }

  @Override
  protected boolean matchesSafely(WidgetInfo widget) {
    return valueKey.equals(widget.getValueKey());
  }

  @Override
  public void describeTo(Description description) {
    description.appendText("with value key: ").appendText(valueKey);
  }
}
