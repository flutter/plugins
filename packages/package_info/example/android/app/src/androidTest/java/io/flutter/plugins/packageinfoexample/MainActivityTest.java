// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.packageinfoexample;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.instrumentationadapter.FlutterRunner;
import dev.flutter.plugins.instrumentationadapter.FlutterTest;
import org.junit.runner.RunWith;

@RunWith(FlutterRunner.class)
public class MainActivityTest extends FlutterTest {
  public void launchActivity() {
    ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class);
    rule.launchActivity(null);
  }
}
