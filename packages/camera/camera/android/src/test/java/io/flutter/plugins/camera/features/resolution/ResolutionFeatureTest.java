// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.resolution;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;

import android.media.CamcorderProfile;
import io.flutter.plugins.camera.CameraProperties;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;

public class ResolutionFeatureTest {
  private static final String cameraName = "1";
  private CamcorderProfile mockProfileLow;
  private MockedStatic<CamcorderProfile> mockedStaticProfile;

  @Before
  public void before() {
    mockedStaticProfile = mockStatic(CamcorderProfile.class);
    mockProfileLow = mock(CamcorderProfile.class);
    CamcorderProfile mockProfile = mock(CamcorderProfile.class);

    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_HIGH))
        .thenReturn(true);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_2160P))
        .thenReturn(true);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_1080P))
        .thenReturn(true);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_720P))
        .thenReturn(true);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_480P))
        .thenReturn(true);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_QVGA))
        .thenReturn(true);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_LOW))
        .thenReturn(true);

    mockedStaticProfile
        .when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_HIGH))
        .thenReturn(mockProfile);
    mockedStaticProfile
        .when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_2160P))
        .thenReturn(mockProfile);
    mockedStaticProfile
        .when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_1080P))
        .thenReturn(mockProfile);
    mockedStaticProfile
        .when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P))
        .thenReturn(mockProfile);
    mockedStaticProfile
        .when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_480P))
        .thenReturn(mockProfile);
    mockedStaticProfile
        .when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_QVGA))
        .thenReturn(mockProfile);
    mockedStaticProfile
        .when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_LOW))
        .thenReturn(mockProfileLow);
  }

  @After
  public void after() {
    mockedStaticProfile.reset();
    mockedStaticProfile.close();
  }

  @Test
  public void getDebugName_shouldReturnTheNameOfTheFeature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature =
        new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    assertEquals("ResolutionFeature", resolutionFeature.getDebugName());
  }

  @Test
  public void getValue_shouldReturnInitialValueWhenNotSet() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature =
        new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    assertEquals(ResolutionPreset.max, resolutionFeature.getValue());
  }

  @Test
  public void getValue_shouldEchoSetValue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature =
        new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    resolutionFeature.setValue(ResolutionPreset.high);

    assertEquals(ResolutionPreset.high, resolutionFeature.getValue());
  }

  @Test
  public void checkIsSupport_returnsTrue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature =
        new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    assertTrue(resolutionFeature.checkIsSupported());
  }

  @Test
  public void getBestAvailableCamcorderProfileForResolutionPreset_shouldFallThrough() {
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_HIGH))
        .thenReturn(false);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_2160P))
        .thenReturn(false);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_1080P))
        .thenReturn(false);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_720P))
        .thenReturn(false);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_480P))
        .thenReturn(false);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_QVGA))
        .thenReturn(false);
    mockedStaticProfile
        .when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_LOW))
        .thenReturn(true);

    assertEquals(
        mockProfileLow,
        ResolutionFeature.getBestAvailableCamcorderProfileForResolutionPreset(
            1, ResolutionPreset.max));
  }

  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetMax() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.max);

    mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));
  }

  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetUltraHigh() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.ultraHigh);

    mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));
  }

  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetVeryHigh() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.veryHigh);

    mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));
  }

  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetHigh() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.high);

    mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));
  }

  @Test
  public void computeBestPreviewSize_shouldUse480PWhenResolutionPresetMedium() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.medium);

    mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_480P));
  }

  @Test
  public void computeBestPreviewSize_shouldUseQVGAWhenResolutionPresetLow() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.low);

    mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_QVGA));
  }
}
