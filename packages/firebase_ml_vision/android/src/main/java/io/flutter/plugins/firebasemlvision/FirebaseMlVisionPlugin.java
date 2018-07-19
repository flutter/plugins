package io.flutter.plugins.firebasemlvision;

import android.app.Activity;
import android.app.Application;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.net.Uri;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.media.ExifInterface;
import android.util.Log;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
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
import io.flutter.plugins.firebasemlvision.live.LegacyCamera;

/**
 * FirebaseMlVisionPlugin
 */
public class FirebaseMlVisionPlugin implements MethodCallHandler {
  public static final int CAMERA_REQUEST_ID = 928291720;
  private Registrar registrar;
  private Activity activity;

  @Nullable
  private LegacyCamera camera;

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
            //TODO: handle camera permission requesting
//            if (camera != null && camera.getRequestingPermission()) {
//              camera.setRequestingPermission(false);
//              return;
//            }
            if (activity == FirebaseMlVisionPlugin.this.activity) {
              if (camera != null) {
                try {
                  camera.start(null);
                } catch (IOException ignored) {
                }
              }
            }
          }

          @Override
          public void onActivityPaused(Activity activity) {
            if (activity == FirebaseMlVisionPlugin.this.activity) {
              if (camera != null) {
                camera.stop();
              }
            }
          }

          @Override
          public void onActivityStopped(Activity activity) {
            if (activity == FirebaseMlVisionPlugin.this.activity) {
              if (camera != null) {
                camera.stop();
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
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "init":
        if (camera != null) {
          camera.stop();
        }
        result.success(null);
        break;
      case "availableCameras":
        List<Map<String, Object>> cameras = LegacyCamera.listAvailableCameraDetails();
        result.success(cameras);
        break;
      case "initialize":
        int cameraFacing = call.argument("cameraName");
        String resolutionPreset = call.argument("resolutionPreset");
        if (camera != null) {
          camera.stop();
        }
        camera = new LegacyCamera(registrar, resolutionPreset, cameraFacing); //new Camera(registrar, cameraName, resolutionPreset, result);
        camera.setMachineLearningFrameProcessor(TextDetector.instance);
        try {
          camera.start(new LegacyCamera.OnCameraOpenedCallback() {
            @Override
            public void onOpened(long textureId, int width, int height) {
              Map<String, Object> reply = new HashMap<>();
              reply.put("textureId", textureId);
              reply.put("previewWidth", width);
              reply.put("previewHeight", height);
              result.success(reply);
            }

            @Override
            public void onFailed(Exception e) {
              result.error("CameraInitializationError", e.getLocalizedMessage(), null);
            }
          });
        } catch (IOException e) {
          result.error("CameraInitializationError", e.getLocalizedMessage(), null);
        }
        break;
      case "dispose": {
        if (camera != null) {
          camera.release();
          camera = null;
        }
        result.success(null);
        break;
      }
      case "LiveView#setDetector":
        if (camera != null) {
          String detectorType = call.argument("detectorType");
          Detector detector;
          switch (detectorType) {
            case "text":
              detector = TextDetector.instance;
              break;
            case "barcode":
              detector = BarcodeDetector.instance;
              break;
            default:
              detector = TextDetector.instance;
          }
          camera.setMachineLearningFrameProcessor(detector);
        }
        result.success(null);
        break;
      case "BarcodeDetector#detectInImage":
        FirebaseVisionImage image = filePathToVisionImage((String) call.arguments, result);
        if (image != null) BarcodeDetector.instance.handleDetection(image, new Detector.OperationFinishedCallback() {
          @Override
          public void success(Detector detector, Object data) {
            result.success(data);
          }

          @Override
          public void error(DetectorException e) {
            e.sendError(result);
          }
        });
        break;
      case "BarcodeDetector#close":
        BarcodeDetector.instance.close(new Detector.OperationFinishedCallback() {
          @Override
          public void success(Detector detector, Object data) {
            result.success(null);
          }

          @Override
          public void error(DetectorException e) {
            e.sendError(result);
          }
        });
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
        if (image != null) TextDetector.instance.handleDetection(image, new Detector.OperationFinishedCallback() {
          @Override
          public void success(Detector detector, Object data) {
            result.success(data);
          }

          @Override
          public void error(DetectorException e) {
            e.sendError(result);
          }
        });
        break;
      case "TextDetector#close":
        TextDetector.instance.close(new Detector.OperationFinishedCallback() {
          @Override
          public void success(Detector detector, Object data) {
            result.success(null);
          }

          @Override
          public void error(DetectorException e) {
            e.sendError(result);
          }
        });
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
//          camera.continueRequestingPermissions();
        }
        return true;
      }
      return false;
    }
  }
}
