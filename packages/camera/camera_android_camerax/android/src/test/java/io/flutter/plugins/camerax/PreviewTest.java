// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camerax;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.reset;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.graphics.SurfaceTexture;
import android.util.Size;
import android.view.Surface;
import androidx.camera.core.Preview;
import androidx.camera.core.SurfaceRequest;
import androidx.core.util.Consumer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.ResolutionInfo;
import io.flutter.plugins.camerax.GeneratedCameraXLibrary.SystemServicesFlutterApi.Reply;
import io.flutter.view.TextureRegistry;
import java.util.concurrent.Executor;
import org.junit.After;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.MockitoJUnit;
import org.mockito.junit.MockitoRule;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class PreviewTest {
  @Rule public MockitoRule mockitoRule = MockitoJUnit.rule();

  @Mock public Preview mockPreview;
  @Mock public BinaryMessenger mockBinaryMessenger;
  @Mock public TextureRegistry mockTextureRegistry;
  @Mock public CameraXProxy mockCameraXProxy;

  InstanceManager testInstanceManager;

  @Before
  public void setUp() {
    testInstanceManager = spy(InstanceManager.open(identifier -> {}));
  }

  @After
  public void tearDown() {
    testInstanceManager.close();
  }

  @Test
  public void create_createsPreviewWithCorrectConfiguration() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final Preview.Builder mockPreviewBuilder = mock(Preview.Builder.class);
    final int targetRotation = 90;
    final int targetResolutionWidth = 10;
    final int targetResolutionHeight = 50;
    final Long previewIdentifier = 3L;
    final GeneratedCameraXLibrary.ResolutionInfo resolutionInfo =
        new GeneratedCameraXLibrary.ResolutionInfo.Builder()
            .setWidth(Long.valueOf(targetResolutionWidth))
            .setHeight(Long.valueOf(targetResolutionHeight))
            .build();

    previewHostApi.cameraXProxy = mockCameraXProxy;
    when(mockCameraXProxy.createPreviewBuilder()).thenReturn(mockPreviewBuilder);
    when(mockPreviewBuilder.build()).thenReturn(mockPreview);

    final ArgumentCaptor<Size> sizeCaptor = ArgumentCaptor.forClass(Size.class);

    previewHostApi.create(previewIdentifier, Long.valueOf(targetRotation), resolutionInfo);

    verify(mockPreviewBuilder).setTargetRotation(targetRotation);
    verify(mockPreviewBuilder).setTargetResolution(sizeCaptor.capture());
    assertEquals(sizeCaptor.getValue().getWidth(), targetResolutionWidth);
    assertEquals(sizeCaptor.getValue().getHeight(), targetResolutionHeight);
    verify(mockPreviewBuilder).build();
    verify(testInstanceManager).addDartCreatedInstance(mockPreview, previewIdentifier);
  }

  @Test
  public void setSurfaceProviderTest_createsSurfaceProviderAndReturnsTextureEntryId() {
    final PreviewHostApiImpl previewHostApi =
        spy(new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry));
    final TextureRegistry.SurfaceTextureEntry mockSurfaceTextureEntry =
        mock(TextureRegistry.SurfaceTextureEntry.class);
    final SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    final Long previewIdentifier = 5L;
    final Long surfaceTextureEntryId = 120L;

    previewHostApi.cameraXProxy = mockCameraXProxy;
    testInstanceManager.addDartCreatedInstance(mockPreview, previewIdentifier);

    when(mockTextureRegistry.createSurfaceTexture()).thenReturn(mockSurfaceTextureEntry);
    when(mockSurfaceTextureEntry.surfaceTexture()).thenReturn(mockSurfaceTexture);
    when(mockSurfaceTextureEntry.id()).thenReturn(surfaceTextureEntryId);

    final ArgumentCaptor<Preview.SurfaceProvider> surfaceProviderCaptor =
        ArgumentCaptor.forClass(Preview.SurfaceProvider.class);
    final ArgumentCaptor<Surface> surfaceCaptor = ArgumentCaptor.forClass(Surface.class);
    final ArgumentCaptor<Consumer> consumerCaptor = ArgumentCaptor.forClass(Consumer.class);

    // Test that surface provider was set and the surface texture ID was returned.
    assertEquals(previewHostApi.setSurfaceProvider(previewIdentifier), surfaceTextureEntryId);
    verify(mockPreview).setSurfaceProvider(surfaceProviderCaptor.capture());
    verify(previewHostApi).createSurfaceProvider(mockSurfaceTexture);
  }

  @Test
  public void createSurfaceProvider_createsExpectedPreviewSurfaceProvider() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final SurfaceTexture mockSurfaceTexture = mock(SurfaceTexture.class);
    final Surface mockSurface = mock(Surface.class);
    final SurfaceRequest mockSurfaceRequest = mock(SurfaceRequest.class);
    final SurfaceRequest.Result mockSurfaceRequestResult = mock(SurfaceRequest.Result.class);
    final SystemServicesFlutterApiImpl mockSystemServicesFlutterApi =
        mock(SystemServicesFlutterApiImpl.class);
    final int resolutionWidth = 200;
    final int resolutionHeight = 500;

    previewHostApi.cameraXProxy = mockCameraXProxy;
    when(mockCameraXProxy.createSurface(mockSurfaceTexture)).thenReturn(mockSurface);
    when(mockSurfaceRequest.getResolution())
        .thenReturn(new Size(resolutionWidth, resolutionHeight));
    when(mockCameraXProxy.createSystemServicesFlutterApiImpl(mockBinaryMessenger))
        .thenReturn(mockSystemServicesFlutterApi);

    final ArgumentCaptor<Surface> surfaceCaptor = ArgumentCaptor.forClass(Surface.class);
    final ArgumentCaptor<Consumer> consumerCaptor = ArgumentCaptor.forClass(Consumer.class);

    Preview.SurfaceProvider previewSurfaceProvider =
        previewHostApi.createSurfaceProvider(mockSurfaceTexture);
    previewSurfaceProvider.onSurfaceRequested(mockSurfaceRequest);

    verify(mockSurfaceTexture).setDefaultBufferSize(resolutionWidth, resolutionHeight);
    verify(mockSurfaceRequest)
        .provideSurface(surfaceCaptor.capture(), any(Executor.class), consumerCaptor.capture());

    // Test that the surface derived from the surface texture entry will be provided to the surface request.
    assertEquals(surfaceCaptor.getValue(), mockSurface);

    // Test that the Consumer used to handle surface request result releases Flutter surface texture appropriately
    // and sends camera errors appropriately.
    Consumer<SurfaceRequest.Result> capturedConsumer = consumerCaptor.getValue();

    // Case where Surface should be released.
    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_REQUEST_CANCELLED);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_REQUEST_CANCELLED);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_WILL_NOT_PROVIDE_SURFACE);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_SURFACE_USED_SUCCESSFULLY);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    reset(mockSurface);

    // Case where error must be sent.
    when(mockSurfaceRequestResult.getResultCode())
        .thenReturn(SurfaceRequest.Result.RESULT_INVALID_SURFACE);
    capturedConsumer.accept(mockSurfaceRequestResult);
    verify(mockSurface).release();
    verify(mockSystemServicesFlutterApi).sendCameraError(anyString(), any(Reply.class));
  }

  @Test
  public void releaseFlutterSurfaceTexture_makesCallToReleaseFlutterSurfaceTexture() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final TextureRegistry.SurfaceTextureEntry mockSurfaceTextureEntry =
        mock(TextureRegistry.SurfaceTextureEntry.class);

    previewHostApi.flutterSurfaceTexture = mockSurfaceTextureEntry;

    previewHostApi.releaseFlutterSurfaceTexture();
    verify(mockSurfaceTextureEntry).release();
  }

  @Test
  public void getResolutionInfo_makesCallToRetrievePreviewResolutionInfo() {
    final PreviewHostApiImpl previewHostApi =
        new PreviewHostApiImpl(mockBinaryMessenger, testInstanceManager, mockTextureRegistry);
    final androidx.camera.core.ResolutionInfo mockResolutionInfo =
        mock(androidx.camera.core.ResolutionInfo.class);
    final Long previewIdentifier = 23L;
    final int resolutionWidth = 500;
    final int resolutionHeight = 200;

    testInstanceManager.addDartCreatedInstance(mockPreview, previewIdentifier);
    when(mockPreview.getResolutionInfo()).thenReturn(mockResolutionInfo);
    when(mockResolutionInfo.getResolution())
        .thenReturn(new Size(resolutionWidth, resolutionHeight));

    ResolutionInfo resolutionInfo = previewHostApi.getResolutionInfo(previewIdentifier);
    assertEquals(resolutionInfo.getWidth(), Long.valueOf(resolutionWidth));
    assertEquals(resolutionInfo.getHeight(), Long.valueOf(resolutionHeight));
  }
}
