// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import static io.flutter.plugins.quickactions.MethodCallHandlerImpl.EXTRA_ACTION;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.StandardMethodCodec;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.nio.ByteBuffer;
import org.junit.After;
import org.junit.Test;
import org.mockito.internal.util.reflection.FieldSetter;

public class QuickActionsTest {
  private static class TestBinaryMessenger implements BinaryMessenger {
    public MethodCall lastMethodCall;

    @Override
    public void send(@NonNull String channel, @Nullable ByteBuffer message) {
      send(channel, message, null);
    }

    @Override
    public void send(
        @NonNull String channel,
        @Nullable ByteBuffer message,
        @Nullable final BinaryReply callback) {
      if (channel.equals("plugins.flutter.io/quick_actions")) {
        lastMethodCall =
            StandardMethodCodec.INSTANCE.decodeMethodCall((ByteBuffer) message.position(0));
      }
    }

    @Override
    public void setMessageHandler(@NonNull String channel, @Nullable BinaryMessageHandler handler) {
      // Do nothing.
    }
  }

  static final int SUPPORTED_BUILD = 25;
  static final int UNSUPPORTED_BUILD = 24;
  static final String SHORTCUT_TYPE = "action_one";

  @Test
  public void canAttachToEngine() {
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(testBinaryMessenger);

    final QuickActionsPlugin plugin = new QuickActionsPlugin();
    plugin.onAttachedToEngine(mockPluginBinding);
  }

  @Test
  public void onAttachedToActivity_buildVersionSupported_invokesLaunchMethod()
      throws NoSuchFieldException, IllegalAccessException {
    // Arrange
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final QuickActionsPlugin plugin = new QuickActionsPlugin();
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin);
    setBuildVersion(SUPPORTED_BUILD);
    FieldSetter.setField(
        plugin,
        QuickActionsPlugin.class.getDeclaredField("handler"),
        mock(MethodCallHandlerImpl.class));
    final Intent mockIntent = createMockIntentWithQuickActionExtra();
    final Activity mockMainActivity = mock(Activity.class);
    when(mockMainActivity.getIntent()).thenReturn(mockIntent);
    final ActivityPluginBinding mockActivityPluginBinding = mock(ActivityPluginBinding.class);
    when(mockActivityPluginBinding.getActivity()).thenReturn(mockMainActivity);

    // Act
    plugin.onAttachedToActivity(mockActivityPluginBinding);

    // Assert
    assertNotNull(testBinaryMessenger.lastMethodCall);
    assertEquals(testBinaryMessenger.lastMethodCall.method, "launch");
    assertEquals(testBinaryMessenger.lastMethodCall.arguments, SHORTCUT_TYPE);
  }

  @Test
  public void onNewIntent_buildVersionUnsupported_doesNotInvokeMethod()
      throws NoSuchFieldException, IllegalAccessException {
    // Arrange
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final QuickActionsPlugin plugin = new QuickActionsPlugin();
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin);
    setBuildVersion(UNSUPPORTED_BUILD);
    final Intent mockIntent = createMockIntentWithQuickActionExtra();

    // Act
    final boolean onNewIntentReturn = plugin.onNewIntent(mockIntent);

    // Assert
    assertNull(testBinaryMessenger.lastMethodCall);
    assertFalse(onNewIntentReturn);
  }

  @Test
  public void onNewIntent_buildVersionSupported_invokesLaunchMethod()
      throws NoSuchFieldException, IllegalAccessException {
    // Arrange
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final QuickActionsPlugin plugin = new QuickActionsPlugin();
    setUpMessengerAndFlutterPluginBinding(testBinaryMessenger, plugin);
    setBuildVersion(SUPPORTED_BUILD);
    final Intent mockIntent = createMockIntentWithQuickActionExtra();

    // Act
    final boolean onNewIntentReturn = plugin.onNewIntent(mockIntent);

    // Assert
    assertNotNull(testBinaryMessenger.lastMethodCall);
    assertEquals(testBinaryMessenger.lastMethodCall.method, "launch");
    assertEquals(testBinaryMessenger.lastMethodCall.arguments, SHORTCUT_TYPE);
    assertFalse(onNewIntentReturn);
  }

  private void setUpMessengerAndFlutterPluginBinding(
      TestBinaryMessenger testBinaryMessenger, QuickActionsPlugin plugin) {
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(testBinaryMessenger);
    plugin.onAttachedToEngine(mockPluginBinding);
  }

  private Intent createMockIntentWithQuickActionExtra() {
    final Intent mockIntent = mock(Intent.class);
    when(mockIntent.hasExtra(EXTRA_ACTION)).thenReturn(true);
    when(mockIntent.getStringExtra(EXTRA_ACTION)).thenReturn(QuickActionsTest.SHORTCUT_TYPE);
    return mockIntent;
  }

  private void setBuildVersion(int buildVersion)
      throws NoSuchFieldException, IllegalAccessException {
    Field buildSdkField = Build.VERSION.class.getField("SDK_INT");
    buildSdkField.setAccessible(true);
    final Field modifiersField = Field.class.getDeclaredField("modifiers");
    modifiersField.setAccessible(true);
    modifiersField.setInt(buildSdkField, buildSdkField.getModifiers() & ~Modifier.FINAL);
    buildSdkField.set(null, buildVersion);
  }

  @After
  public void tearDown() throws NoSuchFieldException, IllegalAccessException {
    setBuildVersion(0);
  }
}
