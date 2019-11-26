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

import androidx.test.espresso.flutter.api.SyntheticAction;
import com.google.gson.annotations.Expose;

/** Represents an action that retrieves the Flutter widget's diagnostics information. */
final class GetWidgetDiagnosticsAction extends SyntheticAction {

  @Expose private final String diagnosticsType = "widget";

  /**
   * Sets the depth of the retrieved diagnostics tree as 0. This means only the information of the
   * root widget will be retrieved.
   */
  @Expose private final int subtreeDepth = 0;

  /** Always includes the diagnostics properties of this widget. */
  @Expose private final boolean includeProperties = true;

  GetWidgetDiagnosticsAction() {
    super("get_diagnostics_tree");
  }
}
