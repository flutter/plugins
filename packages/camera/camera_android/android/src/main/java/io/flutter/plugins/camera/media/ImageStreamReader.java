// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera.media;

import android.graphics.ImageFormat;
import android.media.Image;
import android.media.ImageReader;
import android.os.Handler;
import android.os.Looper;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.camera.types.CameraCaptureProperties;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

// Wraps an ImageReader to allow for testing of the image handler.
public class ImageStreamReader {

  /**
   * The image format we are going to send back to dart. Usually it's the same as streamImageFormat
   * but in the case of NV21 we will actually request YUV frames but convert it to NV21 before
   * sending to dart.
   */
  private final int dartImageFormat;

  private final ImageReader imageReader;
  private final ImageStreamReaderUtils imageStreamReaderUtils;

  /**
   * Creates a new instance of the {@link ImageStreamReader}.
   *
   * @param imageReader is the image reader that will receive frames
   * @param imageStreamReaderUtils is an instance of {@link ImageStreamReaderUtils}
   */
  @VisibleForTesting
  public ImageStreamReader(
      ImageReader imageReader, int dartImageFormat, ImageStreamReaderUtils imageStreamReaderUtils) {
    this.imageReader = imageReader;
    this.dartImageFormat = dartImageFormat;
    this.imageStreamReaderUtils = imageStreamReaderUtils;
  }

  /**
   * Creates a new instance of the {@link ImageStreamReader}.
   *
   * @param width is the image width
   * @param height is the image height
   * @param imageFormat is the {@link ImageFormat} that should be returned to dart.
   * @param maxImages is how many images can be acquired at one time, usually 1.
   */
  public ImageStreamReader(int width, int height, int imageFormat, int maxImages) {
    this.dartImageFormat = imageFormat;
    this.imageReader =
        ImageReader.newInstance(width, height, computeStreamImageFormat(imageFormat), maxImages);
    this.imageStreamReaderUtils = new ImageStreamReaderUtils();
  }

  /**
   * Returns the image format to stream based on a requested input format. Usually it's the same
   * except when dart is requesting NV21. In that case we stream YUV420 and process it into NV21
   * before sending the frames over.
   *
   * @param dartImageFormat is the image format dart is requesting.
   * @return the image format that should be streamed from the camera.
   */
  @VisibleForTesting
  public static int computeStreamImageFormat(int dartImageFormat) {
    if (dartImageFormat == ImageFormat.NV21) {
      return ImageFormat.YUV_420_888;
    } else {
      return dartImageFormat;
    }
  }

  /**
   * Processes a new frame (image) from the image reader and send the frame to Dart.
   *
   * @param image is the image which needs processed as an {@link Image}
   * @param captureProps is the capture props from the camera class as {@link
   *     CameraCaptureProperties}
   * @param imageStreamSink is the image stream sink from dart as a dart {@link
   *     EventChannel.EventSink}
   */
  @VisibleForTesting
  public void onImageAvailable(
      @NonNull Image image,
      CameraCaptureProperties captureProps,
      EventChannel.EventSink imageStreamSink) {
    try {
      Map<String, Object> imageBuffer = new HashMap<>();

      // Get plane data ready
      if (dartImageFormat == ImageFormat.NV21) {
        imageBuffer.put("planes", parsePlanesForNv21(image));
      } else {
        imageBuffer.put("planes", parsePlanesForYuvOrJpeg(image));
      }

      imageBuffer.put("width", image.getWidth());
      imageBuffer.put("height", image.getHeight());
      imageBuffer.put("format", dartImageFormat);
      imageBuffer.put("lensAperture", captureProps.getLastLensAperture());
      imageBuffer.put("sensorExposureTime", captureProps.getLastSensorExposureTime());
      Integer sensorSensitivity = captureProps.getLastSensorSensitivity();
      imageBuffer.put(
          "sensorSensitivity", sensorSensitivity == null ? null : (double) sensorSensitivity);

      final Handler handler = new Handler(Looper.getMainLooper());
      handler.post(() -> imageStreamSink.success(imageBuffer));
      image.close();

    } catch (IllegalStateException e) {
      // Handle "buffer is inaccessible" errors that can happen on some devices from ImageStreamReaderUtils.yuv420ThreePlanesToNV21()
      final Handler handler = new Handler(Looper.getMainLooper());
      handler.post(
          () ->
              imageStreamSink.error(
                  "IllegalStateException",
                  "Caught IllegalStateException: " + e.getMessage(),
                  null));
      image.close();
    }
  }

  /**
   * Given an input image, will return a list of maps suitable to send back to dart where
   * each map describes the image plane.
   *
   * For Yuv / Jpeg, we do no further processing on the frame so we simply send it as-is.
   *
   * @param image - the image to process.
   * @return parsed map describing the image planes to be sent to dart.
   */
  public List<Map<String, Object>> parsePlanesForYuvOrJpeg(@NonNull Image image) {
    List<Map<String, Object>> planes = new ArrayList<>();

    // For YUV420 and JPEG, just send the data as-is for each plane.
    for (Image.Plane plane : image.getPlanes()) {
      ByteBuffer buffer = plane.getBuffer();

      byte[] bytes = new byte[buffer.remaining()];
      buffer.get(bytes, 0, bytes.length);

      Map<String, Object> planeBuffer = new HashMap<>();
      planeBuffer.put("bytesPerRow", plane.getRowStride());
      planeBuffer.put("bytesPerPixel", plane.getPixelStride());
      planeBuffer.put("bytes", bytes);

      planes.add(planeBuffer);
    }
    return planes;
  }

  /**
   * Given an input image, will return a single-plane NV21 image. Assumes YUV420 as an input type.
   *
   * @param image - the image to process.
   * @return parsed map describing the image planes to be sent to dart.
   */
  public List<Map<String, Object>> parsePlanesForNv21(@NonNull Image image) {
    List<Map<String, Object>> planes = new ArrayList<>();

    // We will convert the YUV data to NV21 which is a single-plane image
    ByteBuffer bytes =
        imageStreamReaderUtils.yuv420ThreePlanesToNV21(
            image.getPlanes(), image.getWidth(), image.getHeight());

    Map<String, Object> planeBuffer = new HashMap<>();
    planeBuffer.put("bytesPerRow", image.getWidth());
    planeBuffer.put("bytesPerPixel", 1);
    planeBuffer.put("bytes", bytes.array());
    planes.add(planeBuffer);
    return planes;
  }

  /** Returns the image reader surface. */
  public Surface getSurface() {
    return imageReader.getSurface();
  }

  /**
   * Subscribes the image stream reader to handle incoming images using onImageAvailable().
   *
   * @param captureProps is the capture props from the camera class as {@link
   *     CameraCaptureProperties}
   * @param imageStreamSink is the image stream sink from dart as {@link EventChannel.EventSink}
   * @param handler is generally the background handler of the camera as {@link Handler}
   */
  public void subscribeListener(
      CameraCaptureProperties captureProps,
      EventChannel.EventSink imageStreamSink,
      Handler handler) {
    imageReader.setOnImageAvailableListener(
        reader -> {
          Image image = reader.acquireNextImage();
          if (image == null) return;

          onImageAvailable(image, captureProps, imageStreamSink);
        },
        handler);
  }

  /**
   * Removes the listener from the image reader.
   *
   * @param handler is generally the background handler of the camera
   */
  public void removeListener(Handler handler) {
    imageReader.setOnImageAvailableListener(null, handler);
  }

  /** Closes the image reader. */
  public void close() {
    imageReader.close();
  }
}
