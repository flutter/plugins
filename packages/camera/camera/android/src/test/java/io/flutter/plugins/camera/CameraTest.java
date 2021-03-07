package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.hardware.camera2.CameraAccessException;
import android.media.CamcorderProfile;
import io.flutter.plugins.camera.types.ResolutionPreset;
import io.flutter.view.TextureRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.MockedStatic;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class CameraTest {

  @Test
  public void should_create_camera_plugin() throws CameraAccessException {
    final Activity mockActivity = mock(Activity.class);
    final TextureRegistry.SurfaceTextureEntry flutterTextureMock =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final DartMessenger dartMessengerMock = mock(DartMessenger.class);
    final String cameraName = "1";
    final ResolutionPreset resolutionPreset = ResolutionPreset.high;
    final boolean enableAudio = false;

    // Mocks
    final CamcorderProfile mockCamcorderProfile = mock(CamcorderProfile.class);
    final CameraProperties mockCameraProperties = mock(CameraProperties.class);
    final DeviceOrientationManager mockDeviceOrientationManager =
        mock(DeviceOrientationManager.class);

    try (MockedStatic<CameraUtils> mockCameraUtils = mockStatic(CameraUtils.class)) {
      mockCameraUtils
          .when(
              () ->
                  CameraUtils.getBestAvailableCamcorderProfileForResolutionPreset(
                      cameraName, resolutionPreset))
          .thenReturn(mockCamcorderProfile);

      mockCamcorderProfile.videoFrameHeight = 480;
      mockCamcorderProfile.videoFrameWidth = 640;
      when(mockCameraProperties.getLensFacing()).thenReturn(0);
      when(mockCameraProperties.getSensorOrientation()).thenReturn(0);
      when(mockCameraProperties.getCameraName()).thenReturn(cameraName);
      when(mockCameraProperties.getControlAutoFocusAvailableModes())
          .thenReturn(new int[] {0, 1, 2});
      when(mockCameraProperties.getControlAutoExposureAvailableTargetFpsRanges()).thenReturn(null);

      Camera camera = null;
      try (MockedStatic<DeviceOrientationManager> mockOrientationManagerFactory =
          mockStatic(DeviceOrientationManager.class)) {
        mockOrientationManagerFactory
            .when(() -> DeviceOrientationManager.create(mockActivity, dartMessengerMock, true, 0))
            .thenReturn(mockDeviceOrientationManager);

        camera =
            new Camera(
                mockActivity,
                flutterTextureMock,
                dartMessengerMock,
                mockCameraProperties,
                resolutionPreset,
                enableAudio);
      }

      assertNotNull("should create a camera", camera);
      assertEquals(
          "should be in preview state from the start",
          camera.getState(),
          CameraState.STATE_PREVIEW);
      verify(mockDeviceOrientationManager, times(1)).start();
    }
  }
}
