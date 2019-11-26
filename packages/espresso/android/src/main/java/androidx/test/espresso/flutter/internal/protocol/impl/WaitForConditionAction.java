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
