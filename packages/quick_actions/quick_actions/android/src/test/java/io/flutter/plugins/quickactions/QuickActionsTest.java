// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.quickactions;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.StandardMethodCodec;
import java.nio.ByteBuffer;
import org.junit.Test;

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

  @Test
  public void canAttachToEngine() {
    final TestBinaryMessenger testBinaryMessenger = new TestBinaryMessenger();
    final FlutterPluginBinding mockPluginBinding = mock(FlutterPluginBinding.class);
    when(mockPluginBinding.getBinaryMessenger()).thenReturn(testBinaryMessenger);

    final QuickActionsPlugin plugin = new QuickActionsPlugin();
    plugin.onAttachedToEngine(mockPluginBinding);
  }
}
