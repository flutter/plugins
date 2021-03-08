// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features;

/**
 * This is all of our available features in the camera. Used in the features map of the camera to
 * safely access feature class instances when we need to change their setting values.
 */
public enum CameraFeatures {
  autoFocus("autoFocus"),
  exposureLock("exposureLock"),
  exposureOffset("exposureOffset"),
  flash("flash"),
  resolution("resolution"),
  focusPoint("focusPoint"),
  fpsRange("fpsRange"),
  sensorOrientation("sensorOrientation"),
  zoomLevel("zoomLevel"),
  regionBoundaries("regionBoundaries"),
  exposurePoint("exposurePoint"),
  noiseReduction("noiseReduction");

  private final String strValue;

  CameraFeatures(String strValue) {
    this.strValue = strValue;
  }

  @Override
  public String toString() {
    return strValue;
  }
}
