// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.localauth;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.hardware.biometrics.BiometricManager;
import android.os.Build;
import androidx.biometric.BiometricPrompt;
import androidx.fragment.app.FragmentActivity;
import androidx.lifecycle.Lifecycle;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugins.localauth.utils.TestUtils;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class AuthenticationHelperTests {

  @Test
  public void authenticationHelper_shouldBuildBasicPromptInfo() {
    Lifecycle mockLifecycle = mock(Lifecycle.class);
    FragmentActivity mockActivity = mock(FragmentActivity.class);
    MethodCall mockMethodCall = mock(MethodCall.class);
    AuthenticationHelper.AuthCompletionHandler mockHandler =
        mock(AuthenticationHelper.AuthCompletionHandler.class);
    when(mockMethodCall.argument("stickyAuth")).thenReturn(false);
    when(mockMethodCall.argument("localizedReason")).thenReturn("localizedReasonValue");
    when(mockMethodCall.argument("signInTitle")).thenReturn("signInTitleValue");
    when(mockMethodCall.argument("biometricHint")).thenReturn("biometricHintValue");
    when(mockMethodCall.argument("sensitiveTransaction")).thenReturn(false);
    when(mockMethodCall.argument("cancelButton")).thenReturn("cancelButtonValue");
    AuthenticationHelper helper =
        new AuthenticationHelper(
            mockLifecycle, mockActivity, mockMethodCall, mockHandler, new int[] {});
    BiometricPrompt.PromptInfo promptInfo = helper.getPromptInfo();
    assertEquals("localizedReasonValue", promptInfo.getDescription());
    assertEquals("signInTitleValue", promptInfo.getTitle());
    assertEquals("biometricHintValue", promptInfo.getSubtitle());
    assertEquals(false, promptInfo.isConfirmationRequired());
    assertEquals("cancelButtonValue", promptInfo.getNegativeButtonText());
  }

  @Test
  public void authenticationHelper_shouldSetAllowedAuthenticatorsOnAPI30AndAbove() {
    Lifecycle mockLifecycle = mock(Lifecycle.class);
    FragmentActivity mockActivity = mock(FragmentActivity.class);
    MethodCall mockMethodCall = mock(MethodCall.class);
    AuthenticationHelper.AuthCompletionHandler mockHandler =
        mock(AuthenticationHelper.AuthCompletionHandler.class);
    when(mockMethodCall.argument("stickyAuth")).thenReturn(false);
    when(mockMethodCall.argument("localizedReason")).thenReturn("localizedReasonValue");
    when(mockMethodCall.argument("signInTitle")).thenReturn("signInTitleValue");
    when(mockMethodCall.argument("biometricHint")).thenReturn("biometricHintValue");
    when(mockMethodCall.argument("sensitiveTransaction")).thenReturn(false);
    when(mockMethodCall.argument("cancelButton")).thenReturn("cancelButtonValue");
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.R);
    AuthenticationHelper helper =
        new AuthenticationHelper(
            mockLifecycle,
            mockActivity,
            mockMethodCall,
            mockHandler,
            new int[] {
              BiometricManager.Authenticators.BIOMETRIC_WEAK,
              BiometricManager.Authenticators.BIOMETRIC_STRONG,
            });
    BiometricPrompt.PromptInfo promptInfo = helper.getPromptInfo();
    assertEquals(
        BiometricManager.Authenticators.BIOMETRIC_WEAK
            | BiometricManager.Authenticators.BIOMETRIC_STRONG,
        promptInfo.getAllowedAuthenticators());
    assertEquals(false, promptInfo.isDeviceCredentialAllowed());
  }

  @Test
  public void authenticationHelper_shouldSetDeviceCredentialsAllowedBelowAPI30() {
    Lifecycle mockLifecycle = mock(Lifecycle.class);
    FragmentActivity mockActivity = mock(FragmentActivity.class);
    MethodCall mockMethodCall = mock(MethodCall.class);
    AuthenticationHelper.AuthCompletionHandler mockHandler =
        mock(AuthenticationHelper.AuthCompletionHandler.class);
    when(mockMethodCall.argument("stickyAuth")).thenReturn(false);
    when(mockMethodCall.argument("localizedReason")).thenReturn("localizedReasonValue");
    when(mockMethodCall.argument("signInTitle")).thenReturn("signInTitleValue");
    when(mockMethodCall.argument("biometricHint")).thenReturn("biometricHintValue");
    when(mockMethodCall.argument("sensitiveTransaction")).thenReturn(false);
    when(mockMethodCall.argument("cancelButton")).thenReturn("cancelButtonValue");
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.Q);
    AuthenticationHelper helper =
        new AuthenticationHelper(
            mockLifecycle,
            mockActivity,
            mockMethodCall,
            mockHandler,
            new int[] {
              BiometricManager.Authenticators.DEVICE_CREDENTIAL,
              BiometricManager.Authenticators.BIOMETRIC_WEAK,
              BiometricManager.Authenticators.BIOMETRIC_STRONG,
            });
    BiometricPrompt.PromptInfo promptInfo = helper.getPromptInfo();
    assertEquals(0, promptInfo.getAllowedAuthenticators());
    assertTrue(promptInfo.isDeviceCredentialAllowed());
    assertEquals("", promptInfo.getNegativeButtonText());
  }

  @Test
  public void authenticationHelper_shouldSetNegativeButtonText_whenDeviceCredentialsNotAllowed() {
    Lifecycle mockLifecycle = mock(Lifecycle.class);
    FragmentActivity mockActivity = mock(FragmentActivity.class);
    MethodCall mockMethodCall = mock(MethodCall.class);
    AuthenticationHelper.AuthCompletionHandler mockHandler =
        mock(AuthenticationHelper.AuthCompletionHandler.class);
    when(mockMethodCall.argument("stickyAuth")).thenReturn(false);
    when(mockMethodCall.argument("localizedReason")).thenReturn("localizedReasonValue");
    when(mockMethodCall.argument("signInTitle")).thenReturn("signInTitleValue");
    when(mockMethodCall.argument("biometricHint")).thenReturn("biometricHintValue");
    when(mockMethodCall.argument("sensitiveTransaction")).thenReturn(false);
    when(mockMethodCall.argument("cancelButton")).thenReturn("cancelButtonValue");
    TestUtils.setFinalStatic(Build.VERSION.class, "SDK_INT", Build.VERSION_CODES.Q);
    AuthenticationHelper helper =
        new AuthenticationHelper(
            mockLifecycle,
            mockActivity,
            mockMethodCall,
            mockHandler,
            new int[] {
              BiometricManager.Authenticators.BIOMETRIC_WEAK,
              BiometricManager.Authenticators.BIOMETRIC_STRONG,
            });
    BiometricPrompt.PromptInfo promptInfo = helper.getPromptInfo();
    assertEquals("cancelButtonValue", promptInfo.getNegativeButtonText());
  }
}
