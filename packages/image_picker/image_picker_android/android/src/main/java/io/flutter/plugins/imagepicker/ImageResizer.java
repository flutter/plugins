// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import android.util.Log;
import androidx.annotation.Nullable;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

class ImageResizer {
  private final File externalFilesDirectory;
  private final ExifDataCopier exifDataCopier;

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
  String resizeImageIfNeeded(
      String imagePath,
      @Nullable Double maxWidth,
      @Nullable Double maxHeight,
      @Nullable Integer imageQuality) {
    BitmapFactory.Options queryOptions = new BitmapFactory.Options();
    queryOptions.inJustDecodeBounds = true;
    decodeFile(imagePath, queryOptions);
    if (queryOptions.outWidth == -1 || queryOptions.outHeight == -1) {
      return null;
    }
    boolean shouldScale =
        maxWidth != null || maxHeight != null || isImageQualityValid(imageQuality);
    if (!shouldScale) {
      return imagePath;
    }
    try {
      String[] pathParts = imagePath.split("/");
      String imageName = pathParts[pathParts.length - 1];
      Point size =
          calculateSize(
              Double.valueOf(queryOptions.outWidth),
              Double.valueOf(queryOptions.outHeight),
              maxWidth,
              maxHeight);
      BitmapFactory.Options options = new BitmapFactory.Options();
      options.inSampleSize = calculateInSampleSize(options, size.x, size.y);
      options.inJustDecodeBounds = false;
      File file =
          resizedImage(
              decodeFile(imagePath, options), maxWidth, maxHeight, imageQuality, imageName);
      copyExif(imagePath, file.getPath());
      return file.getPath();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  private File resizedImage(
      Bitmap bmp, Double maxWidth, Double maxHeight, Integer imageQuality, String outputImageName)
      throws IOException {
    double originalWidth = bmp.getWidth() * 1.0;
    double originalHeight = bmp.getHeight() * 1.0;

    if (!isImageQualityValid(imageQuality)) {
      imageQuality = 100;
    }

    Point size = calculateSize(originalWidth, originalHeight, maxWidth, maxHeight);
    Bitmap scaledBmp = createScaledBitmap(bmp, size.x, size.y, false);
    File file =
        createImageOnExternalDirectory("/scaled_" + outputImageName, scaledBmp, imageQuality);
    return file;
  }

  private Point calculateSize(
      Double originalWidth, Double originalHeight, Double maxWidth, Double maxHeight) {
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

    return new Point(width.intValue(), height.intValue());
  }

  private File createFile(File externalFilesDirectory, String child) {
    File image = new File(externalFilesDirectory, child);
    if (!image.getParentFile().exists()) {
      image.getParentFile().mkdirs();
    }
    return image;
  }

  private FileOutputStream createOutputStream(File imageFile) throws IOException {
    return new FileOutputStream(imageFile);
  }

  private void copyExif(String filePathOri, String filePathDest) {
    exifDataCopier.copyExif(filePathOri, filePathDest);
  }

  private Bitmap decodeFile(String path, @Nullable BitmapFactory.Options opts) {
    return BitmapFactory.decodeFile(path, opts);
  }

  private Bitmap createScaledBitmap(Bitmap bmp, int width, int height, boolean filter) {
    return Bitmap.createScaledBitmap(bmp, width, height, filter);
  }

  private boolean isImageQualityValid(Integer imageQuality) {
    return imageQuality != null && imageQuality > 0 && imageQuality < 100;
  }

  private int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
    final int height = options.outHeight;
    final int width = options.outWidth;
    int inSampleSize = 1;
    if (height > reqHeight || width > reqWidth) {
      final int halfHeight = height / 2;
      final int halfWidth = width / 2;
      while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
        inSampleSize *= 2;
      }
    }
    return inSampleSize;
  }

  private File createImageOnExternalDirectory(String name, Bitmap bitmap, int imageQuality)
      throws IOException {
    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    boolean saveAsPNG = bitmap.hasAlpha();
    if (saveAsPNG) {
      Log.d(
          "ImageResizer",
          "image_picker: compressing is not supported for type PNG. Returning the image with original quality");
    }
    bitmap.compress(
        saveAsPNG ? Bitmap.CompressFormat.PNG : Bitmap.CompressFormat.JPEG,
        imageQuality,
        outputStream);
    File imageFile = createFile(externalFilesDirectory, name);
    FileOutputStream fileOutput = createOutputStream(imageFile);
    fileOutput.write(outputStream.toByteArray());
    fileOutput.close();
    return imageFile;
  }
}
