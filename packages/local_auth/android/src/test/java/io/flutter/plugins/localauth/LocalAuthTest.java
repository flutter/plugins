// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

import org.junit.Test;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class LocalAuthTest {
  @Test
  public void isDeviceSupportedReturnsFalse() {
    final LocalAuthPlugin plugin = new LocalAuthPlugin();
    final MethodChannel.Result mockResult =  mock(MethodChannel.Result.class);
    plugin.onMethodCall(new MethodCall("isDeviceSupported", null), mockResult);
    verify(mockResult).success(false);
  }
}
