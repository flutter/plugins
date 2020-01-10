// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;

import androidx.test.espresso.flutter.api.SyntheticAction;
import com.google.gson.Gson;
import com.google.gson.annotations.Expose;

/**
 * Represents an action that waits until the specified conditions have been met in the Flutter app.
 */
final class WaitForConditionAction extends SyntheticAction {

  private static final Gson gson = new Gson();

  @Expose private final String conditionName = "CombinedCondition";

  @Expose private final String conditions;

  /**
   * Creates with the given wait conditions.
   *
   * @param waitConditions the conditions that this action shall wait for. Cannot be null.
   */
  public WaitForConditionAction(WaitCondition... waitConditions) {
    super("waitForCondition");
    conditions = gson.toJson(checkNotNull(waitConditions));
  }
}
