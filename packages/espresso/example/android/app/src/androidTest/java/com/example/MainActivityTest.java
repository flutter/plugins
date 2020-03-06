// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.espresso_example;

import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.action.FlutterActions.click;
import static androidx.test.espresso.flutter.action.FlutterActions.syntheticClick;
import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withText;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withTooltip;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;
import static com.google.common.truth.Truth.assertThat;

import androidx.test.core.app.ActivityScenario;
import androidx.test.espresso.flutter.EspressoFlutter.WidgetInteraction;
import androidx.test.espresso.flutter.assertion.FlutterAssertions;
import androidx.test.espresso.flutter.matcher.FlutterMatchers;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/** Unit tests for {@link EspressoFlutter}. */
@RunWith(AndroidJUnit4.class)
public class MainActivityTest {

  @Before
  public void setUp() throws Exception {
    ActivityScenario.launch(MainActivity.class);
  }

  @Test
  public void performTripleClick() {
    WidgetInteraction interaction =
        onFlutterWidget(withTooltip("Increment")).perform(click(), click()).perform(click());
    assertThat(interaction).isNotNull();
    onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 3 times.")));
  }

  @Test
  public void performClick() {
    WidgetInteraction interaction = onFlutterWidget(withTooltip("Increment")).perform(click());
    assertThat(interaction).isNotNull();
    onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 1 time.")));
  }

  @Test
  public void performSyntheticClick() {
    WidgetInteraction interaction =
        onFlutterWidget(withTooltip("Increment")).perform(syntheticClick());
    assertThat(interaction).isNotNull();
    onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 1 time.")));
  }

  @Test
  public void performTwiceSyntheticClicks() {
    WidgetInteraction interaction =
        onFlutterWidget(withTooltip("Increment")).perform(syntheticClick(), syntheticClick());
    assertThat(interaction).isNotNull();
    onFlutterWidget(withValueKey("CountText")).check(matches(withText("Button tapped 2 times.")));
  }

  @Test
  public void isIncrementButtonExists() {
    onFlutterWidget(FlutterMatchers.withTooltip("Increment"))
        .check(FlutterAssertions.matches(FlutterMatchers.isExisting()));
  }

  @Test
  public void isAppBarExists() {
    onFlutterWidget(FlutterMatchers.withType("AppBar"))
        .check(FlutterAssertions.matches(FlutterMatchers.isExisting()));
  }
}
