// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera_android_camerax_example;

import static org.junit.Assert.assertTrue;

import androidx.test.core.app.ActivityScenario;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import io.flutter.plugins.DartIntegrationTest;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@DartIntegrationTest
@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Before
  public void setUp() throws Exception {
    ActivityScenario.launch(MainActivity.class);
  }

  @Test
  public void fakeTest() {
    assertTrue(true);
  }
}
