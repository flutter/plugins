// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.graphics.Rect;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CaptureRequest.Builder;
import android.media.CamcorderProfile;
import android.util.Size;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.camera.features.CameraFeatureFactory;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.autofocus.AutoFocusFeature;
import io.flutter.plugins.camera.features.exposurelock.ExposureLockFeature;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import io.flutter.plugins.camera.features.exposureoffset.ExposureOffsetFeature;
import io.flutter.plugins.camera.features.exposureoffset.ExposureOffsetValue;
import io.flutter.plugins.camera.features.exposurepoint.ExposurePointFeature;
import io.flutter.plugins.camera.features.flash.FlashFeature;
import io.flutter.plugins.camera.features.flash.FlashMode;
import io.flutter.plugins.camera.features.focuspoint.FocusPointFeature;
import io.flutter.plugins.camera.features.fpsrange.FpsRangeFeature;
import io.flutter.plugins.camera.features.noisereduction.NoiseReductionFeature;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import io.flutter.plugins.camera.features.regionboundaries.RegionBoundariesFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.plugins.camera.features.sensororientation.DeviceOrientationManager;
import io.flutter.plugins.camera.features.sensororientation.SensorOrientationFeature;
import io.flutter.plugins.camera.features.zoomlevel.CameraZoom;
import io.flutter.plugins.camera.features.zoomlevel.ZoomLevelFeature;
import io.flutter.view.TextureRegistry;
import java.util.concurrent.Callable;
import org.junit.Before;
import org.junit.Test;

public class CameraTest {
  private CameraProperties mockCameraProperties;
  private CameraFeatureFactory mockCameraFeatureFactory;
  private DartMessenger mockDartMessenger;
  private Camera camera;

  @Before
  public void before() {
    mockCameraProperties = mock(CameraProperties.class);
    mockCameraFeatureFactory = new TestCameraFeatureFactory();
    mockDartMessenger = mock(DartMessenger.class);

    final Activity mockActivity = mock(Activity.class);
    final TextureRegistry.SurfaceTextureEntry mockFlutterTexture =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final String cameraName = "1";
    final ResolutionPreset resolutionPreset = ResolutionPreset.high;
    final boolean enableAudio = false;

    when(mockCameraProperties.getCameraName()).thenReturn(cameraName);

    camera =
        new Camera(
            mockActivity,
            mockFlutterTexture,
            mockCameraFeatureFactory,
            mockDartMessenger,
            mockCameraProperties,
            resolutionPreset,
            enableAudio);
  }

  @Test
  public void should_create_camera_plugin_and_set_all_features() {
    final Activity mockActivity = mock(Activity.class);
    final TextureRegistry.SurfaceTextureEntry mockFlutterTexture =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final CameraFeatureFactory mockCameraFeatureFactory = mock(CameraFeatureFactory.class);
    final String cameraName = "1";
    final ResolutionPreset resolutionPreset = ResolutionPreset.high;
    final boolean enableAudio = false;

    when(mockCameraProperties.getCameraName()).thenReturn(cameraName);

    Camera camera =
        new Camera(
            mockActivity,
            mockFlutterTexture,
            mockCameraFeatureFactory,
            mockDartMessenger,
            mockCameraProperties,
            resolutionPreset,
            enableAudio);

    verify(mockCameraFeatureFactory, times(1)).createAutoFocusFeature(mockCameraProperties, false);
    verify(mockCameraFeatureFactory, times(1)).createExposureLockFeature(mockCameraProperties);
    verify(mockCameraFeatureFactory, times(1))
        .createExposurePointFeature(eq(mockCameraProperties), any());
    verify(mockCameraFeatureFactory, times(1)).createExposureOffsetFeature(mockCameraProperties);
    verify(mockCameraFeatureFactory, times(1)).createFlashFeature(mockCameraProperties);
    verify(mockCameraFeatureFactory, times(1))
        .createFocusPointFeature(eq(mockCameraProperties), any());
    verify(mockCameraFeatureFactory, times(1)).createFpsRangeFeature(mockCameraProperties);
    verify(mockCameraFeatureFactory, times(1)).createNoiseReductionFeature(mockCameraProperties);
    verify(mockCameraFeatureFactory, times(1))
        .createResolutionFeature(mockCameraProperties, resolutionPreset, cameraName);
    verify(mockCameraFeatureFactory, times(1))
        .createSensorOrientationFeature(mockCameraProperties, mockActivity, mockDartMessenger);
    verify(mockCameraFeatureFactory, times(1)).createZoomLevelFeature(mockCameraProperties);
    verify(mockCameraFeatureFactory, never()).createRegionBoundariesFeature(any(), any());
    assertNotNull("should create a camera", camera);
  }

  @Test
  public void getCaptureSize() {
    ResolutionFeature mockResolutionFeature =
        mockCameraFeatureFactory.createResolutionFeature(mockCameraProperties, null, null);
    Size mockSize = mock(Size.class);

    when(mockResolutionFeature.getCaptureSize()).thenReturn(mockSize);

    Size actualSize = camera.getCaptureSize();

    verify(mockResolutionFeature, times(1)).getCaptureSize();
    assertEquals(mockSize, actualSize);
  }

  @Test
  public void getPreviewSize() {
    ResolutionFeature mockResolutionFeature =
        mockCameraFeatureFactory.createResolutionFeature(mockCameraProperties, null, null);
    Size mockSize = mock(Size.class);

    when(mockResolutionFeature.getPreviewSize()).thenReturn(mockSize);

    Size actualSize = camera.getPreviewSize();

    verify(mockResolutionFeature, times(1)).getPreviewSize();
    assertEquals(mockSize, actualSize);
  }

  @Test
  public void getDeviceOrientationManager() {
    SensorOrientationFeature mockSensorOrientationFeature =
        mockCameraFeatureFactory.createSensorOrientationFeature(mockCameraProperties, null, null);
    DeviceOrientationManager mockDeviceOrientationManager = mock(DeviceOrientationManager.class);

    when(mockSensorOrientationFeature.getDeviceOrientationManager())
        .thenReturn(mockDeviceOrientationManager);

    DeviceOrientationManager actualDeviceOrientationManager = camera.getDeviceOrientationManager();

    verify(mockSensorOrientationFeature, times(1)).getDeviceOrientationManager();
    assertEquals(mockDeviceOrientationManager, actualDeviceOrientationManager);
  }

  @Test
  public void getExposureOffsetStepSize() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    double stepSize = 2.3;

    when(mockExposureOffsetFeature.getExposureOffsetStepSize()).thenReturn(stepSize);

    double actualSize = camera.getExposureOffsetStepSize();

    verify(mockExposureOffsetFeature, times(1)).getExposureOffsetStepSize();
    assertEquals(stepSize, actualSize, 0);
  }

  @Test
  public void getMaxExposureOffset() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    double expectedMaxOffset = 42.0;
    ExposureOffsetValue exposureOffsetValue = new ExposureOffsetValue(21.5, 42.0, 0.0);

    when(mockExposureOffsetFeature.getValue()).thenReturn(exposureOffsetValue);

    double actualMaxOffset = camera.getMaxExposureOffset();

    verify(mockExposureOffsetFeature, times(1)).getValue();
    assertEquals(expectedMaxOffset, actualMaxOffset, 0);
  }

  @Test
  public void getMinExposureOffset() {
    ExposureOffsetFeature mockExposureOffsetFeature =
        mockCameraFeatureFactory.createExposureOffsetFeature(mockCameraProperties);
    double expectedMinOffset = 21.5;
    ExposureOffsetValue exposureOffsetValue = new ExposureOffsetValue(21.5, 42.0, 0.0);

    when(mockExposureOffsetFeature.getValue()).thenReturn(exposureOffsetValue);

    double actualMinOffset = camera.getMinExposureOffset();

    verify(mockExposureOffsetFeature, times(1)).getValue();
    assertEquals(expectedMinOffset, actualMinOffset, 0);
  }

  @Test
  public void getMaxZoomLevel() {
    ZoomLevelFeature mockZoomLevelFeature =
        mockCameraFeatureFactory.createZoomLevelFeature(mockCameraProperties);
    Rect sensorRect = mock(Rect.class);
    float expectedMaxZoomLevel = 4.2f;
    CameraZoom cameraZoom = CameraZoom.create(sensorRect, expectedMaxZoomLevel);

    when(mockZoomLevelFeature.getCameraZoom()).thenReturn(cameraZoom);

    float actualMaxZoomLevel = camera.getMaxZoomLevel();

    verify(mockZoomLevelFeature, times(1)).getCameraZoom();
    assertEquals(expectedMaxZoomLevel, actualMaxZoomLevel, 0);
  }

  @Test
  public void getMinZoomLevel() {
    float expectedMinZoomLevel = CameraZoom.DEFAULT_ZOOM_FACTOR;
    float actualMinZoomLevel = camera.getMinZoomLevel();

    assertEquals(expectedMinZoomLevel, actualMinZoomLevel, 0);
  }

  @Test
  public void getRecordingProfile() {
    ResolutionFeature mockResolutionFeature =
        mockCameraFeatureFactory.createResolutionFeature(mockCameraProperties, null, null);
    CamcorderProfile mockCamcorderProfile = mock(CamcorderProfile.class);

    when(mockResolutionFeature.getRecordingProfile()).thenReturn(mockCamcorderProfile);

    CamcorderProfile actualRecordingProfile = camera.getRecordingProfile();

    verify(mockResolutionFeature, times(1)).getRecordingProfile();
    assertEquals(mockCamcorderProfile, actualRecordingProfile);
  }

  @Test
  public void setExposureMode_Should_update_exposure_lock_feature_and_update_builder() {
    ExposureLockFeature mockExposureLockFeature =
        mockCameraFeatureFactory.createExposureLockFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    ExposureMode exposureMode = ExposureMode.locked;

    camera.setExposureMode(mockResult, exposureMode);

    verify(mockExposureLockFeature, times(1)).setValue(exposureMode);
    verify(mockExposureLockFeature, times(1)).updateBuilder(null);
  }

  @Test
  public void setExposurePoint_Should_update_exposure_point_feature_and_update_builder() {
    ExposurePointFeature mockExposurePointFeature =
        mockCameraFeatureFactory.createExposurePointFeature(mockCameraProperties, null);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);

    camera.setExposurePoint(mockResult, point);

    verify(mockExposurePointFeature, times(1)).setValue(point);
    verify(mockExposurePointFeature, times(1)).updateBuilder(null);
  }

  @Test
  public void setFlashMode_Should_update_flash_feature_and_update_builder() {
    FlashFeature mockFlashFeature =
        mockCameraFeatureFactory.createFlashFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    FlashMode flashMode = FlashMode.always;

    camera.setFlashMode(mockResult, flashMode);

    verify(mockFlashFeature, times(1)).setValue(flashMode);
    verify(mockFlashFeature, times(1)).updateBuilder(null);
  }

  @Test
  public void setFocusPoint_Should_update_focus_point_feature_and_update_builder() {
    FocusPointFeature mockFocusPointFeature =
        mockCameraFeatureFactory.createFocusPointFeature(mockCameraProperties, null);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Point point = new Point(42d, 42d);

    camera.setFocusPoint(mockResult, point);

    verify(mockFocusPointFeature, times(1)).setValue(point);
    verify(mockFocusPointFeature, times(1)).updateBuilder(null);
  }

  @Test
  public void setZoomLevel_Should_update_zoom_level_feature_and_update_builder()
      throws CameraAccessException {
    ZoomLevelFeature mockZoomLevelFeature =
        mockCameraFeatureFactory.createZoomLevelFeature(mockCameraProperties);
    MethodChannel.Result mockResult = mock(MethodChannel.Result.class);
    Rect sensorRect = mock(Rect.class);
    CameraZoom cameraZoom = CameraZoom.create(sensorRect, 5.0f);
    float zoomLevel = 4.2f;

    when(mockZoomLevelFeature.getCameraZoom()).thenReturn(cameraZoom);

    camera.setZoomLevel(mockResult, zoomLevel);

    verify(mockZoomLevelFeature, times(1)).setValue(zoomLevel);
    verify(mockZoomLevelFeature, times(1)).updateBuilder(null);
  }

  private static class TestCameraFeatureFactory implements CameraFeatureFactory {
    private final AutoFocusFeature mockAutoFocusFeature;
    private final ExposureLockFeature mockExposureLockFeature;
    private final ExposureOffsetFeature mockExposureOffsetFeature;
    private final ExposurePointFeature mockExposurePointFeature;
    private final FlashFeature mockFlashFeature;
    private final FocusPointFeature mockFocusPointFeature;
    private final FpsRangeFeature mockFpsRangeFeature;
    private final NoiseReductionFeature mockNoiseReductionFeature;
    private final RegionBoundariesFeature mockRegionBoundariesFeature;
    private final ResolutionFeature mockResolutionFeature;
    private final SensorOrientationFeature mockSensorOrientationFeature;
    private final ZoomLevelFeature mockZoomLevelFeature;

    public TestCameraFeatureFactory() {
      this.mockAutoFocusFeature = mock(AutoFocusFeature.class);
      this.mockExposureLockFeature = mock(ExposureLockFeature.class);
      this.mockExposureOffsetFeature = mock(ExposureOffsetFeature.class);
      this.mockExposurePointFeature = mock(ExposurePointFeature.class);
      this.mockFlashFeature = mock(FlashFeature.class);
      this.mockFocusPointFeature = mock(FocusPointFeature.class);
      this.mockFpsRangeFeature = mock(FpsRangeFeature.class);
      this.mockNoiseReductionFeature = mock(NoiseReductionFeature.class);
      this.mockRegionBoundariesFeature = mock(RegionBoundariesFeature.class);
      this.mockResolutionFeature = mock(ResolutionFeature.class);
      this.mockSensorOrientationFeature = mock(SensorOrientationFeature.class);
      this.mockZoomLevelFeature = mock(ZoomLevelFeature.class);
    }

    @Override
    public AutoFocusFeature createAutoFocusFeature(
        @NonNull CameraProperties cameraProperties, boolean recordingVideo) {
      return mockAutoFocusFeature;
    }

    @Override
    public ExposureLockFeature createExposureLockFeature(
        @NonNull CameraProperties cameraProperties) {
      return mockExposureLockFeature;
    }

    @Override
    public ExposureOffsetFeature createExposureOffsetFeature(
        @NonNull CameraProperties cameraProperties) {
      return mockExposureOffsetFeature;
    }

    @Override
    public FlashFeature createFlashFeature(@NonNull CameraProperties cameraProperties) {
      return mockFlashFeature;
    }

    @Override
    public ResolutionFeature createResolutionFeature(
        @NonNull CameraProperties cameraProperties,
        ResolutionPreset initialSetting,
        String cameraName) {
      return mockResolutionFeature;
    }

    @Override
    public FocusPointFeature createFocusPointFeature(
        @NonNull CameraProperties cameraProperties, Callable<CameraRegions> getCameraRegions) {
      return mockFocusPointFeature;
    }

    @Override
    public FpsRangeFeature createFpsRangeFeature(@NonNull CameraProperties cameraProperties) {
      return mockFpsRangeFeature;
    }

    @Override
    public SensorOrientationFeature createSensorOrientationFeature(
        @NonNull CameraProperties cameraProperties,
        @NonNull Activity activity,
        @NonNull DartMessenger dartMessenger) {
      return mockSensorOrientationFeature;
    }

    @Override
    public ZoomLevelFeature createZoomLevelFeature(@NonNull CameraProperties cameraProperties) {
      return mockZoomLevelFeature;
    }

    @Override
    public RegionBoundariesFeature createRegionBoundariesFeature(
        @NonNull CameraProperties cameraProperties, @NonNull Builder requestBuilder) {
      return mockRegionBoundariesFeature;
    }

    @Override
    public ExposurePointFeature createExposurePointFeature(
        @NonNull CameraProperties cameraProperties,
        @NonNull Callable<CameraRegions> getCameraRegions) {
      return mockExposurePointFeature;
    }

    @Override
    public NoiseReductionFeature createNoiseReductionFeature(
        @NonNull CameraProperties cameraProperties) {
      return mockNoiseReductionFeature;
    }
  }
}
