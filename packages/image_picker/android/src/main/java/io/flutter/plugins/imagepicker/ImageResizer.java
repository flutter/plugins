// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

class ImageResizer {
  private final File externalFilesDirectory;
  private final ExifDataCopier exifDataCopier;

  public static class SizeInfo {
    public final int width;
    public final int height;
    public final double scale;
    public final double drawX;
    public final double drawY;
    public final double drawWidth;
    public final double drawHeight;

    SizeInfo(
        int width,
        int height,
        double scale,
        double drawX,
        double drawY,
        double drawWidth,
        double drawHeight) {
      this.width = width;
      this.height = height;
      this.scale = scale;
      this.drawX = drawX;
      this.drawY = drawY;
      this.drawWidth = drawWidth;
      this.drawHeight = drawHeight;
    }
  }

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
  String resizeImageIfNeeded(String imagePath, Double maxWidth, Double maxHeight, boolean crop) {
    boolean shouldScale = maxWidth != null || maxHeight != null;

    if (!shouldScale) {
      return imagePath;
    }

    try {
      File scaledImage = resizedImage(imagePath, maxWidth, maxHeight, crop);
      exifDataCopier.copyExif(imagePath, scaledImage.getPath());

      return scaledImage.getPath();
    } catch (IOException e) {
      throw new RuntimeException(e);
    }
  }

  public static SizeInfo computeSizeInfo(
      int originalWidth, int originalHeight, Double maxWidth, Double maxHeight, boolean crop) {
    boolean hasMaxWidth = maxWidth != null;
    boolean hasMaxHeight = maxHeight != null;

    double widthScale = hasMaxWidth ? maxWidth / Math.max(1, originalWidth) : -1.0;
    double heightScale = hasMaxHeight ? maxHeight / Math.max(1, originalHeight) : -1.0;

    double scale;
    if (hasMaxWidth) {
      if (hasMaxHeight) {
        if (crop) {
          scale = Math.max(widthScale, heightScale);
        } else {
          scale = Math.min(widthScale, heightScale);
        }
      } else {
        scale = widthScale;
      }
    } else {
      if (hasMaxHeight) {
        scale = heightScale;
      } else {
        scale = 1.0;
      }
    }

    scale = Math.min(scale, 1.0);

    double drawWidth = Math.round(scale * originalWidth);
    double drawHeight = Math.round(scale * originalHeight);

    double width = hasMaxWidth ? Math.min(drawWidth, maxWidth) : drawWidth;
    double height = hasMaxHeight ? Math.min(drawHeight, maxHeight) : drawHeight;

    double drawX = (width - drawWidth) / 2;
    double drawY = (height - drawHeight) / 2;

    return new SizeInfo((int) width, (int) height, scale, drawX, drawY, drawWidth, drawHeight);
  }

  private File resizedImage(String path, Double maxWidth, Double maxHeight, boolean crop)
      throws IOException {
    Bitmap bmp = BitmapFactory.decodeFile(path);
    final SizeInfo info =
        computeSizeInfo(bmp.getWidth(), bmp.getHeight(), maxWidth, maxHeight, crop);

    int sampleSize = 1;
    while (sampleSize * 2 < 1 / info.scale) {
      sampleSize *= 2;
    }

    Bitmap.Config config = bmp.getConfig();
    if (config == null) {
      config = Bitmap.Config.ARGB_8888;
    }

    Paint paint = new Paint(Paint.FILTER_BITMAP_FLAG);

    // First step - scale in range [0.5; 1)
    {
      Bitmap scaledBmp =
          Bitmap.createBitmap(info.width * sampleSize, info.height * sampleSize, config);
      Canvas canvas = new Canvas(scaledBmp);
      canvas.translate((float) (info.drawX * sampleSize), (float) (info.drawY * sampleSize));
      float scale = (float) (info.scale * sampleSize);
      canvas.scale(scale, scale);
      canvas.drawBitmap(bmp, 0, 0, paint);
      bmp.recycle();
      bmp = scaledBmp;
    }

    // Scale by 0.5 as many times as needed
    while (sampleSize > 1) {
      sampleSize /= 2;

      Bitmap scaledBmp =
          Bitmap.createBitmap(info.width * sampleSize, info.height * sampleSize, config);
      Canvas canvas = new Canvas(scaledBmp);
      canvas.scale(0.5f, 0.5f);
      canvas.drawBitmap(bmp, 0, 0, paint);
      bmp.recycle();
      bmp = scaledBmp;
    }

    ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
    bmp.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);

    String[] pathParts = path.split("/");
    String imageName = pathParts[pathParts.length - 1];

    File imageFile = new File(externalFilesDirectory, "/scaled_" + imageName);
    FileOutputStream fileOutput = new FileOutputStream(imageFile);
    fileOutput.write(outputStream.toByteArray());
    fileOutput.close();

    return imageFile;
  }
}
