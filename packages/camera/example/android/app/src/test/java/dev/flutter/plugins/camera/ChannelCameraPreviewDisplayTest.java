package dev.flutter.plugins.camera;

import org.junit.Test;
import org.mockito.ArgumentCaptor;

import dev.flutter.plugins.camera.CameraPluginProtocol.ChannelCameraPreviewDisplay;
import io.flutter.plugin.common.EventChannel;

import static org.mockito.Matchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

public class ChannelCameraPreviewDisplayTest {

  @Test
  public void itNotifiesImageStreamConnectionWhenItsReadyToStreamImages() {
    final EventChannel fakeEventChannel = mock(EventChannel.class);
    final EventChannel.EventSink fakeEventSink = mock(EventChannel.EventSink.class);
    final ChannelCameraPreviewDisplay display = new ChannelCameraPreviewDisplay(fakeEventChannel);
    final CameraPreviewDisplay.ImageStreamConnection fakeImageStreamConnection = mock(CameraPreviewDisplay.ImageStreamConnection.class);

    display.startStreaming(fakeImageStreamConnection);

    ArgumentCaptor<EventChannel.StreamHandler> streamCaptor = ArgumentCaptor.forClass(EventChannel.StreamHandler.class);
    verify(fakeEventChannel, times(1)).setStreamHandler(streamCaptor.capture());
    EventChannel.StreamHandler streamHandler = streamCaptor.getValue();

    streamHandler.onListen(null, fakeEventSink);
    verify(fakeImageStreamConnection, times(1)).onConnectionReady(any(CameraPluginProtocol.ChannelCameraImageStream.class));
  }

  @Test
  public void itClosesImageStreamConnectionWhenChannelCloses() {
    final EventChannel fakeEventChannel = mock(EventChannel.class);
    final EventChannel.EventSink fakeEventSink = mock(EventChannel.EventSink.class);
    final ChannelCameraPreviewDisplay display = new ChannelCameraPreviewDisplay(fakeEventChannel);
    final CameraPreviewDisplay.ImageStreamConnection fakeImageStreamConnection = mock(CameraPreviewDisplay.ImageStreamConnection.class);

    display.startStreaming(fakeImageStreamConnection);

    ArgumentCaptor<EventChannel.StreamHandler> streamCaptor = ArgumentCaptor.forClass(EventChannel.StreamHandler.class);
    verify(fakeEventChannel, times(1)).setStreamHandler(streamCaptor.capture());
    EventChannel.StreamHandler streamHandler = streamCaptor.getValue();

    streamHandler.onListen(null, fakeEventSink);
    streamHandler.onCancel(null);

    verify(fakeImageStreamConnection, times(1)).onConnectionClosed();
  }

}
