// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static org.junit.Assert.assertNotNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.app.Activity;
import android.hardware.camera2.CameraAccessException;
import io.flutter.plugins.camera.features.CameraFeatureFactory;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.view.TextureRegistry;
import org.junit.Test;

public class CameraTest {

  @Test
  public void should_create_camera_plugin() throws CameraAccessException {
    final Activity mockActivity = mock(Activity.class);
    final TextureRegistry.SurfaceTextureEntry mockFlutterTexture =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final CameraFeatureFactory mockCameraFeatureFactory = mock(CameraFeatureFactory.class);
    final DartMessenger mockDartMessenger = mock(DartMessenger.class);
    final CameraProperties mockCameraProperties = mock(CameraProperties.class);
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
}
