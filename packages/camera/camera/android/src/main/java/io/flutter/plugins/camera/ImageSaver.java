package io.flutter.plugins.camera;

import android.media.Image;
import android.os.Handler;
import android.os.Looper;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;

/** Saves a JPEG {@link Image} into the specified {@link File}. */
public class ImageSaver implements Runnable {

  /** The JPEG image */
  private final Image mImage;

  /** The file we save the image into. */
  private final File mFile;

  /** Used to finish the picture capture request */
  private final PictureCaptureRequest mPictureCaptureRequest;

  ImageSaver(Image image, File file, PictureCaptureRequest pictureCaptureRequest) {
    mImage = image;
    mFile = file;
    mPictureCaptureRequest = pictureCaptureRequest;
  }

  @Override
  public void run() {
    // We need to call the method channel stuff on main thread
    final Handler handler = new Handler(Looper.getMainLooper());

    ByteBuffer buffer = mImage.getPlanes()[0].getBuffer();
    byte[] bytes = new byte[buffer.remaining()];
    buffer.get(bytes);
    FileOutputStream output = null;
    try {
      output = new FileOutputStream(mFile);
      output.write(bytes);

      handler.post(
          new Runnable() {
            @Override
            public void run() {
              mPictureCaptureRequest.finish(mFile.getAbsolutePath());
            }
          });

    } catch (IOException e) {
      mPictureCaptureRequest.error("IOError", "Failed saving image", null);
    } finally {
      mImage.close();
      if (null != output) {
        try {
          output.close();
        } catch (IOException e) {
          handler.post(
              new Runnable() {
                @Override
                public void run() {
                  mPictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
                }
              });
        }
      }
    }
  }
}
