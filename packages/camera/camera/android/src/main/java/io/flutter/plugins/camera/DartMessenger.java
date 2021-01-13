// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.text.TextUtils;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.camera.types.ExposureMode;
import io.flutter.plugins.camera.types.FocusMode;
import java.util.HashMap;
import java.util.Map;

class DartMessenger {
  @Nullable private MethodChannel channel;

  enum EventType {
    ERROR,
    CAMERA_CLOSING,
    INITIALIZED,
    VIDEO_RECORDED,
  }

  DartMessenger(BinaryMessenger messenger, long cameraId) {
    channel = new MethodChannel(messenger, "flutter.io/cameraPlugin/camera" + cameraId);
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
        EventType.INITIALIZED,
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

  void sendVideoRecordedEvent(String path, Integer maxVideoDuration) {
    this.send(
        EventType.VIDEO_RECORDED,
        new HashMap<String, Object>() {
          {
            if (path != null) put("path", path);
            if (maxVideoDuration != null) put("maxVideoDuration", maxVideoDuration);
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
