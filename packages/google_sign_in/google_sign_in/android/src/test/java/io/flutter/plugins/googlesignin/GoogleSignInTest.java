// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlesignin;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.common.api.Scope;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.Spy;

public class GoogleSignInTest {
  @Mock Context mockContext;
  @Mock Activity mockActivity;
  @Mock PluginRegistry.Registrar mockRegistrar;
  @Mock BinaryMessenger mockMessenger;
  @Spy MethodChannel.Result result;
  @Mock GoogleSignInWrapper mockGoogleSignIn;
  @Mock GoogleSignInAccount account;
  private GoogleSignInPlugin plugin;

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    when(mockRegistrar.messenger()).thenReturn(mockMessenger);
    when(mockRegistrar.context()).thenReturn(mockContext);
    when(mockRegistrar.activity()).thenReturn(mockActivity);
    plugin = new GoogleSignInPlugin();
    plugin.initInstance(mockRegistrar.messenger(), mockRegistrar.context(), mockGoogleSignIn);
    plugin.setUpRegistrar(mockRegistrar);
  }

  @Test
  public void requestScopes_ResultErrorIfAccountIsNull() {
    MethodCall methodCall = new MethodCall("requestScopes", null);
    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(null);
    plugin.onMethodCall(methodCall, result);
    verify(result).error("sign_in_required", "No account to grant scopes.", null);
  }

  @Test
  public void requestScopes_ResultTrueIfAlreadyGranted() {
    HashMap<String, List<String>> arguments = new HashMap<>();
    arguments.put("scopes", Collections.singletonList("requestedScope"));

    MethodCall methodCall = new MethodCall("requestScopes", arguments);
    Scope requestedScope = new Scope("requestedScope");
    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(true);

    plugin.onMethodCall(methodCall, result);
    verify(result).success(true);
  }

  @Test
  public void requestScopes_RequestsPermissionIfNotGranted() {
    HashMap<String, List<String>> arguments = new HashMap<>();
    arguments.put("scopes", Collections.singletonList("requestedScope"));
    MethodCall methodCall = new MethodCall("requestScopes", arguments);
    Scope requestedScope = new Scope("requestedScope");

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.onMethodCall(methodCall, result);

    verify(mockGoogleSignIn)
        .requestPermissions(mockActivity, 53295, account, new Scope[] {requestedScope});
  }

  @Test
  public void requestScopes_ReturnsFalseIfPermissionDenied() {
    HashMap<String, List<String>> arguments = new HashMap<>();
    arguments.put("scopes", Collections.singletonList("requestedScope"));
    MethodCall methodCall = new MethodCall("requestScopes", arguments);
    Scope requestedScope = new Scope("requestedScope");

    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.onMethodCall(methodCall, result);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE,
        Activity.RESULT_CANCELED,
        new Intent());

    verify(result).success(false);
  }

  @Test
  public void requestScopes_ReturnsTrueIfPermissionGranted() {
    HashMap<String, List<String>> arguments = new HashMap<>();
    arguments.put("scopes", Collections.singletonList("requestedScope"));
    MethodCall methodCall = new MethodCall("requestScopes", arguments);
    Scope requestedScope = new Scope("requestedScope");

    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.onMethodCall(methodCall, result);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());

    verify(result).success(true);
  }

  @Test
  public void requestScopes_mayBeCalledRepeatedly_ifAlreadyGranted() {
    HashMap<String, List<String>> arguments = new HashMap<>();
    arguments.put("scopes", Collections.singletonList("requestedScope"));
    MethodCall methodCall = new MethodCall("requestScopes", arguments);
    Scope requestedScope = new Scope("requestedScope");

    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(account);
    when(account.getGrantedScopes()).thenReturn(Collections.singleton(requestedScope));
    when(mockGoogleSignIn.hasPermissions(account, requestedScope)).thenReturn(false);

    plugin.onMethodCall(methodCall, result);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());
    plugin.onMethodCall(methodCall, result);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());

    verify(result, times(2)).success(true);
  }

  @Test
  public void requestScopes_mayBeCalledRepeatedly_ifNotSignedIn() {
    HashMap<String, List<String>> arguments = new HashMap<>();
    arguments.put("scopes", Collections.singletonList("requestedScope"));
    MethodCall methodCall = new MethodCall("requestScopes", arguments);
    Scope requestedScope = new Scope("requestedScope");

    ArgumentCaptor<PluginRegistry.ActivityResultListener> captor =
        ArgumentCaptor.forClass(PluginRegistry.ActivityResultListener.class);
    verify(mockRegistrar).addActivityResultListener(captor.capture());
    PluginRegistry.ActivityResultListener listener = captor.getValue();

    when(mockGoogleSignIn.getLastSignedInAccount(mockContext)).thenReturn(null);

    plugin.onMethodCall(methodCall, result);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());
    plugin.onMethodCall(methodCall, result);
    listener.onActivityResult(
        GoogleSignInPlugin.Delegate.REQUEST_CODE_REQUEST_SCOPE, Activity.RESULT_OK, new Intent());

    verify(result, times(2)).error("sign_in_required", "No account to grant scopes.", null);
  }

  @Test(expected = IllegalStateException.class)
  public void signInThrowsWithoutActivity() {
    final GoogleSignInPlugin plugin = new GoogleSignInPlugin();
    plugin.initInstance(
        mock(BinaryMessenger.class), mock(Context.class), mock(GoogleSignInWrapper.class));

    plugin.onMethodCall(new MethodCall("signIn", null), null);
  }
}
