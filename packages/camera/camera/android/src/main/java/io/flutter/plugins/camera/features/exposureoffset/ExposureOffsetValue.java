// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.exposureoffset;

/**
 * This represents the exposure offset value. It holds the minimum and maximum values, as well as
 * the current setting value.
 */
public class ExposureOffsetValue {
  public final double min;
  public final double max;
  public final double value;

  public ExposureOffsetValue(double min, double max, double value) {
    this.min = min;
    this.max = max;
    this.value = value;
  }

  public ExposureOffsetValue(double value) {
    this(0, 0, value);
  }
}
