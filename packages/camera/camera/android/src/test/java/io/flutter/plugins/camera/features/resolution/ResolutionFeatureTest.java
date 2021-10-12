// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.features.resolution;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.mockStatic;
import static org.mockito.Mockito.when;

import android.media.CamcorderProfile;
import android.media.EncoderProfiles;
import android.os.Build;
import io.flutter.plugins.camera.CameraProperties;
import java.util.List;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.MockedStatic;

public class ResolutionFeatureTest {
  private static final String cameraName = "1";
  private CamcorderProfile mockProfileLow;
  private EncoderProfiles mockProfileLow_v31;
  private MockedStatic<CamcorderProfile> mockedStaticProfile;

  @Before
  @SuppressWarnings("deprecation")
  public void before() {
    mockedStaticProfile = mockStatic(CamcorderProfile.class);
    mockProfileLow = mock(CamcorderProfile.class);
    mockProfileLow_v31 = mock(EncoderProfiles.class);
    CamcorderProfile mockProfile = mock(CamcorderProfile.class);
    EncoderProfiles mockProfile_v31 = mock(EncoderProfiles.class);
    List<EncoderProfiles.VideoProfile> mockVideoProfiles = List.of(mock(EncoderProfiles.VideoProfile.class));

    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_HIGH)).thenReturn(true);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_2160P)).thenReturn(true);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_1080P)).thenReturn(true);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_720P)).thenReturn(true);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_480P)).thenReturn(true);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_QVGA)).thenReturn(true);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_LOW)).thenReturn(true);

    if (Build.VERSION.SDK_INT >= 31) {
    mockedStaticProfile.when(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_HIGH))
        .thenReturn(mockProfile_v31);
    mockedStaticProfile.when(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_2160P))
        .thenReturn(mockProfile_v31);
    mockedStaticProfile.when(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_1080P))
        .thenReturn(mockProfile_v31);
    mockedStaticProfile.when(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_720P))
        .thenReturn(mockProfile_v31);
    mockedStaticProfile.when(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_480P))
        .thenReturn(mockProfile_v31);
    mockedStaticProfile.when(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_QVGA))
        .thenReturn(mockProfile_v31);
    mockedStaticProfile.when(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_LOW))
        .thenReturn(mockProfileLow_v31);

    when(mockProfile_v31.getVideoProfiles()).thenReturn(mockVideoProfiles);

    } else {
      mockedStaticProfile.when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_HIGH)).thenReturn(mockProfile);
      mockedStaticProfile.when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_2160P)).thenReturn(mockProfile);
      mockedStaticProfile.when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_1080P)).thenReturn(mockProfile);
      mockedStaticProfile.when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P)).thenReturn(mockProfile);
      mockedStaticProfile.when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_480P)).thenReturn(mockProfile);
      mockedStaticProfile.when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_QVGA)).thenReturn(mockProfile);
      mockedStaticProfile.when(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_LOW)).thenReturn(mockProfileLow);
    }
  }

  @After
  public void after() {
    mockedStaticProfile.reset();
    mockedStaticProfile.close();
  }

  @Test
  public void getDebugName_shouldReturnTheNameOfTheFeature() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature = new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    assertEquals("ResolutionFeature", resolutionFeature.getDebugName());
  }

  @Test
  public void getValue_shouldReturnInitialValueWhenNotSet() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature = new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    assertEquals(ResolutionPreset.max, resolutionFeature.getValue());
  }

  @Test
  public void getValue_shouldEchoSetValue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature = new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    resolutionFeature.setValue(ResolutionPreset.high);

    assertEquals(ResolutionPreset.high, resolutionFeature.getValue());
  }

  @Test
  public void checkIsSupport_returnsTrue() {
    CameraProperties mockCameraProperties = mock(CameraProperties.class);
    ResolutionFeature resolutionFeature = new ResolutionFeature(mockCameraProperties, ResolutionPreset.max, cameraName);

    assertTrue(resolutionFeature.checkIsSupported());
  }

  @SuppressWarnings("deprecation")
  @Test
  public void getBestAvailableCamcorderProfileForResolutionPreset_shouldFallThrough() {
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_HIGH)).thenReturn(false);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_2160P)).thenReturn(false);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_1080P)).thenReturn(false);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_720P)).thenReturn(false);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_480P)).thenReturn(false);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_QVGA)).thenReturn(false);
    mockedStaticProfile.when(() -> CamcorderProfile.hasProfile(1, CamcorderProfile.QUALITY_LOW)).thenReturn(true);

    if (Build.VERSION.SDK_INT >= 31) {
      assertEquals(mockProfileLow_v31,
          ResolutionFeature.getBestAvailableCamcorderProfileForResolutionPreset_v31(1, ResolutionPreset.max));
    } else {
      assertEquals(mockProfileLow,
          ResolutionFeature.getBestAvailableCamcorderProfileForResolutionPreset(1, ResolutionPreset.max));
    }
  }

  @SuppressWarnings("deprecation")
  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetMax() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.max);

    if (Build.VERSION.SDK_INT >= 31) {
      mockedStaticProfile.verify(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_720P));

    } else {
      mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));

    }
  }

  @SuppressWarnings("deprecation")
  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetUltraHigh() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.ultraHigh);

    if (Build.VERSION.SDK_INT >= 31) {
      mockedStaticProfile.verify(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_720P));
    } else {
      mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));
    }
  }

  @SuppressWarnings("deprecation")
  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetVeryHigh() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.veryHigh);

    if (Build.VERSION.SDK_INT >= 31) {
      mockedStaticProfile.verify(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_720P));

    } else {
      mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));

    }
  }

  @SuppressWarnings("deprecation")
  @Test
  public void computeBestPreviewSize_shouldUse720PWhenResolutionPresetHigh() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.high);

    if (Build.VERSION.SDK_INT >= 31) {
      mockedStaticProfile.verify(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_720P));
    } else {
      mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_720P));

    }
  }

  @SuppressWarnings("deprecation")
  @Test
  public void computeBestPreviewSize_shouldUse480PWhenResolutionPresetMedium() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.medium);

    if (Build.VERSION.SDK_INT >= 31) {
      mockedStaticProfile.verify(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_480P));
    } else {
      mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_480P));

    }
  }

  @SuppressWarnings("deprecation")
  @Test
  public void computeBestPreviewSize_shouldUseQVGAWhenResolutionPresetLow() {
    ResolutionFeature.computeBestPreviewSize(1, ResolutionPreset.low);

    if (Build.VERSION.SDK_INT >= 31) {
      mockedStaticProfile.verify(() -> CamcorderProfile.getAll("1", CamcorderProfile.QUALITY_QVGA));
    } else {
      mockedStaticProfile.verify(() -> CamcorderProfile.get(1, CamcorderProfile.QUALITY_QVGA));

    }
  }
}
