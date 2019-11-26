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
package androidx.test.espresso.flutter.api;

import static com.google.common.base.Preconditions.checkNotNull;

import androidx.test.espresso.flutter.model.WidgetInfo;
import com.google.common.annotations.Beta;
import com.google.gson.annotations.Expose;
import com.google.gson.annotations.SerializedName;
import javax.annotation.Nonnull;
import org.hamcrest.TypeSafeMatcher;

/**
 * Base matcher for Flutter widgets.
 *
 * <p>A widget matcher's function is two-fold:
 *
 * <ul>
 *   <li>A matcher that can be passed into Flutter for selecting a Flutter widget.
 *   <li>Works with the {@code MatchesWidgetAssertion} to assert on a widget's properties.
 * </ul>
 */
@Beta
public abstract class WidgetMatcher extends TypeSafeMatcher<WidgetInfo> {

  @Expose
  @SerializedName("finderType")
  protected String matcherId;

  /**
   * Constructs a {@code WidgetMatcher} instance with the given {@code matcherId}.
   *
   * @param matcherId the matcher id that represents this widget matcher.
   */
  public WidgetMatcher(@Nonnull String matcherId) {
    this.matcherId = checkNotNull(matcherId);
  }
}
