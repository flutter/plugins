// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidalarmmanagerexample;

import static androidx.test.espresso.Espresso.pressBackUnconditionally;
import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;
import static org.junit.Assert.assertEquals;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.test.InstrumentationRegistry;
import androidx.test.core.app.ActivityScenario;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import androidx.test.rule.ActivityTestRule;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class BackgroundExecutionTest {
  private SharedPreferences prefs;
  static final String COUNT_KEY = "flutter.count";

  @Rule
  public ActivityTestRule<DriverExtensionActivity> myActivityTestRule =
      new ActivityTestRule<>(DriverExtensionActivity.class, true, false);

  @Before
  public void setUp() throws Exception {
    Context context = InstrumentationRegistry.getInstrumentation().getTargetContext();
    prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
    prefs.edit().putLong(COUNT_KEY, 0).apply();

    ActivityScenario.launch(DriverExtensionActivity.class);
  }

  @Test
  public void startBackgroundIsolate() throws Exception {

    // Register a one shot alarm which will go off in ~5 seconds.
    onFlutterWidget(withValueKey("RegisterOneShotAlarm")).perform(click());

    // The alarm count should be 0 after installation.
    assertEquals(prefs.getLong(COUNT_KEY, -1), 0);

    // Close the application to background it.
    pressBackUnconditionally();

    // The alarm should eventually fire, wake up the application, create a
    // background isolate, and then increment the counter in the shared
    // preferences. Timeout after 20s, just to be safe.
    int tries = 0;
    while ((prefs.getLong(COUNT_KEY, -1) == 0) && (tries < 200)) {
      Thread.sleep(100);
      ++tries;
    }
    assertEquals(prefs.getLong(COUNT_KEY, -1), 1);
  }
}
