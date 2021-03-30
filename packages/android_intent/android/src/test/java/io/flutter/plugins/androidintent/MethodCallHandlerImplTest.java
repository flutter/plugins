// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.androidintent;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Matchers.any;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.robolectric.Shadows.shadowOf;

import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
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
import org.robolectric.RobolectricTestRunner;
import org.robolectric.shadows.ShadowPackageManager;

@RunWith(RobolectricTestRunner.class)
public class MethodCallHandlerImplTest {
  private static final String CHANNEL_NAME = "plugins.flutter.io/android_intent";
  private Context context;
  private IntentSender sender;
  private MethodCallHandlerImpl methodCallHandler;

  @Before
  public void setUp() {
    context = ApplicationProvider.getApplicationContext();
    sender = new IntentSender(null, null);
    methodCallHandler = new MethodCallHandlerImpl(sender);
  }

  @Test
  public void startListening_registersChannel() {
    BinaryMessenger messenger = mock(BinaryMessenger.class);

    methodCallHandler.startListening(messenger);

    verify(messenger, times(1))
        .setMessageHandler(eq(CHANNEL_NAME), any(BinaryMessageHandler.class));
  }

  @Test
  public void startListening_unregistersExistingChannel() {
    BinaryMessenger firstMessenger = mock(BinaryMessenger.class);
    BinaryMessenger secondMessenger = mock(BinaryMessenger.class);
    methodCallHandler.startListening(firstMessenger);

    methodCallHandler.startListening(secondMessenger);

    // Unregisters the first and then registers the second.
    verify(firstMessenger, times(1)).setMessageHandler(CHANNEL_NAME, null);
    verify(secondMessenger, times(1))
        .setMessageHandler(eq(CHANNEL_NAME), any(BinaryMessageHandler.class));
  }

  @Test
  public void stopListening_unregistersExistingChannel() {
    BinaryMessenger messenger = mock(BinaryMessenger.class);
    methodCallHandler.startListening(messenger);

    methodCallHandler.stopListening();

    verify(messenger, times(1)).setMessageHandler(CHANNEL_NAME, null);
  }

  @Test
  public void stopListening_doesNothingWhenUnset() {
    BinaryMessenger messenger = mock(BinaryMessenger.class);

    methodCallHandler.stopListening();

    verify(messenger, never()).setMessageHandler(CHANNEL_NAME, null);
  }

  @Test
  public void onMethodCall_doesNothingWhenContextIsNull() {
    Result result = mock(Result.class);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    // No matter what, should always succeed.
    verify(result, times(1)).success(null);
    assertNull(shadowOf((Application) context).getNextStartedActivity());
  }

  @Test
  public void onMethodCall_setsAction() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals("foo", intent.getAction());
  }

  @Test
  public void onMethodCall_setsNewTaskFlagWithApplicationContext() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK, intent.getFlags());
  }

  @Test
  public void onMethodCall_addsFlags() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    Integer requestFlags = Intent.FLAG_FROM_BACKGROUND;
    args.put("flags", requestFlags);
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK | requestFlags, intent.getFlags());
  }

  @Test
  public void onMethodCall_addsCategory() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    String category = "bar";
    args.put("category", category);
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertTrue(intent.getCategories().contains(category));
  }

  @Test
  public void onMethodCall_setsData() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    Uri data = Uri.parse("http://flutter.dev");
    args.put("data", data.toString());
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(data, intent.getData());
  }

  @Test
  public void onMethodCall_clearsInvalidPackageNames() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    args.put("packageName", "invalid");
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertNull(intent.getPackage());
  }

  @Test
  public void onMethodCall_setsComponentName() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    ComponentName expectedComponent =
        new ComponentName("io.flutter.plugins.androidintent", "MainActivity");
    args.put("action", "foo");
    args.put("package", expectedComponent.getPackageName());
    args.put("componentName", expectedComponent.getClassName());
    Result result = mock(Result.class);
    ShadowPackageManager shadowPm =
        shadowOf(ApplicationProvider.getApplicationContext().getPackageManager());
    shadowPm.addActivityIfNotPresent(expectedComponent);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertNotNull(intent.getComponent());
    assertEquals("foo", intent.getAction());
    assertEquals("io.flutter.plugins.androidintent", intent.getPackage());
    assertEquals(
        "io.flutter.plugins.androidintent/MainActivity", intent.getComponent().flattenToString());
  }

  @Test
  public void onMethodCall_setsOnlyComponentName() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    ComponentName expectedComponent =
        new ComponentName("io.flutter.plugins.androidintent", "MainActivity");
    args.put("package", expectedComponent.getPackageName());
    args.put("componentName", expectedComponent.getClassName());
    Result result = mock(Result.class);
    ShadowPackageManager shadowPm =
        shadowOf(ApplicationProvider.getApplicationContext().getPackageManager());
    shadowPm.addActivityIfNotPresent(expectedComponent);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertNotNull(intent.getComponent());
    assertEquals("io.flutter.plugins.androidintent", intent.getPackage());
    assertEquals(
        "io.flutter.plugins.androidintent/MainActivity", intent.getComponent().flattenToString());
  }

  @Test
  public void onMethodCall_setsType() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    String type = "video/*";
    args.put("type", type);
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(type, intent.getType());
  }

  @Test
  public void onMethodCall_setsDataAndType() {
    sender.setApplicationContext(context);
    Map<String, Object> args = new HashMap<>();
    args.put("action", "foo");
    Uri data = Uri.parse("http://flutter.dev");
    args.put("data", data.toString());
    String type = "video/*";
    args.put("type", type);
    Result result = mock(Result.class);

    methodCallHandler.onMethodCall(new MethodCall("launch", args), result);

    verify(result, times(1)).success(null);
    Intent intent = shadowOf((Application) context).getNextStartedActivity();
    assertNotNull(intent);
    assertEquals(type, intent.getType());
    assertEquals(data, intent.getData());
  }
}
