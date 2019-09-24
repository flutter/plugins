// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.plugins.camera;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraManager;
import android.icu.util.CurrencyAmount;
import android.os.Build;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.TextureRegistry;

public class CameraPlugin implements FlutterPlugin, ActivityAware, MethodCallHandler {

  private EventChannel imageStreamChannel;
  private Camera camera;

  private FlutterPluginBinding pluginBinding;
  private ActivityPluginBinding activityBinding;

  private final CameraPermissions.CameraPermissionsDelegate permissionsDelegate = new CameraPermissions.CameraPermissionsDelegate() {
    @Override
    public boolean hasCameraPermission() {
      return ContextCompat.checkSelfPermission(activityBinding.getActivity(), Manifest.permission.CAMERA)
          == PackageManager.PERMISSION_GRANTED;
    }

    @Override
    public boolean hasAudioPermission() {
      return ContextCompat.checkSelfPermission(activityBinding.getActivity(), Manifest.permission.RECORD_AUDIO)
          == PackageManager.PERMISSION_GRANTED;
    }

    @Override
    public void requestPermission(boolean enableAudio, int requestCode) {
      ActivityCompat.requestPermissions(
          activityBinding.getActivity(),
          enableAudio
              ? new String[] {Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO}
              : new String[] {Manifest.permission.CAMERA},
          requestCode);
    }

    @Override
    public void addRequestPermissionsResultListener(@NonNull PluginRegistry.RequestPermissionsResultListener listener) {
      activityBinding.addRequestPermissionsResultListener(listener);
    }
  };
  private final CameraPermissions cameraPermissions = new CameraPermissions(permissionsDelegate);

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = flutterPluginBinding;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.pluginBinding = null;
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    // Setup
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
      // When a background flutter view tries to register the plugin, the registrar has no activity.
      // We stop the registration process as this plugin is foreground only. Also, if the sdk is
      // less than 21 (min sdk for Camera2) we don't register the plugin.
      return;
    }

    this.activityBinding = activityPluginBinding;

    this.imageStreamChannel = new EventChannel(
        this.pluginBinding.getFlutterEngine().getDartExecutor(),
        "plugins.flutter.io/camera/imageStream"
    );

    final MethodChannel channel =
        new MethodChannel(pluginBinding.getFlutterEngine().getDartExecutor(), "plugins.flutter.io/camera");

    channel.setMethodCallHandler(this);
  }

  // TODO: there are 2+ channels
  // 1:EventChannel   - plugins.flutter.io/camera/imageStream
  // 1:MethodChannel  - plugins.flutter.io/camera
  // 0+:EventChannel  - flutter.io/cameraPlugin/cameraEvents[textureId]

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    // Ignore
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    // Ignore
  }

  @Override
  public void onDetachedFromActivity() {
    // Teardown
    this.activityBinding = null;
  }

  private void instantiateCamera(MethodCall call, Result result) throws CameraAccessException {
    String cameraName = call.argument("cameraName");
    String resolutionPreset = call.argument("resolutionPreset");
    boolean enableAudio = call.argument("enableAudio");
    TextureRegistry.SurfaceTextureEntry textureEntry = pluginBinding
        .getFlutterEngine()
        .getRenderer()
        .createSurfaceTexture();

    camera = new Camera(
        activityBinding.getActivity(),
        (CameraManager) activityBinding.getActivity().getSystemService(Context.CAMERA_SERVICE),
        textureEntry,
        cameraName,
        resolutionPreset,
        enableAudio
    );

    camera.open(new Camera.OnCameraOpenedCallback() {
      @Override
      public void onCameraOpened(long textureId, int previewWidth, int previewHeight) {
        Map<String, Object> reply = new HashMap<>();
        reply.put("textureId", textureId);
        reply.put("previewWidth", previewWidth);
        reply.put("previewHeight", previewHeight);
        result.success(reply);
      }

      @Override
      public void onCameraOpenFailed(@NonNull String message) {
        result.error("CameraAccess", message, null);
      }
    });

    EventChannel cameraEventChannel = new EventChannel(
        pluginBinding.getFlutterEngine().getDartExecutor(),
        "flutter.io/cameraPlugin/cameraEvents" + textureEntry.id()
    );
    cameraEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object o, final EventChannel.EventSink eventSink) {
        final Camera.CameraEventHandler cameraEventHandler = new Camera.CameraEventHandler() {
          @Override
          public void onError(String description) {
            Map<String, String> event = new HashMap<>();
            event.put("eventType", "error");
            event.put("errorDescription", description);
            eventSink.success(event);
          }

          @Override
          public void onCameraClosed() {
            Map<String, String> event = new HashMap<>();
            event.put("eventType", "camera_closing");
            eventSink.success(event);
          }
        };

        camera.setCameraEventHandler(cameraEventHandler);
      }

      @Override
      public void onCancel(Object o) {
        camera.setCameraEventHandler(null);
      }
    });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    switch (call.method) {
      case "availableCameras":
        try {
          result.success(CameraUtils.getAvailableCameras(activityBinding.getActivity()));
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
          final String filePath = call.argument("path");
          camera.takePicture(filePath, new Camera.OnPictureTakenCallback() {
            @Override
            public void onPictureTaken() {
              result.success(null);
            }

            @Override
            public void onFileAlreadyExists() {
              result.error(
                  "fileExists",
                  "File at path '" + filePath + "' already exists. Cannot overwrite.",
                  null
              );
            }

            @Override
            public void onFailedToSaveImage() {
              result.error("IOError", "Failed saving image", null);
            }

            @Override
            public void onCaptureFailure(@NonNull String reason) {
              result.error("captureFailure", reason, null);
            }

            @Override
            public void onCameraAccessFailure(@NonNull String message) {
              result.error("cameraAccess", message, null);
            }
          });
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
          String filePath = call.argument("filePath");
          try {
            camera.startVideoRecording(filePath);
          } catch (IllegalStateException e) {
            result.error("fileExists", "File at path '" + filePath + "' already exists.", null);
          } catch (CameraAccessException | IOException e) {
            result.error("videoRecordingFailed", e.getMessage(), null);
          }
          break;
        }
      case "stopVideoRecording":
        {
          try {
            camera.stopVideoRecording();
          } catch (CameraAccessException | IllegalStateException e) {
            result.error("videoRecordingFailed", e.getMessage(), null);
          }
          break;
        }
      case "pauseVideoRecording":
        {
          try {
            camera.pauseVideoRecording();
          } catch (UnsupportedOperationException e) {
            result.error("videoRecordingFailed", "pauseVideoRecording requires Android API +24.", null);
          } catch (IllegalStateException e) {
            result.error("videoRecordingFailed", e.getMessage(), null);
          }
          break;
        }
      case "resumeVideoRecording":
        {
          try {
            camera.resumeVideoRecording();
          } catch (UnsupportedOperationException e) {
            result.error("videoRecordingFailed","resumeVideoRecording requires Android API +24.",null);
          } catch (IllegalStateException e) {
            result.error("videoRecordingFailed", e.getMessage(), null);
          }
          break;
        }
      case "startImageStream":
        {
          try {
            CameraPreviewDisplay previewDisplay = new CameraPreviewDisplay(imageStreamChannel);
            camera.startPreviewWithImageStream(previewDisplay);
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

  // We move catching CameraAccessException out of onMethodCall because it causes a crash
  // on plugin registration for sdks incompatible with Camera2 (< 21). We want this plugin to
  // to be able to compile with <21 sdks for apps that want the camera and support earlier version.
  @SuppressWarnings("ConstantConditions")
  private void handleException(Exception exception, Result result) {
    if (exception instanceof CameraAccessException) {
      result.error("CameraAccess", exception.getMessage(), null);
    }

    throw (RuntimeException) exception;
  }
}
