package io.flutter.plugins.imagepicker.support;

import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.util.Log;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

// From: https://stackoverflow.com/questions/31925712/android-getting-an-image-from-gallery-comes-rotated

public class ExifUtils {

  static public void copyExif(String filePathOri, String filePathDest) {
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
  public static Bitmap modifyOrientation(Bitmap bitmap, String imageAbsolutePath) throws IOException {
    ExifInterface ei = new ExifInterface(imageAbsolutePath);
    int orientation = ei.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);

    switch (orientation) {
      case ExifInterface.ORIENTATION_ROTATE_90:
        return rotate(bitmap, 90);

      case ExifInterface.ORIENTATION_ROTATE_180:
        return rotate(bitmap, 180);

      case ExifInterface.ORIENTATION_ROTATE_270:
        return rotate(bitmap, 270);

      case ExifInterface.ORIENTATION_FLIP_HORIZONTAL:
        return flip(bitmap, true, false);

      case ExifInterface.ORIENTATION_FLIP_VERTICAL:
        return flip(bitmap, false, true);

      default:
        return bitmap;
    }
  }

  public static Bitmap rotate(Bitmap bitmap, float degrees) {
    Matrix matrix = new Matrix();
    matrix.postRotate(degrees);
    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
  }

  public static Bitmap flip(Bitmap bitmap, boolean horizontal, boolean vertical) {
    Matrix matrix = new Matrix();
    matrix.preScale(horizontal ? -1 : 1, vertical ? -1 : 1);
    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
  }
}
