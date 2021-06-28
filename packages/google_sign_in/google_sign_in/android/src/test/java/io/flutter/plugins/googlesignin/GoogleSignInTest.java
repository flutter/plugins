// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import static org.mockito.Mockito.mock;

import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import org.junit.Test;

public class GoogleSignInTest {
  @Test(expected = IllegalStateException.class)
  public void signInThrowsWithoutActivity() {
    final GoogleSignInPlugin plugin = new GoogleSignInPlugin();
    plugin.initInstance(
        mock(BinaryMessenger.class), mock(Context.class), mock(GoogleSignInWrapper.class));

    plugin.onMethodCall(new MethodCall("signIn", null), null);
  }
}
