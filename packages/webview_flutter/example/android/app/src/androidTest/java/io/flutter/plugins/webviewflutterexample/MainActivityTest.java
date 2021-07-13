// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.webviewflutterexample;

import static androidx.test.espresso.flutter.EspressoFlutter.onFlutterWidget;
import static androidx.test.espresso.flutter.assertion.FlutterAssertions.matches;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.isExisting;
import static androidx.test.espresso.flutter.matcher.FlutterMatchers.withValueKey;
import androidx.test.core.app.ActivityScenario;
import androidx.test.runner.AndroidJUnit4;
import io.flutter.embedding.android.FlutterActivity;

import org.junit.After;
import org.junit.Before;
import org.junit.runner.RunWith;

import org.junit.Test;

@RunWith(AndroidJUnit4.class)
public class MainActivityTest {
  ActivityScenario<FlutterActivity> scenario;

  @Before
  public void setup() {
    scenario = ActivityScenario.launch(FlutterActivity.class);
  }

  @After
  public void cleanup() {
    scenario.close();
  }

  @Test
  public void testWebViewViewIsAddedToTree() {
    onFlutterWidget(withValueKey("example_webView")).check(matches(isExisting()));
  }
}
