// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.junit.Assert.assertEquals;
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
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageStreamReaderTest {
  /** If we request YUV42 we should stream in YUV420. */
  @Test
  public void computeStreamImageFormat_computesCorrectStreamFormatYuv() {
    int requestedStreamFormat = ImageFormat.YUV_420_888;
    int result = ImageStreamReader.computeStreamImageFormat(requestedStreamFormat);
    assertEquals(result, ImageFormat.YUV_420_888);
  }

  /**
   * When we want to stream in NV21, we should still request YUV420 from the camera because we will
   * convert it to NV21 before sending it to dart.
   */
  @Test
  public void computeStreamImageFormat_computesCorrectStreamFormatNv21() {
    int requestedStreamFormat = ImageFormat.NV21;
    int result = ImageStreamReader.computeStreamImageFormat(requestedStreamFormat);
    assertEquals(result, ImageFormat.YUV_420_888);
  }

  /**
   * If we are requesting NV21, then the planes should be processed and converted to NV21 before
   * being sent to dart. We make sure yuv420ThreePlanesToNV21 is called when we are requesting
   */
  @Test
  public void onImageAvailable_parsesPlanesForNv21() {
    // Dart wants NV21 frames
    int dartImageFormat = ImageFormat.NV21;

    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);
    ImageStreamReader imageStreamReader =
        new ImageStreamReader(mockImageReader, dartImageFormat, mockImageStreamReaderUtils);

    ByteBuffer mockBytes = ByteBuffer.allocate(0);
    when(mockImageStreamReaderUtils.yuv420ThreePlanesToNV21(any(), anyInt(), anyInt()))
        .thenReturn(mockBytes);

    // The image format as streamed from the camera
    int imageFormat = ImageFormat.YUV_420_888;

    // Mock YUV image
    Image mockImage = mock(Image.class);
    when(mockImage.getWidth()).thenReturn(1280);
    when(mockImage.getHeight()).thenReturn(720);
    when(mockImage.getFormat()).thenReturn(imageFormat);

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

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);
    imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

    // Make sure we processed the frame with parsePlanesForNv21
    verify(mockImageStreamReaderUtils).yuv420ThreePlanesToNV21(any(), anyInt(), anyInt());
  }

  /** If we are requesting YUV420, then we should send the 3-plane image as it is. */
  @Test
  public void onImageAvailable_parsesPlanesForYuv420() {
    // Dart wants NV21 frames
    int dartImageFormat = ImageFormat.YUV_420_888;

    ImageReader mockImageReader = mock(ImageReader.class);
    ImageStreamReaderUtils mockImageStreamReaderUtils = mock(ImageStreamReaderUtils.class);
    ImageStreamReader imageStreamReader =
        new ImageStreamReader(mockImageReader, dartImageFormat, mockImageStreamReaderUtils);

    ByteBuffer mockBytes = ByteBuffer.allocate(0);
    when(mockImageStreamReaderUtils.yuv420ThreePlanesToNV21(any(), anyInt(), anyInt()))
        .thenReturn(mockBytes);

    // The image format as streamed from the camera
    int imageFormat = ImageFormat.YUV_420_888;

    // Mock YUV image
    Image mockImage = mock(Image.class);
    when(mockImage.getWidth()).thenReturn(1280);
    when(mockImage.getHeight()).thenReturn(720);
    when(mockImage.getFormat()).thenReturn(imageFormat);

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

    CameraCaptureProperties mockCaptureProps = mock(CameraCaptureProperties.class);
    EventChannel.EventSink mockEventSink = mock(EventChannel.EventSink.class);
    imageStreamReader.onImageAvailable(mockImage, mockCaptureProps, mockEventSink);

    // Make sure we processed the frame with parsePlanesForYuvOrJpeg
    verify(mockImageStreamReaderUtils, never()).yuv420ThreePlanesToNV21(any(), anyInt(), anyInt());
  }
}
