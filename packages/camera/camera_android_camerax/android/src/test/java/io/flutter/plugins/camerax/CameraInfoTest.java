// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

import androidx.camera.core.CameraInfo;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class CameraInfoTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public CameraInfo cameraInfo;
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
  public void getSensorRotationDegreesTest() {
    final CameraInfoHostApiImpl cameraInfoHostApi = new CameraInfoHostApiImpl(testInstanceManager);

    testInstanceManager.addDartCreatedInstance(cameraInfo, 1);

    cameraInfoHostApi.getSensorRotationDegrees(1L);
    verify(cameraInfo).getSensorRotationDegrees();
  }

  @Test
  public void flutterApiCreate() {
    final CameraInfoFlutterApiImpl spyFlutterApi =
        spy(new CameraInfoFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    testInstanceManager.addHostCreatedInstance(cameraInfo);
    spyFlutterApi.create(cameraInfo, reply -> {});

    final long identifier =
        Objects.requireNonNull(testInstanceManager.getIdentifierForStrongReference(cameraInfo));
    verify(spyFlutterApi).create(eq(identifier), any());
  }
}
