// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;

import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import org.junit.Test;

public class CameraUtilsTest {

  @Test
  public void serializeDeviceOrientation_serializes_correctly() {
    assertEquals(
        "portraitUp",
        CameraUtils.serializeDeviceOrientation(PlatformChannel.DeviceOrientation.PORTRAIT_UP));
    assertEquals(
        "portraitDown",
        CameraUtils.serializeDeviceOrientation(PlatformChannel.DeviceOrientation.PORTRAIT_DOWN));
    assertEquals(
        "landscapeLeft",
        CameraUtils.serializeDeviceOrientation(PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT));
    assertEquals(
        "landscapeRight",
        CameraUtils.serializeDeviceOrientation(PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT));
  }

  @Test(expected = UnsupportedOperationException.class)
  public void serializeDeviceOrientation_throws_for_null() {
    CameraUtils.serializeDeviceOrientation(null);
  }

  @Test
  public void deserializeDeviceOrientation_deserializes_correctly() {
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.deserializeDeviceOrientation("portraitUp"));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_DOWN,
        CameraUtils.deserializeDeviceOrientation("portraitDown"));
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT,
        CameraUtils.deserializeDeviceOrientation("landscapeLeft"));
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT,
        CameraUtils.deserializeDeviceOrientation("landscapeRight"));
  }

  @Test(expected = UnsupportedOperationException.class)
  public void deserializeDeviceOrientation_throws_for_null() {
    CameraUtils.deserializeDeviceOrientation(null);
  }

  @Test
  public void getDeviceOrientationFromDegrees_converts_correctly() {
    // Portrait UP
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.getDeviceOrientationFromDegrees(0));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.getDeviceOrientationFromDegrees(315));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.getDeviceOrientationFromDegrees(44));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.getDeviceOrientationFromDegrees(-45));
    // Portrait DOWN
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_DOWN,
        CameraUtils.getDeviceOrientationFromDegrees(180));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_DOWN,
        CameraUtils.getDeviceOrientationFromDegrees(135));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_DOWN,
        CameraUtils.getDeviceOrientationFromDegrees(224));
    // Landscape LEFT
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT,
        CameraUtils.getDeviceOrientationFromDegrees(90));
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT,
        CameraUtils.getDeviceOrientationFromDegrees(45));
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_LEFT,
        CameraUtils.getDeviceOrientationFromDegrees(134));
    // Landscape RIGHT
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT,
        CameraUtils.getDeviceOrientationFromDegrees(270));
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT,
        CameraUtils.getDeviceOrientationFromDegrees(225));
    assertEquals(
        PlatformChannel.DeviceOrientation.LANDSCAPE_RIGHT,
        CameraUtils.getDeviceOrientationFromDegrees(314));
  }
}
