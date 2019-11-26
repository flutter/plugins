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
