// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.graphics.ImageFormat;
import android.media.Image;
import android.media.ImageReader;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.camera.types.CameraCaptureProperties;
import java.nio.ByteBuffer;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageStreamReaderTest {
  private ImageStreamReader imageStreamReader;
  private ImageStreamReaderUtils mockImageStreamReaderUtils;

  @Before
  public void setUp() {
    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);

    this.mockImageStreamReaderUtils = mockImageStreamReaderUtils;
    this.imageStreamReader =
            new ImageStreamReader(mockImageReader, ImageFormat.YUV_420_888, this.mockImageStreamReaderUtils);
  }

  @Test
  public void computeStreamImageFormat_forNv21() {
    int result = ImageStreamReader.computeStreamImageFormat(ImageFormat.NV21);
    Assert.assertEquals(ImageFormat.YUV_420_888, result);
  }

  @Test
  public void computeStreamImageFormat_forJpeg() {
    int result = ImageStreamReader.computeStreamImageFormat(ImageFormat.JPEG);
    Assert.assertEquals(ImageFormat.JPEG, result);
  }


  @Test
  public void onImageAvailable_doesNotTryToFixConvertForNonNv21Format() {
    // Mock JPEG image
    int imageFormat = ImageFormat.JPEG;
    Image mockImage = mock(Image.class);
    when(mockImage.getFormat()).thenReturn(imageFormat);

    // Mock plane. JPEG images have only one plane
    Image.Plane plane0 = mock(Image.Plane.class);
    when(plane0.getBuffer()).thenReturn(ByteBuffer.allocate(497950));
    when(plane0.getRowStride()).thenReturn(0);
    when(plane0.getPixelStride()).thenReturn(0);
    Image.Plane[] planes = {plane0};
    when(mockImage.getPlanes()).thenReturn(planes);

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);
    imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

    verify(mockImageStreamReaderUtils, never()).yuv420ThreePlanesToNV21(any(), anyInt(), anyInt());
  }

  @Test
  public void onImageAvailable_doesConvertPlanesForNv21() {
    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);

    // Make sure we setup the correct dartImageFormat
    imageStreamReader =
            new ImageStreamReader(mockImageReader, ImageFormat.NV21, mockImageStreamReaderUtils);

    // Mock YUV image
    Image mockImage = mock(Image.class);
    when(mockImage.getWidth()).thenReturn(1280);
    when(mockImage.getHeight()).thenReturn(720);
    when(mockImage.getFormat()).thenReturn(ImageFormat.YUV_420_888);

    // Mock planes. YUV images have 3 planes (Y, U, V).
    Image.Plane planeY = mock(Image.Plane.class);
    Image.Plane planeU = mock(Image.Plane.class);
    Image.Plane planeV = mock(Image.Plane.class);

    // Y plane is width*height
    // Row stride is generally == width but when there is padding it will
    // be larger. The numbers in this example are from a Vivo V2135 on 'high'
    // setting (1280x720).
    when(planeY.getBuffer()).thenReturn(ByteBuffer.allocate(1105664));
    when(planeY.getRowStride()).thenReturn(1536);
    when(planeY.getPixelStride()).thenReturn(1);

    // U and V planes are always the same sizes/values.
    // https://developer.android.com/reference/android/graphics/ImageFormat#YUV_420_888
    when(planeU.getBuffer()).thenReturn(ByteBuffer.allocate(552703));
    when(planeV.getBuffer()).thenReturn(ByteBuffer.allocate(552703));
    when(planeU.getRowStride()).thenReturn(1536);
    when(planeV.getRowStride()).thenReturn(1536);
    when(planeU.getPixelStride()).thenReturn(2);
    when(planeV.getPixelStride()).thenReturn(2);

    // Add planes to image
    Image.Plane[] planes = {planeY, planeU, planeV};
    when(mockImage.getPlanes()).thenReturn(planes);

    when(mockImageStreamReaderUtils.yuv420ThreePlanesToNV21(any(), anyInt(), anyInt())).thenReturn(ByteBuffer.allocate(1280*720));

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);
    imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

    verify(mockImageStreamReaderUtils).yuv420ThreePlanesToNV21(any(), anyInt(), anyInt());
  }
}
