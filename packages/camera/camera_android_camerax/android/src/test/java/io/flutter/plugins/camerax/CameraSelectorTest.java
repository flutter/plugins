// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Arrays;
import java.util.List;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CameraSelectorTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public CameraSelector mockCameraSelector;
  @Mock public BinaryMessenger mockBinaryMessenger;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.open(identifier -> {});
  }

  @After
  public void tearDown() {
    testInstanceManager.close();
  }

  @Test
  public void requireLensFacingTest() {
    final CameraSelectorHostApiImpl cameraSelectorHostApi =
        new CameraSelectorHostApiImpl(mockBinaryMessenger, testInstanceManager);
    final CameraSelector.Builder mockCameraSelectorBuilder = mock(CameraSelector.Builder.class);

    cameraSelectorHostApi.cameraSelectorBuilder = mockCameraSelectorBuilder;

    when(mockCameraSelectorBuilder.requireLensFacing(1)).thenReturn(mockCameraSelectorBuilder);
    when(mockCameraSelectorBuilder.build()).thenReturn(mockCameraSelector);

    assertEquals(
        cameraSelectorHostApi.requireLensFacing(1L),
        testInstanceManager.getIdentifierForStrongReference(mockCameraSelector));
    verify(mockCameraSelectorBuilder).requireLensFacing(CameraSelector.LENS_FACING_BACK);
  }

  @Test
  public void filterTest() {
    final CameraSelectorHostApiImpl cameraSelectorHostApi =
        new CameraSelectorHostApiImpl(mockBinaryMessenger, testInstanceManager);
    final CameraInfo cameraInfo = mock(CameraInfo.class);
    final List<CameraInfo> cameraInfosForFilter = Arrays.asList(cameraInfo);
    final List<Long> cameraInfosIds = Arrays.asList(1L);

    testInstanceManager.addDartCreatedInstance(mockCameraSelector, 0);
    testInstanceManager.addDartCreatedInstance(cameraInfo, 1);

    when(mockCameraSelector.filter(cameraInfosForFilter)).thenReturn(cameraInfosForFilter);

    assertEquals(
        cameraSelectorHostApi.filter(0L, cameraInfosIds),
        Arrays.asList(testInstanceManager.getIdentifierForStrongReference(cameraInfo)));
    verify(mockCameraSelector).filter(cameraInfosForFilter);
  }

  @Test
  public void flutterApiCreateTest() {
    final CameraSelectorFlutterApiImpl spyFlutterApi =
        spy(new CameraSelectorFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    spyFlutterApi.create(mockCameraSelector, 0L, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(mockCameraSelector));
    verify(spyFlutterApi).create(eq(identifier), eq(0L), any());
  }
}
