package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;

import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import org.junit.Test;

public class CameraUtilsTest {

  @Test
  public void getDeviceOrientationFromDegrees_converts_correctly() {
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.getDeviceOrientationFromDegrees(0));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.getDeviceOrientationFromDegrees(-45));
    assertEquals(
        PlatformChannel.DeviceOrientation.PORTRAIT_UP,
        CameraUtils.getDeviceOrientationFromDegrees(44));
  }
}
