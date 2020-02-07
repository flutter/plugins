// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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
