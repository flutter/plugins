// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;

import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import org.junit.Test;

public class CameraUtilsTest {

  @Test
  public void serializeDeviceOrientation_serializesCorrectly() {
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
  public void deserializeDeviceOrientation_deserializesCorrectly() {
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
  public void deserializeDeviceOrientation_throwsForNull() {
    CameraUtils.deserializeDeviceOrientation(null);
  }
}
