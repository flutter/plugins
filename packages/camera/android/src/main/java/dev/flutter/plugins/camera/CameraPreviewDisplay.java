package dev.flutter.plugins.camera;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.EventChannel;

public class CameraPreviewDisplay {
  private final EventChannel imageStreamChannel;

  /* package */ CameraPreviewDisplay(@NonNull EventChannel imageStreamChannel) {
    this.imageStreamChannel = imageStreamChannel;
  }

  void startStreaming(@NonNull final ImageStreamConnection connection) {
    imageStreamChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object o, EventChannel.EventSink eventSink) {
        CameraImageStream cameraImageStream = new CameraImageStream(eventSink);
        connection.onConnectionReady(cameraImageStream);
      }

      @Override
      public void onCancel(Object o) {
        connection.onConnectionClosed();
      }
    });
  }

  interface ImageStreamConnection {
    void onConnectionReady(@NonNull CameraImageStream stream);

    void onConnectionClosed();
  }
}
