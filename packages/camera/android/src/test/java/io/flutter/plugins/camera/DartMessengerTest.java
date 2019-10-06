package io.flutter.plugins.camera;

import static junit.framework.TestCase.assertNull;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.StandardMethodCodec;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;

public class DartMessengerTest {
  /** A {@link BinaryMessenger} implementation that does nothing but save its messages. */
  private static class FakeBinaryMessenger implements BinaryMessenger {
    private BinaryMessageHandler handler;
    private final List<ByteBuffer> sentMessages = new ArrayList<>();

    @Override
    public void send(String channel, ByteBuffer message) {
      sentMessages.add(message);
    }

    @Override
    public void send(String channel, ByteBuffer message, BinaryReply callback) {
      send(channel, message);
    }

    @Override
    public void setMessageHandler(String channel, BinaryMessageHandler handler) {
      this.handler = handler;
    }

    BinaryMessageHandler getMessageHandler() {
      return handler;
    }

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
  public void setsStreamHandler() {
    assertNotNull(fakeBinaryMessenger.getMessageHandler());
  }

  @Test
  public void send_handlesNullEventSinks() {
    dartMessenger.send(DartMessenger.EventType.ERROR, "error description");

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(0, sentMessages.size());
  }

  @Test
  public void send_includesErrorDescriptions() {
    initializeEventSink();

    dartMessenger.send(DartMessenger.EventType.ERROR, "error description");

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    Map<String, String> event = decodeSentMessage(sentMessages.get(0));
    assertEquals(DartMessenger.EventType.ERROR.toString().toLowerCase(), event.get("eventType"));
    assertEquals("error description", event.get("errorDescription"));
  }

  @Test
  public void sendCameraClosingEvent() {
    initializeEventSink();

    dartMessenger.sendCameraClosingEvent();

    List<ByteBuffer> sentMessages = fakeBinaryMessenger.getMessages();
    assertEquals(1, sentMessages.size());
    Map<String, String> event = decodeSentMessage(sentMessages.get(0));
    assertEquals(
        DartMessenger.EventType.CAMERA_CLOSING.toString().toLowerCase(), event.get("eventType"));
    assertNull(event.get("errorDescription"));
  }

  private Map<String, String> decodeSentMessage(ByteBuffer sentMessage) {
    sentMessage.position(0);
    return (Map<String, String>) StandardMethodCodec.INSTANCE.decodeEnvelope(sentMessage);
  }

  private void initializeEventSink() {
    MethodCall call = new MethodCall("listen", null);
    ByteBuffer encodedCall = StandardMethodCodec.INSTANCE.encodeMethodCall(call);
    encodedCall.position(0);
    fakeBinaryMessenger.getMessageHandler().onMessage(encodedCall, reply -> {});
  }
}
