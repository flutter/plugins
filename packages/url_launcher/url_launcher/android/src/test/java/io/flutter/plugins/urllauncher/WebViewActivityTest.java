// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import static org.mockito.Matchers.any;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.os.Bundle;
import androidx.test.core.app.ApplicationProvider;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.BinaryMessenger.BinaryMessageHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.Result;
import java.util.HashMap;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.Assert.assertEquals;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class WebViewActivityTest {
  private static final String CHANNEL_NAME = "plugins.flutter.io/url_launcher";

  @Test
  public void extractHeaders_returnsEmptyMapWhenArgumentIsNull() {
    Map<String, String> result = WebViewActivity.extractHeaders(null);
    Assert.assertEquals(new HashMap<>(), result);
  }
}
