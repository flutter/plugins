package io.flutter.plugins.imagepicker.support;

import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.util.Log;
import androidx.exifinterface.media.ExifInterface;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class ExifUtils {

  public static void copyExif(String filePathOri, String filePathDest) {
    try {
      ExifInterface oldExif = new ExifInterface(filePathOri);
      ExifInterface newExif = new ExifInterface(filePathDest);

      List<String> attributes =
          Arrays.asList(
              "FNumber",
              "ExposureTime",
              "ISOSpeedRatings",
              "GPSAltitude",
              "GPSAltitudeRef",
              "FocalLength",
              "GPSDateStamp",
              "WhiteBalance",
              "GPSProcessingMethod",
              "GPSTimeStamp",
              "DateTime",
              "Flash",
              "GPSLatitude",
              "GPSLatitudeRef",
              "GPSLongitude",
              "GPSLongitudeRef",
              "Make",
              "Model",
              "Orientation");
      for (String attribute : attributes) {
        setIfNotNull(oldExif, newExif, attribute);
      }

      newExif.saveAttributes();

    } catch (Exception ex) {
      Log.e("ExifDataCopier", "Error preserving Exif data on selected image: " + ex);
    }
  }

  private static void setIfNotNull(ExifInterface oldExif, ExifInterface newExif, String property) {
    if (oldExif.getAttribute(property) != null) {
      newExif.setAttribute(property, oldExif.getAttribute(property));
    }
  }

  // from : https://github.com/google/cameraview/issues/22#issuecomment-363047917

  public static Bitmap modifyOrientation(
      int screenOrientation, Bitmap bitmap, String imageAbsolutePath) throws IOException {
    ExifInterface ei = new ExifInterface(imageAbsolutePath);
    int orientation =
        ei.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);

    final Matrix matrix = new Matrix();
    switch (orientation) {
      case ExifInterface.ORIENTATION_NORMAL:
        return bitmap;
      case ExifInterface.ORIENTATION_FLIP_HORIZONTAL:
        matrix.setScale(-1, 1);
        break;
      case ExifInterface.ORIENTATION_ROTATE_180:
        matrix.setRotate(180);
        break;
      case ExifInterface.ORIENTATION_FLIP_VERTICAL:
        matrix.setRotate(180);
        matrix.postScale(-1, 1);
        break;
      case ExifInterface.ORIENTATION_TRANSPOSE:
        matrix.setRotate(90);
        matrix.postScale(-1, 1);
        break;
      case ExifInterface.ORIENTATION_ROTATE_90:
        matrix.setRotate(90);
        break;
      case ExifInterface.ORIENTATION_TRANSVERSE:
        matrix.setRotate(-90);
        matrix.postScale(-1, 1);
        break;
      case ExifInterface.ORIENTATION_ROTATE_270:
        matrix.setRotate(-90);
        break;
      case ExifInterface.ORIENTATION_UNDEFINED:
        // The reported orientation is 0, meaning the image does not know it's orientation.
        // So we will try our best to guess which is the correct orientation.
        double width = ei.getAttributeDouble(ExifInterface.TAG_IMAGE_WIDTH, 0);
        double length = ei.getAttributeDouble(ExifInterface.TAG_IMAGE_LENGTH, 0);
        if (width != 0 && length != 0) {
          final boolean imageIsVertical = width < length;
          final boolean screenInPortrait = screenOrientation == Configuration.ORIENTATION_PORTRAIT;
          if (imageIsVertical && !screenInPortrait) {
            matrix.setRotate(-90);
          } else if (!imageIsVertical && screenInPortrait) {
            matrix.setRotate(90);
          }
        }
    }

    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
  }
}
