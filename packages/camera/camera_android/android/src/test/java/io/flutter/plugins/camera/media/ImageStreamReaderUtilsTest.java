// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import android.media.Image;
import java.nio.ByteBuffer;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;

@RunWith(RobolectricTestRunner.class)
public class ImageStreamReaderUtilsTest {
  private ImageStreamReaderUtils imageStreamReaderUtils;

  @Before
  public void setUp() {
    this.imageStreamReaderUtils = new ImageStreamReaderUtils();
  }

  @Test
  public void areUVPlanesNV21_shouldDetectYuvDataThatIsNv21() {
    Image.Plane planeY = mock(Image.Plane.class);
    Image.Plane planeU = mock(Image.Plane.class);
    Image.Plane planeV = mock(Image.Plane.class);
    Image.Plane[] planes = {planeY, planeU, planeV};

    // We construct the buffers to be valid NV21 split into its 3 planes.
    // This is generally described as a Y buffer with length of the image size
    // followed by two identical size U and V buffers which are sub-sampled by 2.
    ByteBuffer yBuffer = ByteBuffer.allocate(640*360);
    ByteBuffer uBuffer = ByteBuffer.allocate(2 * 640 * 360 / 4 - 1);
    ByteBuffer vBuffer = ByteBuffer.allocate(2 * 640 * 360 / 4 - 1);
    when(planeY.getBuffer()).thenReturn(yBuffer);
    when(planeU.getBuffer()).thenReturn(uBuffer);
    when(planeV.getBuffer()).thenReturn(vBuffer);

    boolean result = ImageStreamReaderUtils.areUVPlanesNV21(planes, 640, 360);
    Assert.assertEquals(true, result);

    yBuffer.clear();
    uBuffer.clear();
    vBuffer.clear();
  }

  @Test
  public void areUVPlanesNV21_shouldDetectYuvDataThatIsNotNv21() {
    Image.Plane planeY = mock(Image.Plane.class);
    Image.Plane planeU = mock(Image.Plane.class);
    Image.Plane planeV = mock(Image.Plane.class);
    Image.Plane[] planes = {planeY, planeU, planeV};

    // We construct the buffers to be a 3-buffer YUV420 image.
    ByteBuffer yBuffer = ByteBuffer.allocate(640*360);
    ByteBuffer uBuffer = ByteBuffer.allocate(640 / 2 * 360 / 2);
    ByteBuffer vBuffer = ByteBuffer.allocate(640 / 2 * 360 / 2);
    when(planeY.getBuffer()).thenReturn(yBuffer);
    when(planeU.getBuffer()).thenReturn(uBuffer);
    when(planeV.getBuffer()).thenReturn(vBuffer);

    boolean result = ImageStreamReaderUtils.areUVPlanesNV21(planes, 640, 360);
    Assert.assertEquals(false, result);

    yBuffer.clear();
    uBuffer.clear();
    vBuffer.clear();
  }

  // Feed it YUV data that has no padding and it should create a valid NV21 image.
  @Test
  public void yuv420ThreePlanesToNV21_shouldCreateValidNv21FromYuvDataNoPadding() {
    Image.Plane planeY = mock(Image.Plane.class);
    Image.Plane planeU = mock(Image.Plane.class);
    Image.Plane planeV = mock(Image.Plane.class);
    Image.Plane[] planes = {planeY, planeU, planeV};

    when(planeY.getRowStride()).thenReturn(640);
    when(planeU.getRowStride()).thenReturn(640);
    when(planeV.getRowStride()).thenReturn(640);
    when(planeY.getPixelStride()).thenReturn(1);
    when(planeU.getPixelStride()).thenReturn(2);
    when(planeV.getPixelStride()).thenReturn(2);

    // We construct the buffers to be a 3-buffer YUV420 image.
    ByteBuffer yBuffer = ByteBuffer.allocate(640*360);
    ByteBuffer uBuffer = ByteBuffer.allocate(640 / 2 * 360 / 2);
    ByteBuffer vBuffer = ByteBuffer.allocate(640 / 2 * 360 / 2);
    when(planeY.getBuffer()).thenReturn(yBuffer);
    when(planeU.getBuffer()).thenReturn(uBuffer);
    when(planeV.getBuffer()).thenReturn(vBuffer);

    ByteBuffer result = imageStreamReaderUtils.yuv420ThreePlanesToNV21(planes, 640, 360);
    Assert.assertEquals(yBuffer.limit() + yBuffer.limit() / 4 + yBuffer.limit() / 4, result.limit());

    yBuffer.clear();
    uBuffer.clear();
    vBuffer.clear();
  }

  // Feed it YUV data that has padding and it should create a valid NV21 image.
  // The result NV21 will have the padding trimmed away.
  @Test
  public void yuv420ThreePlanesToNV21_shouldCreateValidNv21FromYuvDataWithPadding() {
    Image.Plane planeY = mock(Image.Plane.class);
    Image.Plane planeU = mock(Image.Plane.class);
    Image.Plane planeV = mock(Image.Plane.class);
    Image.Plane[] planes = {planeY, planeU, planeV};

    when(planeY.getRowStride()).thenReturn(640);
    when(planeU.getRowStride()).thenReturn(1536);
    when(planeV.getRowStride()).thenReturn(1536);
    when(planeY.getPixelStride()).thenReturn(1);
    when(planeU.getPixelStride()).thenReturn(2);
    when(planeV.getPixelStride()).thenReturn(2);

    // We construct the buffers to be a 3-buffer YUV420 image.
    ByteBuffer yBuffer = ByteBuffer.allocate(640*360);
    ByteBuffer uBuffer = ByteBuffer.allocate(1536 / 2 * 360 / 2);
    ByteBuffer vBuffer = ByteBuffer.allocate(1536 / 2 * 360 / 2);
    when(planeY.getBuffer()).thenReturn(yBuffer);
    when(planeU.getBuffer()).thenReturn(uBuffer);
    when(planeV.getBuffer()).thenReturn(vBuffer);

    ByteBuffer result = imageStreamReaderUtils.yuv420ThreePlanesToNV21(planes, 640, 360);
    Assert.assertEquals(yBuffer.limit() + yBuffer.limit() / 4 + yBuffer.limit() / 4, result.limit());

    yBuffer.clear();
    uBuffer.clear();
    vBuffer.clear();
  }
}
