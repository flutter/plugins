// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher;

import java.util.HashMap;
import java.util.Map;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.Assert;
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
