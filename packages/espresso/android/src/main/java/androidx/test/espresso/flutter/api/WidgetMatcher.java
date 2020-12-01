// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
