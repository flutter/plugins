package dev.flutter.plugins.camera;

import org.junit.Test;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

public class ChannelCameraEventHandlerTest {

  @Test
  public void itReportsError() {
    // Setup test.
    final EventChannel.EventSink fakeSink = mock(EventChannel.EventSink.class);
    final CameraPluginProtocol.ChannelCameraEventHandler handler = new CameraPluginProtocol.ChannelCameraEventHandler();
    handler.setEventSink(fakeSink);

    final Map<String, String> expectedOutput = new HashMap<>();
    expectedOutput.put("eventType", "error");
    expectedOutput.put("errorDescription", "Fake error description");

    // Execute behavior under test.
    handler.onError("Fake error description");

    // Verify results.
    verify(fakeSink, times(1)).success(eq(expectedOutput));
  }

  @Test
  public void itReportsCameraClosed() {
    // Setup test.
    final EventChannel.EventSink fakeSink = mock(EventChannel.EventSink.class);
    final CameraPluginProtocol.ChannelCameraEventHandler handler = new CameraPluginProtocol.ChannelCameraEventHandler();
    handler.setEventSink(fakeSink);

    final Map<String, String> expectedOutput = new HashMap<>();
    expectedOutput.put("eventType", "camera_closing");

    // Execute behavior under test.
    handler.onCameraClosed();

    // Verify results.
    verify(fakeSink, times(1)).success(eq(expectedOutput));
  }

  @Test
  public void itQueuesEventsUntilSinkIsAvailable() {
    // Setup test.
    final EventChannel.EventSink fakeSink = mock(EventChannel.EventSink.class);
    final CameraPluginProtocol.ChannelCameraEventHandler handler = new CameraPluginProtocol.ChannelCameraEventHandler();

    final Map<String, String> expectedErrorOutput = new HashMap<>();
    expectedErrorOutput.put("eventType", "error");
    expectedErrorOutput.put("errorDescription", "Fake error description");

    final Map<String, String> expectedClosedOutput = new HashMap<>();
    expectedClosedOutput.put("eventType", "camera_closing");

    // Execute behavior under test.
    handler.onError("Fake error description");
    handler.onCameraClosed();
    handler.setEventSink(fakeSink);

    // Verify results.
    verify(fakeSink, times(1)).success(eq(expectedErrorOutput));
    verify(fakeSink, times(1)).success(eq(expectedClosedOutput));
  }

}
