package io.flutter.plugins.firebasemlvision;

import android.content.ContentValues;
import android.content.Context;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.media.ExifInterface;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.File;
import java.io.IOException;

/** FirebaseMlVisionPlugin */
public class FirebaseMlVisionPlugin implements MethodCallHandler {
  private Registrar registrar;

  private FirebaseMlVisionPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_ml_vision");
    channel.setMethodCallHandler(new FirebaseMlVisionPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "BarcodeDetector#detectInImage":
        FirebaseVisionImage image = filePathToVisionImage((String) call.arguments, result);
        if (image != null) BarcodeDetector.instance.handleDetection(image, result);
        break;
      case "BarcodeDetector#close":
        BarcodeDetector.instance.close(result);
        break;
      case "FaceDetector#detectInImage":
        break;
      case "FaceDetector#close":
        break;
      case "LabelDetector#detectInImage":
        break;
      case "LabelDetector#close":
        break;
      case "TextDetector#detectInImage":
        image = filePathToVisionImage((String) call.arguments, result);
        if (image != null) TextDetector.instance.handleDetection(image, result);
        break;
      case "TextDetector#close":
        TextDetector.instance.close(result);
        break;
      default:
        result.notImplemented();
    }
  }

  private FirebaseVisionImage filePathToVisionImage(String path, Result result) {
    File file = new File(path);

    try {
      Bitmap bitmap = MediaStore.Images.Media.getBitmap(registrar.context().getContentResolver(), Uri.fromFile(file));
      int rotation = 0;
      int orientation = new ExifInterface(path).getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);

      switch (orientation) {
        case ExifInterface.ORIENTATION_ROTATE_90:
          rotation = 90;
          break;
        case ExifInterface.ORIENTATION_ROTATE_180:
          rotation = 180;
          break;
        case ExifInterface.ORIENTATION_ROTATE_270:
          rotation = 270;
          break;
      }
      Matrix matrix = new Matrix();
      matrix.postRotate(rotation);
      Bitmap rotatedImg = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
      return FirebaseVisionImage.fromBitmap(rotatedImg);
    } catch (IOException exception) {
      result.error("textDetectorIOError", exception.getLocalizedMessage(), null);
    }

    return null;
  }

//  private static int getOrientationFromMediaStore(Context context, String imagePath) {
//    Uri imageUri = getImageContentUri(context, imagePath);
//    if(imageUri == null) {
//      return -1;
//    }
//
//    String[] projection = {MediaStore.Images.ImageColumns.ORIENTATION};
//    Cursor cursor = context.getContentResolver().query(imageUri, projection, null, null, null);
//
//    int orientation = -1;
//    if (cursor != null && cursor.moveToFirst()) {
//      orientation = cursor.getInt(0);
//      cursor.close();
//    }
//
//    return orientation;
//  }
//
//  private static Uri getImageContentUri(Context context, String imagePath) {
//    String[] projection = new String[] {MediaStore.Images.Media._ID};
//    String selection = MediaStore.Images.Media.DATA + "=? ";
//    String[] selectionArgs = new String[] {imagePath};
//    Cursor cursor = context.getContentResolver().query(IMAGE_PROVIDER_URI, projection,
//      selection, selectionArgs, null);
//
//    if (cursor != null && cursor.moveToFirst()) {
//      int imageId = cursor.getInt(0);
//      cursor.close();
//
//      return Uri.withAppendedPath(IMAGE_PROVIDER_URI, Integer.toString(imageId));
//    }
//
//    if (new File(imagePath).exists()) {
//      ContentValues values = new ContentValues();
//      values.put(MediaStore.Images.Media.DATA, imagePath);
//
//      return context.getContentResolver().insert(
//        MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
//    }
//
//    return null;
//  }
}
