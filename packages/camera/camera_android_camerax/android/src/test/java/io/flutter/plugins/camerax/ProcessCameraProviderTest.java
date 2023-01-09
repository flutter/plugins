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
import androidx.camera.core.Camera;
import androidx.camera.core.CameraInfo;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.UseCase;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.lifecycle.LifecycleOwner;
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
  public void bindToLifecycleTest() {
    final ProcessCameraProviderHostApiImpl processCameraProviderHostApi =
        new ProcessCameraProviderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final Camera mockCamera = mock(Camera.class);
    final CameraSelector mockCameraSelector = mock(CameraSelector.class);
    final UseCase mockUseCase = mock(UseCase.class);
    UseCase[] mockUseCases = new UseCase[] {mockUseCase};

    LifecycleOwner mockLifecycleOwner = mock(LifecycleOwner.class);
    processCameraProviderHostApi.setLifecycleOwner(mockLifecycleOwner);

    testInstanceManager.addDartCreatedInstance(processCameraProvider, 0);
    testInstanceManager.addDartCreatedInstance(mockCameraSelector, 1);
    testInstanceManager.addDartCreatedInstance(mockUseCase, 2);
    testInstanceManager.addDartCreatedInstance(mockCamera, 3);

    when(processCameraProvider.bindToLifecycle(
            mockLifecycleOwner, mockCameraSelector, mockUseCases))
        .thenReturn(mockCamera);

    assertEquals(
        processCameraProviderHostApi.bindToLifecycle(0L, 1L, Arrays.asList(2L)), Long.valueOf(3));
    verify(processCameraProvider)
        .bindToLifecycle(mockLifecycleOwner, mockCameraSelector, mockUseCases);
  }

  @Test
  public void unbindTest() {
    final ProcessCameraProviderHostApiImpl processCameraProviderHostApi =
        new ProcessCameraProviderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);
    final UseCase mockUseCase = mock(UseCase.class);
    UseCase[] mockUseCases = new UseCase[] {mockUseCase};

    testInstanceManager.addDartCreatedInstance(processCameraProvider, 0);
    testInstanceManager.addDartCreatedInstance(mockUseCase, 1);

    processCameraProviderHostApi.unbind(0L, Arrays.asList(1L));
    verify(processCameraProvider).unbind(mockUseCases);
  }

  @Test
  public void unbindAllTest() {
    final ProcessCameraProviderHostApiImpl processCameraProviderHostApi =
        new ProcessCameraProviderHostApiImpl(mockBinaryMessenger, testInstanceManager, context);

    testInstanceManager.addDartCreatedInstance(processCameraProvider, 0);

    processCameraProviderHostApi.unbindAll(0L);
    verify(processCameraProvider).unbindAll();
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
