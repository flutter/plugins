// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactionsexample;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ShortcutInfo;
import android.content.pm.ShortcutManager;
import android.util.Log;
import androidx.lifecycle.Lifecycle;
import androidx.test.core.app.ActivityScenario;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.By;
import androidx.test.uiautomator.UiDevice;
import androidx.test.uiautomator.Until;
import io.flutter.plugins.quickactions.QuickActionsPlugin;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicReference;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class QuickActionsTest {
  private Context context;
  private UiDevice device;
  private ActivityScenario<QuickActionsTestActivity> scenario;

  @Before
  public void setUp() {
    context = ApplicationProvider.getApplicationContext();
    device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation());
    scenario = ensureAppRunToView();
    ensureAllAppShortcutsAreCreated();
  }

  @After
  public void tearDown() {
    scenario.close();
    Log.i(QuickActionsTest.class.getSimpleName(), "Run to completion");
  }

  @Test
  public void quickActionPluginIsAdded() {
    final ActivityScenario<QuickActionsTestActivity> scenario =
        ActivityScenario.launch(QuickActionsTestActivity.class);
    scenario.onActivity(
        activity -> {
          assertTrue(activity.engine.getPlugins().has(QuickActionsPlugin.class));
        });
  }

  @Test
  public void appShortcutsAreCreated() {
    List<ShortcutInfo> expectedShortcuts = createMockShortcuts();

    ShortcutManager shortcutManager =
        (ShortcutManager) context.getSystemService(Context.SHORTCUT_SERVICE);
    List<ShortcutInfo> dynamicShortcuts = shortcutManager.getDynamicShortcuts();

    // Assert the app shortcuts defined in ../lib/main.dart.
    assertFalse(dynamicShortcuts.isEmpty());
    assertEquals(expectedShortcuts.size(), dynamicShortcuts.size());
    for (ShortcutInfo expectedShortcut : expectedShortcuts) {
      ShortcutInfo dynamicShortcut =
          dynamicShortcuts
              .stream()
              .filter(s -> s.getId().equals(expectedShortcut.getId()))
              .findFirst()
              .get();

      assertEquals(expectedShortcut.getShortLabel(), dynamicShortcut.getShortLabel());
      assertEquals(expectedShortcut.getLongLabel(), dynamicShortcut.getLongLabel());
    }
  }

  @Test
  public void appShortcutLaunchActivityAfterStarting() {
    // Arrange
    List<ShortcutInfo> shortcuts = createMockShortcuts();
    ShortcutInfo firstShortcut = shortcuts.get(0);
    ShortcutManager shortcutManager =
        (ShortcutManager) context.getSystemService(Context.SHORTCUT_SERVICE);
    List<ShortcutInfo> dynamicShortcuts = shortcutManager.getDynamicShortcuts();
    ShortcutInfo dynamicShortcut =
        dynamicShortcuts
            .stream()
            .filter(s -> s.getId().equals(firstShortcut.getId()))
            .findFirst()
            .get();
    Intent dynamicShortcutIntent = dynamicShortcut.getIntent();
    AtomicReference<QuickActionsTestActivity> initialActivity = new AtomicReference<>();
    scenario.onActivity(initialActivity::set);
    String appReadySentinel = " has launched";

    // Act
    context.startActivity(dynamicShortcutIntent);
    device.wait(Until.hasObject(By.descContains(appReadySentinel)), 2000);
    AtomicReference<QuickActionsTestActivity> currentActivity = new AtomicReference<>();
    scenario.onActivity(currentActivity::set);

    // Assert
    Assert.assertTrue(
        "AppShortcut:" + firstShortcut.getId() + " does not launch the correct activity",
        // We can only find the shortcut type in content description while inspecting it in Ui
        // Automator Viewer.
        device.hasObject(By.desc(firstShortcut.getId() + appReadySentinel)));
    // This is Android SingleTop behavior in which Android does not destroy the initial activity and
    // launch a new activity.
    Assert.assertEquals(initialActivity.get(), currentActivity.get());
  }

  private void ensureAllAppShortcutsAreCreated() {
    device.wait(Until.hasObject(By.text("actions ready")), 1000);
  }

  private List<ShortcutInfo> createMockShortcuts() {
    List<ShortcutInfo> expectedShortcuts = new ArrayList<>();

    String actionOneLocalizedTitle = "Action one";
    expectedShortcuts.add(
        new ShortcutInfo.Builder(context, "action_one")
            .setShortLabel(actionOneLocalizedTitle)
            .setLongLabel(actionOneLocalizedTitle)
            .build());

    String actionTwoLocalizedTitle = "Action two";
    expectedShortcuts.add(
        new ShortcutInfo.Builder(context, "action_two")
            .setShortLabel(actionTwoLocalizedTitle)
            .setLongLabel(actionTwoLocalizedTitle)
            .build());

    return expectedShortcuts;
  }

  private ActivityScenario<QuickActionsTestActivity> ensureAppRunToView() {
    final ActivityScenario<QuickActionsTestActivity> scenario =
        ActivityScenario.launch(QuickActionsTestActivity.class);
    scenario.moveToState(Lifecycle.State.STARTED);
    return scenario;
  }
}
