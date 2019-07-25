// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemlvision;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.net.Uri;
import android.util.SparseArray;
import androidx.exifinterface.media.ExifInterface;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.File;
import java.io.IOException;
import java.util.Map;

/** FirebaseMlVisionPlugin */
public class FirebaseMlVisionPlugin implements MethodCallHandler {
  private final SparseArray<Detector> detectors = new SparseArray<>();

  private Registrar registrar;

  private FirebaseMlVisionPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_ml_vision");
    channel.setMethodCallHandler(new FirebaseMlVisionPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "BarcodeDetector#detectInImage":
      case "FaceDetector#processImage":
      case "ImageLabeler#processImage":
      case "TextRecognizer#processImage":
        handleDetection(call, result);
        break;
      case "BarcodeDetector#close":
      case "FaceDetector#close":
      case "ImageLabeler#close":
      case "TextRecognizer#close":
        closeDetector(call, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private void handleDetection(MethodCall call, Result result) {
    Map<String, Object> options = call.argument("options");

    FirebaseVisionImage image;
    Map<String, Object> imageData = call.arguments();
    try {
      image = dataToVisionImage(imageData);
    } catch (IOException exception) {
      result.error("MLVisionDetectorIOError", exception.getLocalizedMessage(), null);
      return;
    }

    Detector detector = getDetector(call);
    if (detector == null) {
      switch (call.method.split("#")[0]) {
        case "BarcodeDetector":
          detector = new BarcodeDetector(FirebaseVision.getInstance(), options);
          break;
        case "FaceDetector":
          detector = new FaceDetector(FirebaseVision.getInstance(), options);
          break;
        case "ImageLabeler":
          detector = new ImageLabeler(FirebaseVision.getInstance(), options);
          break;
        case "TextRecognizer":
          detector = new TextRecognizer(FirebaseVision.getInstance(), options);
          break;
      }

      final Integer handle = call.argument("handle");
      addDetector(handle, detector);
    }

    detector.handleDetection(image, result);
  }

  private void closeDetector(final MethodCall call, final Result result) {
    final Detector detector = getDetector(call);

    if (detector == null) {
      final Integer handle = call.argument("handle");
      final String message = String.format("Object for handle does not exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    try {
      detector.close();
      result.success(null);
    } catch (IOException e) {
      final String code = String.format("%sIOError", detector.getClass().getSimpleName());
      result.error(code, e.getLocalizedMessage(), null);
    } finally {
      final Integer handle = call.argument("handle");
      detectors.remove(handle);
    }
  }

  private FirebaseVisionImage dataToVisionImage(Map<String, Object> imageData) throws IOException {
    String imageType = (String) imageData.get("type");
    assert imageType != null;

    switch (imageType) {
      case "file":
        final String imageFilePath = (String) imageData.get("path");
        final int rotation = getImageExifOrientation(imageFilePath);

        if (rotation == 0) {
          File file = new File(imageFilePath);
          return FirebaseVisionImage.fromFilePath(registrar.context(), Uri.fromFile(file));
        }

        Matrix matrix = new Matrix();
        matrix.postRotate(rotation);

        final Bitmap bitmap = BitmapFactory.decodeFile(imageFilePath);
        final Bitmap rotatedBitmap =
            Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);

        return FirebaseVisionImage.fromBitmap(rotatedBitmap);
      case "bytes":
        @SuppressWarnings("unchecked")
        Map<String, Object> metadataData = (Map<String, Object>) imageData.get("metadata");

        FirebaseVisionImageMetadata metadata =
            new FirebaseVisionImageMetadata.Builder()
                .setWidth((int) (double) metadataData.get("width"))
                .setHeight((int) (double) metadataData.get("height"))
                .setFormat(FirebaseVisionImageMetadata.IMAGE_FORMAT_NV21)
                .setRotation(getRotation((int) metadataData.get("rotation")))
                .build();

        byte[] bytes = (byte[]) imageData.get("bytes");
        assert bytes != null;

        return FirebaseVisionImage.fromByteArray(bytes, metadata);
      default:
        throw new IllegalArgumentException(String.format("No image type for: %s", imageType));
    }
  }

  private int getImageExifOrientation(String imageFilePath) throws IOException {
    ExifInterface exif = new ExifInterface(imageFilePath);
    int orientation =
        exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);

    switch (orientation) {
      case ExifInterface.ORIENTATION_ROTATE_90:
        return 90;
      case ExifInterface.ORIENTATION_ROTATE_180:
        return 180;
      case ExifInterface.ORIENTATION_ROTATE_270:
        return 270;
      default:
        return 0;
    }
  }

  private int getRotation(int rotation) {
    switch (rotation) {
      case 0:
        return FirebaseVisionImageMetadata.ROTATION_0;
      case 90:
        return FirebaseVisionImageMetadata.ROTATION_90;
      case 180:
        return FirebaseVisionImageMetadata.ROTATION_180;
      case 270:
        return FirebaseVisionImageMetadata.ROTATION_270;
      default:
        throw new IllegalArgumentException(String.format("No rotation for: %d", rotation));
    }
  }

  private void addDetector(final int handle, final Detector detector) {
    if (detectors.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    detectors.put(handle, detector);
  }

  private Detector getDetector(final MethodCall call) {
    final Integer handle = call.argument("handle");
    return detectors.get(handle);
  }
}
