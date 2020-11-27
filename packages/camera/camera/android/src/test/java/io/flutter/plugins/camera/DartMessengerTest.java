package io.flutter.plugins.camera;

import static junit.framework.TestCase.assertNull;
import static org.junit.Assert.assertEquals;

import androidx.annotation.NonNull;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.StandardMethodCodec;
import io.flutter.plugins.camera.DartMessenger.EventType;
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
    assertEquals(DartMessenger.EventType.ERROR.toString().toLowerCase(), call.method);
    assertEquals("error description", call.argument("description"));
  }

  @Test
  public void sendCameraInitializedEvent_includesPreviewSize() {
    dartMessenger.sendCameraInitializedEvent(0, 0);

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    MethodCall call = decodeSentMessage(sentMessages.get(0));
    assertEquals(EventType.INITIALIZED.toString().toLowerCase(), call.method);
    assertEquals(0, (double) call.argument("previewWidth"), 0);
    assertEquals(0, (double) call.argument("previewHeight"), 0);
  }

  @Test
  public void sendCameraClosingEvent() {
    dartMessenger.sendCameraClosingEvent();

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    MethodCall call = decodeSentMessage(sentMessages.get(0));
    assertEquals(DartMessenger.EventType.CAMERA_CLOSING.toString().toLowerCase(), call.method);
    assertNull(call.argument("description"));
  }

  private MethodCall decodeSentMessage(ByteBuffer sentMessage) {
    sentMessage.position(0);

    return StandardMethodCodec.INSTANCE.decodeMethodCall(sentMessage);
  }
}
