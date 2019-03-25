// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

class ImageResizer {
  private final File externalFilesDirectory;
  private final ExifDataCopier exifDataCopier;
  private boolean isRotated = false;

  ImageResizer(File externalFilesDirectory, ExifDataCopier exifDataCopier) {
    this.externalFilesDirectory = externalFilesDirectory;
    this.exifDataCopier = exifDataCopier;
  }

  /**
   * If necessary, resizes the image located in imagePath and then returns the path for the scaled
   * image.
   *
   * <p>If no resizing is needed, returns the path for the original image.
   */
  String resizeImageIfNeeded(String imagePath, Double maxWidth, Double maxHeight, Boolean rotate) {
    boolean shouldScale = maxWidth != null || maxHeight != null;

    if (!shouldScale && !(rotate != null && rotate)) {
      return imagePath;
    }

    try {
      File scaledImage = resizedImage(imagePath, maxWidth, maxHeight, rotate);
      exifDataCopier.copyExif(imagePath, scaledImage.getPath());
      rewriteRotationExifIfNeeded(scaledImage);
      return scaledImage.getPath();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  private void rewriteRotationExifIfNeeded(File scaledImage) throws IOException {
    if (isRotated) {
      ExifInterface exif = new ExifInterface(scaledImage.getPath());
      exif.setAttribute(
          ExifInterface.TAG_ORIENTATION, String.valueOf(ExifInterface.ORIENTATION_NORMAL));
      exif.saveAttributes();
    }
  }

  private File resizedImage(String path, Double maxWidth, Double maxHeight, Boolean rotate)
      throws IOException {
    Bitmap bmp = BitmapFactory.decodeFile(path);
    double originalWidth = bmp.getWidth() * 1.0;
    double originalHeight = bmp.getHeight() * 1.0;

    boolean hasMaxWidth = maxWidth != null;
    boolean hasMaxHeight = maxHeight != null;

    Double width = hasMaxWidth ? Math.min(originalWidth, maxWidth) : originalWidth;
    Double height = hasMaxHeight ? Math.min(originalHeight, maxHeight) : originalHeight;

    boolean shouldDownscaleWidth = hasMaxWidth && maxWidth < originalWidth;
    boolean shouldDownscaleHeight = hasMaxHeight && maxHeight < originalHeight;
    boolean shouldDownscale = shouldDownscaleWidth || shouldDownscaleHeight;

    if (shouldDownscale) {
      double downscaledWidth = (height / originalHeight) * originalWidth;
      double downscaledHeight = (width / originalWidth) * originalHeight;

      if (width < height) {
        if (!hasMaxWidth) {
          width = downscaledWidth;
        } else {
          height = downscaledHeight;
        }
      } else if (height < width) {
        if (!hasMaxHeight) {
          height = downscaledHeight;
        } else {
          width = downscaledWidth;
        }
      } else {
        if (originalWidth < originalHeight) {
          width = downscaledWidth;
        } else if (originalHeight < originalWidth) {
          height = downscaledHeight;
        }
      }
    }

    Bitmap scaledBmp = Bitmap.createScaledBitmap(bmp, width.intValue(), height.intValue(), false);
    if (rotate != null && rotate) {
      scaledBmp = rotateImage(scaledBmp, path);
    }
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    boolean saveAsPNG = bmp.hasAlpha();
    scaledBmp.compress(
        saveAsPNG ? Bitmap.CompressFormat.PNG : Bitmap.CompressFormat.JPEG, 100, outputStream);

    String[] pathParts = path.split("/");
    String imageName = pathParts[pathParts.length - 1];

    File imageFile = new File(externalFilesDirectory, "/scaled_" + imageName);
    FileOutputStream fileOutput = new FileOutputStream(imageFile);
    fileOutput.write(outputStream.toByteArray());
    fileOutput.close();

    return imageFile;
  }

  private Bitmap rotateImage(Bitmap bitmap, String originalImagePath) throws IOException {

    ExifInterface ei = new ExifInterface(originalImagePath);
    int orientation =
        ei.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED);

    switch (orientation) {
      case ExifInterface.ORIENTATION_ROTATE_90:
        return rotate(bitmap, 90);
      case ExifInterface.ORIENTATION_ROTATE_180:
        return rotate(bitmap, 180);
      case ExifInterface.ORIENTATION_ROTATE_270:
        return rotate(bitmap, 270);
      case ExifInterface.ORIENTATION_NORMAL:
        return bitmap;
    }

    return bitmap;
  }

  private Bitmap rotate(Bitmap source, float angle) {
    isRotated = true;
    Matrix matrix = new Matrix();
    matrix.postRotate(angle);
    return Bitmap.createBitmap(source, 0, 0, source.getWidth(), source.getHeight(), matrix, false);
  }
}
