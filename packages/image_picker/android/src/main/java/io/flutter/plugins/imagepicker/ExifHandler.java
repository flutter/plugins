package io.flutter.plugins.imagepicker;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import androidx.exifinterface.media.ExifInterface;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class ExifHandler {

  public ExifInterface copyExif(final String filePathOri, String filePathDest) throws IOException {

      ExifInterface newExif = new ExifInterface(filePathDest);
     final ExifInterface originalExif = new ExifInterface(filePathOri);
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
        setIfNotNull(originalExif, newExif, attribute);
      }

      newExif.saveAttributes();

      return newExif;
  }

  private static void setIfNotNull(ExifInterface oldExif, ExifInterface newExif, String property) {
    if (oldExif.getAttribute(property) != null) {
      newExif.setAttribute(property, oldExif.getAttribute(property));
    }
  }

  // from : https://github.com/google/cameraview/issues/22#issuecomment-363047917
  public  Bitmap getNormalOrientationBitmap(String imageAbsolutePath)
    throws IOException {
    Bitmap bitmap = BitmapFactory.decodeFile(imageAbsolutePath);
    ExifInterface ei = new ExifInterface(imageAbsolutePath);

    int orientation =
      ei.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);

    Matrix matrix = new Matrix();
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
    }

    return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
  }

  public void setNormalOrientation(ExifInterface exif) throws IOException {
    exif.setAttribute(ExifInterface.TAG_ORIENTATION,
      String.valueOf(ExifInterface.ORIENTATION_NORMAL));
    exif.saveAttributes();
  }
}
