// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.noisereduction;

/** Only supports fast mode for now. */
public enum NoiseReductionMode {
  off("off"),
  fast("fast"),
  highQuality("highQuality"),
  minimal("minimal"),
  zeroShutterLag("zeroShutterLag");

  private final String strValue;

  NoiseReductionMode(String strValue) {
    this.strValue = strValue;
  }

  public static NoiseReductionMode getValueForString(String modeStr) {
    for (NoiseReductionMode value : values()) {
      if (value.strValue.equals(modeStr)) return value;
    }
    return null;
  }

  @Override
  public String toString() {
    return strValue;
  }
}
