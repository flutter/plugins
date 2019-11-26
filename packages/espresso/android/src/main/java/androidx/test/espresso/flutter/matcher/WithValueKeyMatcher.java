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
