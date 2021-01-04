package io.flutter.plugins.camera;

import android.text.TextUtils;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.camera.types.ExposureMode;
import java.util.HashMap;
import java.util.Map;

class DartMessenger {
  @Nullable private MethodChannel cameraChannel;
  @Nullable private MethodChannel deviceChannel;

  enum DeviceEventType {
    ORIENTATION_CHANGED("orientation_changed");
    private final String method;

    DeviceEventType(String method) {
      this.method = method;
    }
  }

  enum CameraEventType {
    ERROR("error"),
    CLOSING("camera_closing"),
    INITIALIZED("initialized");

    private final String method;

    CameraEventType(String method) {
      this.method = method;
    }
  }

  DartMessenger(BinaryMessenger messenger, long cameraId) {
    cameraChannel = new MethodChannel(messenger, "flutter.io/cameraPlugin/camera" + cameraId);
    deviceChannel = new MethodChannel(messenger, "flutter.io/cameraPlugin/device");
  }

  void sendDeviceOrientationChangeEvent(PlatformChannel.DeviceOrientation orientation) {
    assert (orientation != null);
    this.send(
        DeviceEventType.ORIENTATION_CHANGED,
        new HashMap<String, Object>() {
          {
            put("orientation", CameraUtils.serializeDeviceOrientation(orientation));
          }
        });
  }

  void sendCameraInitializedEvent(
      Integer previewWidth,
      Integer previewHeight,
      ExposureMode exposureMode,
      Boolean exposurePointSupported) {
    assert (previewWidth != null);
    assert (previewHeight != null);
    assert (exposureMode != null);
    assert (exposurePointSupported != null);
    this.send(
        CameraEventType.INITIALIZED,
        new HashMap<String, Object>() {
          {
            put("previewWidth", previewWidth.doubleValue());
            put("previewHeight", previewHeight.doubleValue());
            put("exposureMode", exposureMode.toString());
            put("exposurePointSupported", exposurePointSupported);
          }
        });
  }

  void sendCameraClosingEvent() {
    send(CameraEventType.CLOSING);
  }

  void sendCameraErrorEvent(@Nullable String description) {
    this.send(
        CameraEventType.ERROR,
        new HashMap<String, Object>() {
          {
            if (!TextUtils.isEmpty(description)) put("description", description);
          }
        });
  }

  void send(CameraEventType eventType) {
    send(eventType, new HashMap<>());
  }

  void send(CameraEventType eventType, Map<String, Object> args) {
    if (cameraChannel == null) {
      return;
    }
    cameraChannel.invokeMethod(eventType.method, args);
  }

  void send(DeviceEventType eventType) {
    send(eventType, new HashMap<>());
  }

  void send(DeviceEventType eventType, Map<String, Object> args) {
    if (deviceChannel == null) {
      return;
    }
    deviceChannel.invokeMethod(eventType.method, args);
  }
}
