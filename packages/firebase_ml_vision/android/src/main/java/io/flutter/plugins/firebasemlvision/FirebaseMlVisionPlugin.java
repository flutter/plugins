package io.flutter.plugins.firebasemlvision;

import android.app.Activity;
import android.app.Application;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.hardware.camera2.CameraAccessException;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.media.ExifInterface;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.firebasemlvision.live.Camera;
import io.flutter.plugins.firebasemlvision.live.CameraInfo;
import io.flutter.plugins.firebasemlvision.live.CameraInfoException;
import io.flutter.view.FlutterView;

/**
 * FirebaseMlVisionPlugin
 */
public class FirebaseMlVisionPlugin implements MethodCallHandler {
  public static final int CAMERA_REQUEST_ID = 928291720;
  private Registrar registrar;
  private Activity activity;

  @Nullable
  private Camera camera;

  private FirebaseMlVisionPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.activity = registrar.activity();

    registrar.addRequestPermissionsResultListener(new CameraRequestPermissionsListener());

    activity
      .getApplication()
      .registerActivityLifecycleCallbacks(
        new Application.ActivityLifecycleCallbacks() {
          @Override
          public void onActivityCreated(Activity activity, Bundle savedInstanceState) {
          }

          @Override
          public void onActivityStarted(Activity activity) {
          }

          @Override
          public void onActivityResumed(Activity activity) {
            if (camera != null && camera.getRequestingPermission()) {
              camera.setRequestingPermission(false);
              return;
            }
            if (activity == FirebaseMlVisionPlugin.this.activity) {
              if (camera != null) {
                camera.open(null);
              }
            }
          }

          @Override
          public void onActivityPaused(Activity activity) {
            if (activity == FirebaseMlVisionPlugin.this.activity) {
              if (camera != null) {
                camera.close();
              }
            }
          }

          @Override
          public void onActivityStopped(Activity activity) {
            if (activity == FirebaseMlVisionPlugin.this.activity) {
              if (camera != null) {
                camera.close();
              }
            }
          }

          @Override
          public void onActivitySaveInstanceState(Activity activity, Bundle outState) {
          }

          @Override
          public void onActivityDestroyed(Activity activity) {
          }
        });
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
      new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_ml_vision");
    channel.setMethodCallHandler(new FirebaseMlVisionPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "init":
        if (camera != null) {
          camera.close();
        }
        result.success(null);
        break;
      case "availableCameras":
        try {
          List<Map<String, Object>> cameras = CameraInfo.getAvailableCameras(registrar.activeContext());
          result.success(cameras);
        } catch (CameraInfoException e) {
          result.error("cameraAccess", e.getMessage(), null);
        }
        break;
      case "initialize":
        String cameraName = call.argument("cameraName");
        String resolutionPreset = call.argument("resolutionPreset");
        if (camera != null) {
          camera.close();
        }
        camera = new Camera(registrar, cameraName, resolutionPreset, result);
        break;
      case "dispose": {
        if (camera != null) {
          camera.dispose();
          camera = null;
        }
        result.success(null);
        break;
      }
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

  private class CameraRequestPermissionsListener
    implements PluginRegistry.RequestPermissionsResultListener {
    @Override
    public boolean onRequestPermissionsResult(int id, String[] permissions, int[] grantResults) {
      if (id == CAMERA_REQUEST_ID) {
        if (camera != null) {
          camera.continueRequestingPermissions();
        }
        return true;
      }
      return false;
    }
  }
}
