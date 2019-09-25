// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import androidx.annotation.NonNull;

class CameraDetails {
  @NonNull
  private String name;
  private int sensorOrientation;
  @NonNull
  private String lensDirection;

  CameraDetails(
      @NonNull String name,
      int sensorOrientation,
      @NonNull String lensDirection
  ) {
    this.name = name;
    this.sensorOrientation = sensorOrientation;
    this.lensDirection = lensDirection;
  }

  @NonNull
  public String getName() {
    return name;
  }

  public int getSensorOrientation() {
    return sensorOrientation;
  }

  @NonNull
  public String getLensDirection() {
    return lensDirection;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    CameraDetails that = (CameraDetails) o;

    if (sensorOrientation != that.sensorOrientation) return false;
    if (!name.equals(that.name)) return false;
    return lensDirection.equals(that.lensDirection);
  }

  @Override
  public int hashCode() {
    int result = name.hashCode();
    result = 31 * result + sensorOrientation;
    result = 31 * result + lensDirection.hashCode();
    return result;
  }
}
