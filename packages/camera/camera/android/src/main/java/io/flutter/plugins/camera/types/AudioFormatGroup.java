// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.types;

import android.media.MediaRecorder;

// mirrors audio_format_group.dart
public enum AudioFormatGroup {
  aac("aac", MediaRecorder.AudioEncoder.AAC);

  private String key;
  private int encoder;

  AudioFormatGroup(String key, int encoder) {
    this.key = key;
    this.encoder = encoder;
  }

  public static AudioFormatGroup getValueForString(String key) {
    for (AudioFormatGroup value : values()) {
      if (value.key.equals(key)) return value;
    }
    return null;
  }

  public int getEncoder() {
    return encoder;
  }
}
