// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import androidx.exifinterface.media.ExifInterface;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

class ImageResizer {
  private final File externalFilesDirectory;
  private final ExifHandler exifHandler;

  ImageResizer(File externalFilesDirectory, ExifHandler exifHandler) {
    this.externalFilesDirectory = externalFilesDirectory;
    this.exifHandler = exifHandler;

  }

  /**
   * This method will utilize the Exif information to try to place the image in normal orientation
   * and then resize it.
   *
   * <p>This method will always apply the operations of fix and resize operation.
   * returns the path for the scaled image.
   * This will create a new image file for every call.
   */
  String normalizeImage(String imagePath, Double maxWidth, Double maxHeight) throws IOException {


      final Bitmap bitmap = exifHandler.getNormalOrientationBitmap(imagePath);
      final File file = resizedImage(bitmap, imagePath, maxWidth, maxHeight);
      final ExifInterface newExif = exifHandler.copyExif(imagePath, file.getPath());

      bitmap.recycle();

      exifHandler.setNormalOrientation(newExif);

      return file.getPath();

  }

  private File resizedImage(
    Bitmap bmp,
    String path,
    Double maxWidth,
    Double maxHeight
  ) throws IOException {

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
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    final boolean saveAsPNG = bmp.hasAlpha();
    final CompressFormat selectedFormat = saveAsPNG ? CompressFormat.PNG : CompressFormat.JPEG;

    scaledBmp.compress(selectedFormat, 100, outputStream);

    String[] pathParts = path.split("/");
    String imageName = pathParts[pathParts.length - 1];

    File imageFile = new File(externalFilesDirectory, "/scaled_" + imageName);
    FileOutputStream fileOutput = new FileOutputStream(imageFile);
    fileOutput.write(outputStream.toByteArray());
    fileOutput.close();
    scaledBmp.recycle();
    return imageFile;
  }
}
