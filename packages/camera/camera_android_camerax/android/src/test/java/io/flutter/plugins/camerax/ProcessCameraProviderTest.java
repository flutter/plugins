// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;

import android.content.Context;
import androidx.camera.lifecycle.ProcessCameraProvider;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;

public class ProcessCameraProviderTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ProcessCameraProvider processCameraProvider;
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
  public void getInstanceTest() {
    final Context mockContext = mock(Context.class);
    final GeneratedCameraXLibrary.Result<Long> mockResult =
        mock(GeneratedCameraXLibrary.Result.class);
    final boolean[] getInstanceCalled = {false};
    final ProcessCameraProviderHostApiImpl processCameraProviderHostApi =
        new ProcessCameraProviderHostApiImpl(
            mockBinaryMessenger, testInstanceManager, mockContext) {
          @Override
          public void getInstance(GeneratedCameraXLibrary.Result<Long> result) {
            getInstanceCalled[0] = true;
          }
        };

    processCameraProviderHostApi.getInstance(mockResult);
    assertTrue(getInstanceCalled[0]);
  }

  @Test
  public void getAvailableCameraInfosTest() {
    final Context mockContext = mock(Context.class);
    final ProcessCameraProviderHostApiImpl processCameraProviderHostApi =
        new ProcessCameraProviderHostApiImpl(mockBinaryMessenger, testInstanceManager, mockContext);

    testInstanceManager.addDartCreatedInstance(processCameraProvider, 0);

    processCameraProviderHostApi.getAvailableCameraInfos(0L);
    verify(processCameraProvider).getAvailableCameraInfos();
  }

  @Test
  public void flutterApiCreateTest() {
    final ProcessCameraProviderFlutterApiImpl spyFlutterApi =
        spy(new ProcessCameraProviderFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    testInstanceManager.addHostCreatedInstance(processCameraProvider);
    spyFlutterApi.create(processCameraProvider, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(processCameraProvider));
    verify(spyFlutterApi).create(eq(identifier), any());
  }
}
