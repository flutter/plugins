package io.flutter.plugins.camera.media;

import android.graphics.ImageFormat;
import android.media.Image;
import android.media.ImageReader;
import android.os.Handler;
import android.os.Looper;
import android.view.Surface;

import androidx.annotation.NonNull;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.camera.types.CameraCaptureProperties;

// Wraps an ImageReader to allow for testing of the image handler.
public class ImageStreamReader {
    // The actual im
    private final ImageReader imageReader;

    /**
     * Creates a new instance of the {@link ImageStreamReader}.
     *
     * @param width is the integer width of the image stream (preview image)
     * @param height is the integer height of the image stream (preview image)
     * @param imageFormatGroup is the integer image format group, as a valid {@link ImageFormat}.
     */
    public ImageStreamReader(
            int width,
            int height,
            int imageFormatGroup
    ) {
        this.imageReader = ImageReader.newInstance(
                width,
                height,
                imageFormatGroup,
                1
        );
    }

    /**
     * Processes a new frame (image) from the image reader, remove padding if necessary,
     * and send the frame to Dart.
     *
     * @param image is the image which needs processed as an {@link Image}
     * @param imageFormat is the image format from the image reader as an int, a valid {@link ImageFormat}
     * @param captureProps is the capture props from the camera class as {@link CameraCaptureProperties}
     * @param imageStreamSink is the image stream sink from dart as a dart {@link EventChannel.EventSink}
     */
    private static void onImageAvailable(
            @NonNull Image image,
            int imageFormat,
            CameraCaptureProperties captureProps,
            EventChannel.EventSink imageStreamSink
    ) {
        List<Map<String, Object>> planes = new ArrayList<>();
        for (int i=0; i<image.getPlanes().length; i++) {
            // Current plane
            Image.Plane plane = image.getPlanes()[i];

            // The metadata to be returned to dart
            Map<String, Object> planeBuffer = new HashMap<>();
            planeBuffer.put("bytesPerPixel", plane.getPixelStride());

            // Sometimes YUV420 has additional padding that must be removed. This is only the case if we are
            // streaming YUV420, the row stride does not match the image width, and the pixel stride is 1.
            if (imageFormat == ImageFormat.YUV_420_888 &&
                    plane.getRowStride() != image.getWidth() &&
                    plane.getPixelStride() == 1) {
                // The ordering of planes is guaranteed by Android. It always goes Y, U, V.
                int planeWidth;
                int planeHeight;
                if (i == 0) {
                    // Y is the image size
                    planeWidth = image.getWidth();
                    planeHeight = image.getHeight();
                } else {
                    // U and V are guaranteed to be the same size and are half of the image height/width
                    // in YUV420
                    planeWidth = image.getWidth() / 2;
                    planeHeight = image.getHeight() / 2;
                }

                planeBuffer.put("bytes", removePlaneBufferPadding(plane, planeWidth, planeHeight));

                // Make sure the bytesPerRow matches the image width now that we've removed the padding
                planeBuffer.put("bytesPerRow", image.getWidth());
            } else {
                // Just use the data as-is
                ByteBuffer buffer = plane.getBuffer();
                byte[] bytes = new byte[buffer.remaining()];
                buffer.get(bytes, 0, bytes.length);
                planeBuffer.put("bytes", bytes);
                planeBuffer.put("bytesPerRow", plane.getRowStride());
            }
            planes.add(planeBuffer);
        }

        Map<String, Object> imageBuffer = new HashMap<>();
        imageBuffer.put("width", image.getWidth());
        imageBuffer.put("height", image.getHeight());
        imageBuffer.put("format", image.getFormat());
        imageBuffer.put("planes", planes);
        imageBuffer.put("lensAperture", captureProps.getLastLensAperture());
        imageBuffer.put("sensorExposureTime", captureProps.getLastSensorExposureTime());
        Integer sensorSensitivity = captureProps.getLastSensorSensitivity();
        imageBuffer.put(
                "sensorSensitivity", sensorSensitivity == null ? null : (double) sensorSensitivity);

        final Handler handler = new Handler(Looper.getMainLooper());
        handler.post(() -> imageStreamSink.success(imageBuffer));
        image.close();
    }

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
    private static byte[] removePlaneBufferPadding(Image.Plane plane, int planeWidth, int planeHeight) {
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
    private static ByteBuffer clipBuffer(ByteBuffer buffer, int start, int size) {
        ByteBuffer duplicate = buffer.duplicate();
        duplicate.position(start);
        duplicate.limit(start + size);
        return duplicate.slice();
    }

    /**
     * Returns the image reader surface.
     */
    public Surface getSurface() {
        return imageReader.getSurface();
    }

    /**
     * Subscribes the image stream reader to handle incoming images using onImageAvailable().
     *
     * @param captureProps is the capture props from the camera class as {@link CameraCaptureProperties}
     * @param imageStreamSink is the image stream sink from dart as {@link EventChannel.EventSink}
     * @param handler is generally the background handler of the camera as {@link Handler}
     */
    public void subscribeListener(
            CameraCaptureProperties captureProps,
            EventChannel.EventSink imageStreamSink,
            Handler handler
    ) {
        imageReader.setOnImageAvailableListener(reader -> {
            Image image = reader.acquireNextImage();
            if (image == null) return;

            onImageAvailable(image, imageReader.getImageFormat(), captureProps, imageStreamSink);
        }, handler);
    }

    /**
     * Removes the listener from the image reader.
     *
     * @param handler is generally the background handler of the camera
     */
    public void removeListener(Handler handler) {
        imageReader.setOnImageAvailableListener(null, handler);
    }

    /**
     * Closes the image reader.
     */
    public void close() {
        imageReader.close();
    }
}
