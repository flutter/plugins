// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static junit.framework.TestCase.assertNull;
import static org.junit.Assert.assertEquals;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugins.camera.types.ExposureMode;
import io.flutter.plugins.camera.types.FocusMode;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import org.junit.Before;
import org.junit.Test;

public class DartMessengerTest {
  /** A {@link BinaryMessenger} implementation that does nothing but save its messages. */
  private static class FakeBinaryMessenger implements BinaryMessenger {
    private final List<ByteBuffer> sentMessages = new ArrayList<>();

    @Override
    public void send(@NonNull String channel, ByteBuffer message) {
      sentMessages.add(message);
    }

    @Override
    public void send(@NonNull String channel, ByteBuffer message, BinaryReply callback) {
      send(channel, message);
    }

    @Override
    public void setMessageHandler(@NonNull String channel, BinaryMessageHandler handler) {}

    List<ByteBuffer> getMessages() {
      return new ArrayList<>(sentMessages);
    }
  }

  private DartMessenger dartMessenger;
  private FakeBinaryMessenger fakeBinaryMessenger;

  @Before
  public void setUp() {
    fakeBinaryMessenger = new FakeBinaryMessenger();
    dartMessenger = new DartMessenger(fakeBinaryMessenger, 0);
  }

  @Test
  public void sendCameraErrorEvent_includesErrorDescriptions() {
    dartMessenger.sendCameraErrorEvent("error description");

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    MethodCall call = decodeSentMessage(sentMessages.get(0));
    assertEquals("error", call.method);
    assertEquals("error description", call.argument("description"));
  }

  @Test
  public void sendCameraInitializedEvent_includesPreviewSize() {
    dartMessenger.sendCameraInitializedEvent(0, 0, ExposureMode.auto, FocusMode.auto, true, true);

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    MethodCall call = decodeSentMessage(sentMessages.get(0));
    assertEquals("initialized", call.method);
    assertEquals(0, (double) call.argument("previewWidth"), 0);
    assertEquals(0, (double) call.argument("previewHeight"), 0);
    assertEquals("ExposureMode auto", call.argument("exposureMode"), "auto");
    assertEquals("FocusMode continuous", call.argument("focusMode"), "auto");
    assertEquals("exposurePointSupported", call.argument("exposurePointSupported"), true);
    assertEquals("focusPointSupported", call.argument("focusPointSupported"), true);
  }

  @Test
  public void sendCameraClosingEvent() {
    dartMessenger.sendCameraClosingEvent();

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    MethodCall call = decodeSentMessage(sentMessages.get(0));
    assertEquals("camera_closing", call.method);
    assertNull(call.argument("description"));
  }

  @Test
  public void sendDeviceOrientationChangedEvent() {
    dartMessenger.sendDeviceOrientationChangeEvent(PlatformChannel.DeviceOrientation.PORTRAIT_UP);

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    MethodCall call = decodeSentMessage(sentMessages.get(0));
    assertEquals("orientation_changed", call.method);
    assertEquals(call.argument("orientation"), "portraitUp");
  }

  private MethodCall decodeSentMessage(ByteBuffer sentMessage) {
    sentMessage.position(0);

    return StandardMethodCodec.INSTANCE.decodeMethodCall(sentMessage);
  }
}
