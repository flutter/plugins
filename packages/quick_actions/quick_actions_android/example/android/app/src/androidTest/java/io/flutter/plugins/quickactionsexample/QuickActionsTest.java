// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactionsexample;

import static org.junit.Assert.assertTrue;

import androidx.test.core.app.ActivityScenario;
import io.flutter.plugins.quickactions.QuickActionsPlugin;
import org.junit.Test;

public class QuickActionsTest {
  @Test
  public void imagePickerPluginIsAdded() {
    final ActivityScenario<QuickActionsTestActivity> scenario =
        ActivityScenario.launch(QuickActionsTestActivity.class);
    scenario.onActivity(
        activity -> {
          assertTrue(activity.engine.getPlugins().has(QuickActionsPlugin.class));
        });
  }
}
