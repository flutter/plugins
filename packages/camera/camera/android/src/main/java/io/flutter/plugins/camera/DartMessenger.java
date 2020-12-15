package io.flutter.plugins.camera;

import android.text.TextUtils;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.Map;

class DartMessenger {
  @Nullable private MethodChannel channel;

  enum EventType {
    ERROR,
    CAMERA_CLOSING,
    INITIALIZED,
  }

  DartMessenger(BinaryMessenger messenger, long cameraId) {
    channel = new MethodChannel(messenger, "flutter.io/cameraPlugin/camera" + cameraId);
  }

  void sendCameraInitializedEvent(Integer previewWidth, Integer previewHeight) {
    this.send(
        EventType.INITIALIZED,
        new HashMap<String, Object>() {
          {
            if (previewWidth != null) put("previewWidth", previewWidth.doubleValue());
            if (previewHeight != null) put("previewHeight", previewHeight.doubleValue());
          }
        });
  }

  void sendCameraClosingEvent() {
    send(EventType.CAMERA_CLOSING);
  }

  void sendCameraErrorEvent(@Nullable String description) {
    this.send(
        EventType.ERROR,
        new HashMap<String, Object>() {
          {
            if (!TextUtils.isEmpty(description)) put("description", description);
          }
        });
  }

  void send(EventType eventType) {
    send(eventType, new HashMap<>());
  }

  void send(EventType eventType, Map<String, Object> args) {
    if (channel == null) {
      return;
    }
    channel.invokeMethod(eventType.toString().toLowerCase(), args);
  }
}
