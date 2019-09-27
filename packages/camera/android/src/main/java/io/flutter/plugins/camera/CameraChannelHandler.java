package io.flutter.plugins.camera;

import android.app.Activity;
import android.hardware.camera2.CameraAccessException;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.TextureRegistry;

public class CameraChannelHandler implements MethodChannel.MethodCallHandler {

  private final CameraPermissions cameraPermissions = new CameraPermissions();
  private final Activity activity;
  private final TextureRegistry textureRegistry;
  private final BinaryMessenger messenger;
  private final EventChannel imageStreamChannel;
  private final CameraPermissions.Permissions permissions;
  private Camera camera;

  public CameraChannelHandler(
      @NonNull Activity activity,
      @NonNull TextureRegistry textureRegistry,
      @NonNull BinaryMessenger binaryMessenger,
      @NonNull EventChannel imageStreamChannel,
      @NonNull CameraPermissions.Permissions permissions
  ) {
    this.activity = activity;
    this.textureRegistry = textureRegistry;
    this.messenger = binaryMessenger;
    this.imageStreamChannel = imageStreamChannel;
    this.permissions = permissions;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final MethodChannel.Result result) {
    switch (call.method) {
      case "availableCameras":
        try {
          result.success(CameraUtils.getAvailableCameras(activity));
        } catch (Exception e) {
          handleException(e, result);
        }
        break;
      case "initialize":
      {
        if (camera != null) {
          camera.close();
        }
        cameraPermissions.requestPermissions(
            activity,
            permissions,
            call.argument("enableAudio"),
            (String errCode, String errDesc) -> {
              if (errCode == null) {
                try {
                  instantiateCamera(call, result);
                } catch (Exception e) {
                  handleException(e, result);
                }
              } else {
                result.error(errCode, errDesc, null);
              }
            });

        break;
      }
      case "takePicture":
      {
        camera.takePicture(call.argument("path"), result);
        break;
      }
      case "prepareForVideoRecording":
      {
        // This optimization is not required for Android.
        result.success(null);
        break;
      }
      case "startVideoRecording":
      {
        camera.startVideoRecording(call.argument("filePath"), result);
        break;
      }
      case "stopVideoRecording":
      {
        camera.stopVideoRecording(result);
        break;
      }
      case "pauseVideoRecording":
      {
        camera.pauseVideoRecording(result);
        break;
      }
      case "resumeVideoRecording":
      {
        camera.resumeVideoRecording(result);
        break;
      }
      case "startImageStream":
      {
        try {
          camera.startPreviewWithImageStream(imageStreamChannel);
          result.success(null);
        } catch (Exception e) {
          handleException(e, result);
        }
        break;
      }
      case "stopImageStream":
      {
        try {
          camera.startPreview();
          result.success(null);
        } catch (Exception e) {
          handleException(e, result);
        }
        break;
      }
      case "dispose":
      {
        if (camera != null) {
          camera.dispose();
        }
        result.success(null);
        break;
      }
      default:
        result.notImplemented();
        break;
    }
  }

  private void instantiateCamera(MethodCall call, MethodChannel.Result result) throws CameraAccessException {
    String cameraName = call.argument("cameraName");
    String resolutionPreset = call.argument("resolutionPreset");
    boolean enableAudio = call.argument("enableAudio");
    camera = new Camera(activity, textureRegistry, cameraName, resolutionPreset, enableAudio);

    EventChannel cameraEventChannel =
        new EventChannel(
            messenger,
            "flutter.io/cameraPlugin/cameraEvents" + camera.getFlutterTexture().id());
    camera.setupCameraEventChannel(cameraEventChannel);

    camera.open(result);
  }

  // We move catching CameraAccessException out of onMethodCall because it causes a crash
  // on plugin registration for sdks incompatible with Camera2 (< 21). We want this plugin to
  // to be able to compile with <21 sdks for apps that want the camera and support earlier version.
  @SuppressWarnings("ConstantConditions")
  private void handleException(Exception exception, MethodChannel.Result result) {
    if (exception instanceof CameraAccessException) {
      result.error("CameraAccess", exception.getMessage(), null);
    }

    throw (RuntimeException) exception;
  }
}
