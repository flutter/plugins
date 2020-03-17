// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

public class GoogleSignInPluginTests {

  @Mock Context mockContext;
  @Mock PluginRegistry.Registrar mockRegistrar;
  @Mock BinaryMessenger mockMessenger;
  @Spy MethodChannel.Result result;
  @Mock GoogleSignInWrapper mockGoogleSignIn;
  GoogleSignInPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    when(mockRegistrar.messenger()).thenReturn(mockMessenger);
    when(mockRegistrar.context()).thenReturn(mockContext);
    GoogleSignInPlugin.registerWith(mockRegistrar);
    plugin = new GoogleSignInPlugin(mockRegistrar, mockGoogleSignIn);
  }

  @Test
  public void requestScopes_ResultErrorIfAccountIsNull() {
    MethodCall methodCall = new MethodCall("requestScopes", null);
    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(null);
    plugin.onMethodCall(methodCall, result);
    verify(result).error("sign_in_required", "No account to grant scopes.", null);
  }
}
