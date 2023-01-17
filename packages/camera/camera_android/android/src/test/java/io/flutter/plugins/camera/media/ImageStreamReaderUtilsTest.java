// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import android.media.Image;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.robolectric.RobolectricTestRunner;
import java.nio.ByteBuffer;
import java.util.Arrays;

@RunWith(RobolectricTestRunner.class)
public class ImageStreamReaderUtilsTest {
    private ImageStreamReaderUtils imageStreamReaderUtils;

    @Before
    public void setUp() {
        this.imageStreamReaderUtils = new ImageStreamReaderUtils();
    }

    @Test(expected = IllegalArgumentException.class)
    public void removePlaneBufferPadding_throwsIfPixelStrideInvalid() {
        Image.Plane planeU = mock(Image.Plane.class);
        when(planeU.getBuffer()).thenReturn(ByteBuffer.allocate(552703));
        when(planeU.getRowStride()).thenReturn(1536);
        when(planeU.getPixelStride()).thenReturn(2);

        imageStreamReaderUtils.removePlaneBufferPadding(planeU, 1280 / 2, 720 / 2);
    }

    // Values here are taken from a Vivo V2135 which adds padding in 1280x720 mode
    @Test
    public void removePlaneBufferPadding_removesPaddingCorrectly() {
        Image.Plane planeY = mock(Image.Plane.class);
        when(planeY.getBuffer()).thenReturn(ByteBuffer.allocate(1105664));
        when(planeY.getRowStride()).thenReturn(1536);
        when(planeY.getPixelStride()).thenReturn(1);

        byte[] fixed = imageStreamReaderUtils.removePlaneBufferPadding(planeY, 1280, 720);

        // After trimming the padding, the buffer size should match the image size
        Assert.assertEquals(fixed.length, 1280 * 720);
        Assert.assertNotEquals(fixed.length, planeY.getBuffer().limit());
        Assert.assertFalse(Arrays.equals(fixed, planeY.getBuffer().array()));
    }

    // Values here are taken from a Pixel 6 which does not add any padding.
    // In the event we pass a buffer with no padding, the returned buffer
    // should be identical to the source one because nothing is trimmed.
    @Test
    public void removePlaneBufferPadding_doesNothingIfThereIsNoPadding() {
        Image.Plane planeY = mock(Image.Plane.class);
        when(planeY.getBuffer()).thenReturn(ByteBuffer.allocate(921600));
        when(planeY.getRowStride()).thenReturn(1280);
        when(planeY.getPixelStride()).thenReturn(1);

        byte[] fixed = imageStreamReaderUtils.removePlaneBufferPadding(planeY, 1280, 720);

        // After trimming the padding, the buffer size should match the image size
        Assert.assertEquals(fixed.length, 1280 * 720);
        Assert.assertEquals(fixed.length, planeY.getBuffer().limit());
        Assert.assertArrayEquals(fixed, planeY.getBuffer().array());
    }
}
