// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.camera.types.ExposureMode;
import io.flutter.plugins.camera.types.FocusMode;
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
    INITIALIZED("initialized"),
    VIDEO_RECORDED("video_recorded");

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
      FocusMode focusMode,
      Boolean exposurePointSupported,
      Boolean focusPointSupported) {
    assert (previewWidth != null);
    assert (previewHeight != null);
    assert (exposureMode != null);
    assert (focusMode != null);
    assert (exposurePointSupported != null);
    assert (focusPointSupported != null);
    this.send(
        CameraEventType.INITIALIZED,
        new HashMap<String, Object>() {
          {
            put("previewWidth", previewWidth.doubleValue());
            put("previewHeight", previewHeight.doubleValue());
            put("exposureMode", exposureMode.toString());
            put("focusMode", focusMode.toString());
            put("exposurePointSupported", exposurePointSupported);
            put("focusPointSupported", focusPointSupported);
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

  void sendVideoRecordedEvent(String path, Integer maxVideoDuration) {
    this.send(
            CameraEventType.VIDEO_RECORDED,
            new HashMap<String, Object>() {
              {
                if (path != null) put("path", path);
                if (maxVideoDuration != null) put("maxVideoDuration", maxVideoDuration);
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
    new Handler(Looper.getMainLooper())
        .post(
            new Runnable() {
              @Override
              public void run() {
                cameraChannel.invokeMethod(eventType.method, args);
              }
            });
  }

  void send(DeviceEventType eventType) {
    send(eventType, new HashMap<>());
  }

  void send(DeviceEventType eventType, Map<String, Object> args) {
    if (deviceChannel == null) {
      return;
    }
    new Handler(Looper.getMainLooper())
        .post(
            new Runnable() {
              @Override
              public void run() {
                deviceChannel.invokeMethod(eventType.method, args);
              }
            });
  }
}
