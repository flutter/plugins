// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CaptureFailure;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.TotalCaptureResult;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodChannel;

// Mirrors flash_mode.dart
public enum FlashMode {
  off("off"),
  auto("auto"),
  always("always"),
  torch("torch");

  private final String strValue;

  FlashMode(String strValue) {
    this.strValue = strValue;
  }

  public static FlashMode getValueForString(String modeStr) {
    for (FlashMode value : values()) {
      if (value.strValue.equals(modeStr)) return value;
    }
    return null;
  }

  @Override
  public String toString() {
    return strValue;
  }
}