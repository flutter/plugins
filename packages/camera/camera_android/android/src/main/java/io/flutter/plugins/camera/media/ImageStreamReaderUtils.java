package io.flutter.plugins.camera.media;

import android.media.Image;
import java.nio.ByteBuffer;

public class ImageStreamReaderUtils {
    /**
     * Copyright (c) 2019 Dmitry Gordin
     * Based on:
     * https://github.com/gordinmitya/yuv2buf/blob/master/yuv2buf/src/main/java/ru/gordinmitya/yuv2buf/Yuv.java
     *
     * Will remove the padding from a given image plane and return the fixed buffer.
     *
     * @param plane is the image plane (buffer) that will be processed as an {@link Image.Plane}
     * @param planeWidth is the width of the plane as an int
     * @param planeHeight is the height of the plane as an int
     */
    public byte[] removePlaneBufferPadding(Image.Plane plane, int planeWidth, int planeHeight) {
        if (plane.getPixelStride() != 1) {
            throw new IllegalArgumentException("it's only valid to remove padding when pixelStride == 1");
        }

        ByteBuffer dst =  ByteBuffer.allocate(planeWidth * planeHeight);
        ByteBuffer src = plane.getBuffer();
        int rowStride = plane.getRowStride();
        ByteBuffer row;
        for (int i = 0; i < planeHeight; i++) {
            row = clipBuffer(src, i * rowStride, planeWidth);
            dst.put(row);
        }

        return dst.array();
    }

    /**
     * Copyright (c) 2019 Dmitry Gordin
     * Based on:
     * https://github.com/gordinmitya/yuv2buf/blob/master/yuv2buf/src/main/java/ru/gordinmitya/yuv2buf/Yuv.java
     *
     * Copies part of a buffer to a new buffer, used to trim the padding.
     *
     * @param buffer is the source buffer to be modified as a {@link ByteBuffer}
     * @param start is the starting offset to read from as an int
     * @param size is the length of data to read as an int
     */
    public ByteBuffer clipBuffer(ByteBuffer buffer, int start, int size) {
        ByteBuffer duplicate = buffer.duplicate();
        duplicate.position(start);
        duplicate.limit(start + size);
        return duplicate.slice();
    }
}
