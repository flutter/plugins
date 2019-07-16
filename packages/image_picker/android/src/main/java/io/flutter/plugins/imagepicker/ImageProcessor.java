// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import io.flutter.plugins.imagepicker.support.ExifUtils;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

class ImageProcessor {
  private final File externalFilesDirectory;

  ImageProcessor(File externalFilesDirectory) {
    this.externalFilesDirectory = externalFilesDirectory;
  }

  /**
   * If necessary, resizes the image located in imagePath and then returns the path for the scaled
   * image.
   *
   * <p>If no resizing is needed, returns the path for the original image.
   */
  String processImage(String imagePath, Double maxWidth, Double maxHeight) {

    try {
      File scaledImage = resizedImage(imagePath, maxWidth, maxHeight);
      ExifUtils.copyExif(imagePath, scaledImage.getPath());

      return scaledImage.getPath();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  private File resizedImage(String path, Double maxWidth, Double maxHeight) throws IOException {
    Bitmap bmp = BitmapFactory.decodeFile(path);
    double originalWidth = bmp.getWidth() * 1.0;
    double originalHeight = bmp.getHeight() * 1.0;

    boolean hasMaxWidth = maxWidth != 0;
    boolean hasMaxHeight = maxHeight != 0;

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

    Bitmap fixedOrientationBmp = ExifUtils.modifyOrientation(scaledBmp, path);


    String[] pathParts = path.split("/");
    String imageName = pathParts[pathParts.length - 1];

    final File imageFile = new File(externalFilesDirectory, "/scaled_" + imageName);
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    boolean saveAsPNG = bmp.hasAlpha();

    fixedOrientationBmp.compress(
      saveAsPNG ? Bitmap.CompressFormat.PNG : Bitmap.CompressFormat.JPEG, 100, outputStream);

    FileOutputStream fileOutput = new FileOutputStream(imageFile);
    fileOutput.write(outputStream.toByteArray());
    fileOutput.close();

    bmp.recycle();
    fixedOrientationBmp.recycle();
    scaledBmp.recycle();

    return imageFile;
  }
}
