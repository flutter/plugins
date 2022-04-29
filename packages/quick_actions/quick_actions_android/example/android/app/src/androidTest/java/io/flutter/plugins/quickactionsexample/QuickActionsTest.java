// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactionsexample;

import static org.junit.Assert.*;

import android.content.Context;
import android.content.pm.ShortcutInfo;
import android.content.pm.ShortcutManager;
import android.util.Log;
import androidx.lifecycle.Lifecycle;
import androidx.test.core.app.ActivityScenario;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.uiautomator.*;
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
  }

  @After
  public void tearDown() {
    scenario.close();
    Log.i(QuickActionsTest.class.getSimpleName(), "Run to completion");
  }

  @Test
  public void imagePickerPluginIsAdded() {
    final ActivityScenario<QuickActionsTestActivity> scenario =
        ActivityScenario.launch(QuickActionsTestActivity.class);
    scenario.onActivity(
        activity -> {
          assertTrue(activity.engine.getPlugins().has(QuickActionsPlugin.class));
        });
  }

  @Test
  public void appShortcutsAreCreated() {
    List<Shortcut> expectedShortcuts = createMockShortcuts();

    ShortcutManager shortcutManager =
        (ShortcutManager) context.getSystemService(Context.SHORTCUT_SERVICE);
    List<ShortcutInfo> dynamicShortcuts = shortcutManager.getDynamicShortcuts();
    Object[] shortcuts = dynamicShortcuts.stream().map(Shortcut::new).toArray();

    // Assert the app shortcuts defined in ../lib/main.dart.
    assertFalse(dynamicShortcuts.isEmpty());
    assertEquals(2, dynamicShortcuts.size());
    assertArrayEquals(expectedShortcuts.toArray(), shortcuts);
  }

  @Test
  public void appShortcutExistsAfterLongPressingAppIcon() throws UiObjectNotFoundException {
    List<Shortcut> shortcuts = createMockShortcuts();
    String appName = context.getApplicationInfo().loadLabel(context.getPackageManager()).toString();

    findAppIcon(device, appName).longClick();

    for (Shortcut shortcut : shortcuts) {
      Assert.assertTrue(
          "The specified shortcut label '" + shortcut.shortLabel + "' does not exist.",
          device.hasObject(By.text(shortcut.shortLabel)));
    }
  }

  @Test
  public void appShortcutLaunchActivityAfterPressing() throws UiObjectNotFoundException {
    // Arrange
    List<Shortcut> shortcuts = createMockShortcuts();
    String appName = context.getApplicationInfo().loadLabel(context.getPackageManager()).toString();
    Shortcut firstShortcut = shortcuts.get(0);
    AtomicReference<QuickActionsTestActivity> initialActivity = new AtomicReference<>();
    scenario.onActivity(initialActivity::set);

    // Act
    findAppIcon(device, appName).longClick();
    UiObject appShortcut = device.findObject(new UiSelector().text(firstShortcut.shortLabel));
    appShortcut.clickAndWaitForNewWindow();
    AtomicReference<QuickActionsTestActivity> currentActivity = new AtomicReference<>();
    scenario.onActivity(currentActivity::set);

    // Assert
    Assert.assertTrue(
        "AppShortcut:" + firstShortcut.type + " does not launch the correct activity",
        // We can only find the shortcut type in content description while inspecting it in Ui
        // Automator Viewer.
        device.hasObject(By.desc(firstShortcut.type)));
    // This is Android SingleTop behavior in which Android does not destroy the initial activity and
    // launch a new activity.
    Assert.assertEquals(initialActivity.get(), currentActivity.get());
  }

  private List<Shortcut> createMockShortcuts() {
    List<Shortcut> expectedShortcuts = new ArrayList<>();
    String actionOneLocalizedTitle = "Action one";
    expectedShortcuts.add(
        new Shortcut("action_one", actionOneLocalizedTitle, actionOneLocalizedTitle));

    String actionTwoLocalizedTitle = "Action two";
    expectedShortcuts.add(
        new Shortcut("action_two", actionTwoLocalizedTitle, actionTwoLocalizedTitle));

    return expectedShortcuts;
  }

  private ActivityScenario<QuickActionsTestActivity> ensureAppRunToView() {
    final ActivityScenario<QuickActionsTestActivity> scenario =
        ActivityScenario.launch(QuickActionsTestActivity.class);
    scenario.moveToState(Lifecycle.State.STARTED);
    return scenario;
  }

  private UiObject findAppIcon(UiDevice device, String appName) throws UiObjectNotFoundException {
    device.pressHome();

    // Swipe up to open App Drawer
    UiScrollable homeView = new UiScrollable(new UiSelector().scrollable(true));
    homeView.scrollForward();

    if (!device.hasObject(By.text(appName))) {
      Log.i(
          QuickActionsTest.class.getSimpleName(),
          "Attempting to scroll App Drawer for App Icon...");
      UiScrollable appDrawer = new UiScrollable(new UiSelector().scrollable(true));
      // The scrollTextIntoView scrolls to the beginning before performing searching scroll; this
      // causes an issue in a scenario where the view is already in the beginning. In this case, it
      // scrolls back to home view. Therefore, we perform a dummy forward scroll to ensure it is not
      // in the beginning.
      appDrawer.scrollForward();
      appDrawer.scrollTextIntoView(appName);
    }

    return device.findObject(new UiSelector().text(appName));
  }
}
