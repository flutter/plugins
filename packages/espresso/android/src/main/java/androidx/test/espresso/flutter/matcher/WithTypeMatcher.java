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
