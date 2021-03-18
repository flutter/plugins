// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features;

import android.app.Activity;
import android.hardware.camera2.CaptureRequest;
import androidx.annotation.NonNull;
import io.flutter.plugins.camera.CameraProperties;
import io.flutter.plugins.camera.DartMessenger;
import io.flutter.plugins.camera.features.autofocus.AutoFocusFeature;
import io.flutter.plugins.camera.features.exposurelock.ExposureLockFeature;
import io.flutter.plugins.camera.features.exposureoffset.ExposureOffsetFeature;
import io.flutter.plugins.camera.features.exposurepoint.ExposurePointFeature;
import io.flutter.plugins.camera.features.flash.FlashFeature;
import io.flutter.plugins.camera.features.focuspoint.FocusPointFeature;
import io.flutter.plugins.camera.features.fpsrange.FpsRangeFeature;
import io.flutter.plugins.camera.features.noisereduction.NoiseReductionFeature;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import io.flutter.plugins.camera.features.regionboundaries.RegionBoundariesFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.plugins.camera.features.sensororientation.SensorOrientationFeature;
import io.flutter.plugins.camera.features.zoomlevel.ZoomLevelFeature;
import java.util.concurrent.Callable;

public class CameraFeatureFactoryImpl implements CameraFeatureFactory {

  @Override
  public AutoFocusFeature createAutoFocusFeature(
      @NonNull CameraProperties cameraProperties, boolean recordingVideo) {
    return new AutoFocusFeature(cameraProperties, recordingVideo);
  }

  @Override
  public ExposureLockFeature createExposureLockFeature(@NonNull CameraProperties cameraProperties) {
    return new ExposureLockFeature(cameraProperties);
  }

  @Override
  public ExposureOffsetFeature createExposureOffsetFeature(
      @NonNull CameraProperties cameraProperties) {
    return new ExposureOffsetFeature(cameraProperties);
  }

  @Override
  public FlashFeature createFlashFeature(@NonNull CameraProperties cameraProperties) {
    return new FlashFeature(cameraProperties);
  }

  @Override
  public ResolutionFeature createResolutionFeature(
      @NonNull CameraProperties cameraProperties,
      ResolutionPreset initialSetting,
      String cameraName) {
    return new ResolutionFeature(cameraProperties, initialSetting, cameraName);
  }

  @Override
  public FocusPointFeature createFocusPointFeature(
      @NonNull CameraProperties cameraProperties, Callable<CameraRegions> getCameraRegions) {
    return new FocusPointFeature(cameraProperties, getCameraRegions);
  }

  @Override
  public FpsRangeFeature createFpsRangeFeature(@NonNull CameraProperties cameraProperties) {
    return new FpsRangeFeature(cameraProperties);
  }

  @Override
  public SensorOrientationFeature createSensorOrientationFeature(
      @NonNull CameraProperties cameraProperties,
      @NonNull Activity activity,
      @NonNull DartMessenger dartMessenger) {
    return new SensorOrientationFeature(cameraProperties, activity, dartMessenger);
  }

  @Override
  public ZoomLevelFeature createZoomLevelFeature(@NonNull CameraProperties cameraProperties) {
    return new ZoomLevelFeature(cameraProperties);
  }

  @Override
  public RegionBoundariesFeature createRegionBoundariesFeature(
      @NonNull CameraProperties cameraProperties, @NonNull CaptureRequest.Builder requestBuilder) {
    return new RegionBoundariesFeature(cameraProperties, requestBuilder);
  }

  @Override
  public ExposurePointFeature createExposurePointFeature(
      @NonNull CameraProperties cameraProperties,
      @NonNull Callable<CameraRegions> getCameraRegions) {
    return new ExposurePointFeature(cameraProperties, getCameraRegions);
  }

  @Override
  public NoiseReductionFeature createNoiseReductionFeature(
      @NonNull CameraProperties cameraProperties) {
    return new NoiseReductionFeature(cameraProperties);
  }
}
