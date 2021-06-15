// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.media.Image;
import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

/** Saves a JPEG {@link Image} into the specified {@link File}. */
public class ImageSaver implements Runnable {

  /** The JPEG image */
  private final Image mImage;

  /** The file we save the image into. */
  private final File mFile;

  /** Used to report the status of the save action. */
  private final Callback mCallback;

  ImageSaver(@NonNull Image image, @NonNull File file, @NonNull Callback callback) {
    mImage = image;
    mFile = file;
    mCallback = callback;
  }

  @Override
  public void run() {
    ByteBuffer buffer = mImage.getPlanes()[0].getBuffer();
    byte[] bytes = new byte[buffer.remaining()];
    buffer.get(bytes);
    FileOutputStream output = null;
    try {
      output = FileOutputStreamFactory.create(mFile);
      output.write(bytes);

      mCallback.onComplete(mFile.getAbsolutePath());

    } catch (IOException e) {
      mCallback.onError("IOError", "Failed saving image");
    } finally {
      mImage.close();
      if (null != output) {
        try {
          output.close();
        } catch (IOException e) {
          mCallback.onError("cameraAccess", e.getMessage());
        }
      }
    }
  }

  public interface Callback {
    void onComplete(String absolutePath);

    void onError(String errorCode, String errorMessage);
  }

  /** Factory class that assists in creating a {@link FileOutputStream} instance. */
  static class FileOutputStreamFactory {
    /**
     * Creates a new instance of the {@link FileOutputStream} class.
     *
     * <p>This method is visible for testing purposes only and should never be used outside this *
     * class.
     *
     * @param file - The file to create the output stream for
     * @return new instance of the {@link FileOutputStream} class.
     * @throws FileNotFoundException when the supplied file could not be found.
     */
    @VisibleForTesting
    public static FileOutputStream create(File file) throws FileNotFoundException {
      return new FileOutputStream(file);
    }
  }
}
