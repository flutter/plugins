// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.media.ThumbnailUtils;
import android.provider.MediaStore;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class ThumbnailCreator {

    private final ImageResizer imageResizer;
    private final File externalFilesDirectory;

    public ThumbnailCreator(ImageResizer imageResizer, File externalFilesDirectory) {
        this.imageResizer = imageResizer;
        this.externalFilesDirectory = externalFilesDirectory;
    }

    /**
     * <p>returns the path for the thumbnail image.
     */
    public String generateImageThumbnail(String originalImagePath, Double width,  Double height) {
        return imageResizer.resizeImageIfNeeded(originalImagePath, width, height);
    }

    /**
     * <p>returns the path for the thumbnail video.
     */
    public String generateVideoThumbnail(String originalVideoPath, Double width,  Double height) {
        try {
            Bitmap bitmap = ThumbnailUtils.createVideoThumbnail(originalVideoPath, MediaStore.Images.Thumbnails.MINI_KIND);

            Bitmap scaledBmp = Bitmap.createScaledBitmap(bitmap, width.intValue(), height.intValue(), false);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            scaledBmp.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);

            String[] pathParts = originalVideoPath.split("/");
            String imageName = pathParts[pathParts.length - 1];

            File imageFile = new File(externalFilesDirectory, "/thumbnail" + imageName);
            FileOutputStream fileOutput = new FileOutputStream(imageFile);
            fileOutput.write(outputStream.toByteArray());
            fileOutput.close();

            return generateImageThumbnail(imageFile.getPath(), width, height);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
