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

import android.content.Context;
import androidx.camera.core.CameraInfo;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.test.core.app.ApplicationProvider;
import com.google.common.util.concurrent.Futures;
import com.google.common.util.concurrent.ListenableFuture;
import io.flutter.plugin.common.BinaryMessenger;
import java.util.Arrays;
import java.util.Objects;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockedStatic;
import org.mockito.Mockito;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.mockito.stubbing.Answer;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ProcessCameraProviderTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public ProcessCameraProvider processCameraProvider;
  @Mock public BinaryMessenger mockBinaryMessenger;

  InstanceManager testInstanceManager;
  private Context context;

  @Before
  public void setUp() {
    testInstanceManager = InstanceManager.open(identifier -> {});
    context = ApplicationProvider.getApplicationContext();
  }

  @After
  public void tearDown() {
    testInstanceManager.close();
  }

  @Test
  public void getInstanceTest() {
    final ProcessCameraProviderHostApiImpl processCameraProviderHostApi =
        new ProcessCameraProviderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final ListenableFuture<ProcessCameraProvider> processCameraProviderFuture =
        spy(Futures.immediateFuture(processCameraProvider));
    final GeneratedCameraXLibrary.Result<Long> mockResult =
        mock(GeneratedCameraXLibrary.Result.class);

    testInstanceManager.addDartCreatedInstance(processCameraProvider, 0);

    try (MockedStatic<ProcessCameraProvider> mockedProcessCameraProvider =
        Mockito.mockStatic(ProcessCameraProvider.class)) {
      mockedProcessCameraProvider
          .when(() -> ProcessCameraProvider.getInstance(context))
          .thenAnswer(
              (Answer<ListenableFuture<ProcessCameraProvider>>)
                  invocation -> processCameraProviderFuture);

      final ArgumentCaptor<Runnable> runnableCaptor = ArgumentCaptor.forClass(Runnable.class);

      processCameraProviderHostApi.getInstance(mockResult);
      verify(processCameraProviderFuture).addListener(runnableCaptor.capture(), any());
      runnableCaptor.getValue().run();
      verify(mockResult).success(0L);
    }
  }

  @Test
  public void getAvailableCameraInfosTest() {
    final ProcessCameraProviderHostApiImpl processCameraProviderHostApi =
        new ProcessCameraProviderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final CameraInfo mockCameraInfo = mock(CameraInfo.class);

    testInstanceManager.addDartCreatedInstance(processCameraProvider, 0);
    testInstanceManager.addDartCreatedInstance(mockCameraInfo, 1);

    when(processCameraProvider.getAvailableCameraInfos()).thenReturn(Arrays.asList(mockCameraInfo));

    assertEquals(processCameraProviderHostApi.getAvailableCameraInfos(0L), Arrays.asList(1L));
    verify(processCameraProvider).getAvailableCameraInfos();
  }

  @Test
  public void flutterApiCreateTest() {
    final ProcessCameraProviderFlutterApiImpl spyFlutterApi =
        spy(new ProcessCameraProviderFlutterApiImpl(mockBinaryMessenger, testInstanceManager));

    spyFlutterApi.create(processCameraProvider, reply -> {});

    final long identifier =
        Objects.requireNonNull(
            testInstanceManager.getIdentifierForStrongReference(processCameraProvider));
    verify(spyFlutterApi).create(eq(identifier), any());
  }
}
