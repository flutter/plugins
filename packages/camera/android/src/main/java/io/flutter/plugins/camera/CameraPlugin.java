package io.flutter.plugins.camera;

import static android.view.OrientationEventListener.ORIENTATION_UNKNOWN;

import android.Manifest;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.ImageFormat;
import android.graphics.Point;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureFailure;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Bundle;
import android.util.Size;
import android.view.Display;
import android.view.OrientationEventListener;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterView;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CameraPlugin implements MethodCallHandler {

  private static final int CAMERA_REQUEST_ID = 513469796;
  private static final String TAG = "CameraPlugin";

  private static CameraManager cameraManager;
  private final FlutterView view;
  private Camera camera;
  private Activity activity;
  private Registrar registrar;
  private Application.ActivityLifecycleCallbacks activityLifecycleCallbacks;
  // The code to run after requesting camera permissions.
  private Runnable cameraPermissionContinuation;
  private boolean requestingPermission;
  private final OrientationEventListener orientationEventListener;
  private int currentOrientation = ORIENTATION_UNKNOWN;

  private CameraPlugin(Registrar registrar, FlutterView view, Activity activity) {
    this.registrar = registrar;
    this.view = view;
    this.activity = activity;

    orientationEventListener =
        new OrientationEventListener(activity.getApplicationContext()) {
          @Override
          public void onOrientationChanged(int i) {
            if (i == ORIENTATION_UNKNOWN) {
              return;
            }
            // Convert the raw deg angle to the nearest multiple of 90.
            currentOrientation = (int) Math.round(i / 90.0) * 90;
          }
        };

    registrar.addRequestPermissionsResultListener(new CameraRequestPermissionsListener());

    this.activityLifecycleCallbacks =
        new Application.ActivityLifecycleCallbacks() {
          @Override
          public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

          @Override
          public void onActivityStarted(Activity activity) {}

          @Override
          public void onActivityResumed(Activity activity) {
            if (requestingPermission) {
              requestingPermission = false;
              return;
            }
            if (activity == CameraPlugin.this.activity) {
              orientationEventListener.enable();
              if (camera != null) {
                camera.open(null);
              }
            }
          }

          @Override
          public void onActivityPaused(Activity activity) {
            if (activity == CameraPlugin.this.activity) {
              orientationEventListener.disable();
              if (camera != null) {
                camera.close();
              }
            }
          }

          @Override
          public void onActivityStopped(Activity activity) {
            if (activity == CameraPlugin.this.activity) {
              if (camera != null) {
                camera.close();
              }
            }
          }

          @Override
          public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

          @Override
          public void onActivityDestroyed(Activity activity) {}
        };
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/camera");

    cameraManager = (CameraManager) registrar.activity().getSystemService(Context.CAMERA_SERVICE);

    channel.setMethodCallHandler(
        new CameraPlugin(registrar, registrar.view(), registrar.activity()));
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "availableCameras":
        try {
          String[] cameraNames = cameraManager.getCameraIdList();
          List<Map<String, Object>> cameras = new ArrayList<>();
          for (String cameraName : cameraNames) {
            HashMap<String, Object> details = new HashMap<>();
            CameraCharacteristics characteristics =
                cameraManager.getCameraCharacteristics(cameraName);
            details.put("name", cameraName);
            @SuppressWarnings("ConstantConditions")
            int lensFacing = characteristics.get(CameraCharacteristics.LENS_FACING);
            switch (lensFacing) {
              case CameraMetadata.LENS_FACING_FRONT:
                details.put("lensFacing", "front");
                break;
              case CameraMetadata.LENS_FACING_BACK:
                details.put("lensFacing", "back");
                break;
              case CameraMetadata.LENS_FACING_EXTERNAL:
                details.put("lensFacing", "external");
                break;
            }
            cameras.add(details);
          }
          result.success(cameras);
        } catch (CameraAccessException e) {
          result.error("cameraAccess", e.getMessage(), null);
        }
        break;
      case "initialize":
        {
          String cameraName = call.argument("cameraName");
          String resolutionPreset = call.argument("resolutionPreset");
          if (camera != null) {
            camera.close();
          }
          camera = new Camera(cameraName, resolutionPreset, result);
          this.activity
              .getApplication()
              .registerActivityLifecycleCallbacks(this.activityLifecycleCallbacks);
          orientationEventListener.enable();
          break;
        }
      case "takePicture":
        {
          camera.takePicture((String) call.argument("path"), result);
          break;
        }
      case "startVideoRecording":
        {
          final String filePath = call.argument("filePath");
          camera.startVideoRecording(filePath, result);
          break;
        }
      case "stopVideoRecording":
        {
          camera.stopVideoRecording(result);
          break;
        }
      case "startImageStream":
        {
          try {
            camera.startPreviewWithImageStream();
            result.success(null);
          } catch (CameraAccessException e) {
            result.error("CameraAccess", e.getMessage(), null);
          }
          break;
        }
      case "stopImageStream":
        {
          try {
            camera.startPreview();
            result.success(null);
          } catch (CameraAccessException e) {
            result.error("CameraAccess", e.getMessage(), null);
          }
          break;
        }
      case "dispose":
        {
          if (camera != null) {
            camera.dispose();
          }
          if (this.activity != null && this.activityLifecycleCallbacks != null) {
            this.activity
                .getApplication()
                .unregisterActivityLifecycleCallbacks(this.activityLifecycleCallbacks);
          }
          result.success(null);
          break;
        }
      default:
        result.notImplemented();
        break;
    }
  }

  private static class CompareSizesByArea implements Comparator<Size> {
    @Override
    public int compare(Size lhs, Size rhs) {
      // We cast here to ensure the multiplications won't overflow.
      return Long.signum(
          (long) lhs.getWidth() * lhs.getHeight() - (long) rhs.getWidth() * rhs.getHeight());
    }
  }

  private class CameraRequestPermissionsListener
      implements PluginRegistry.RequestPermissionsResultListener {
    @Override
    public boolean onRequestPermissionsResult(int id, String[] permissions, int[] grantResults) {
      if (id == CAMERA_REQUEST_ID) {
        cameraPermissionContinuation.run();
        return true;
      }
      return false;
    }
  }

  private class Camera {
    private final FlutterView.SurfaceTextureEntry textureEntry;
    private CameraDevice cameraDevice;
    private CameraCaptureSession cameraCaptureSession;
    private EventChannel.EventSink eventSink;
    private ImageReader pictureImageReader;
    private ImageReader imageStreamReader;
    private int sensorOrientation;
    private boolean isFrontFacing;
    private String cameraName;
    private Size captureSize;
    private Size previewSize;
    private CaptureRequest.Builder captureRequestBuilder;
    private Size videoSize;
    private MediaRecorder mediaRecorder;
    private boolean recordingVideo;

    Camera(final String cameraName, final String resolutionPreset, @NonNull final Result result) {

      this.cameraName = cameraName;
      textureEntry = view.createSurfaceTexture();

      registerEventChannel();

      try {
        int minHeight;
        switch (resolutionPreset) {
          case "high":
            minHeight = 720;
            break;
          case "medium":
            minHeight = 480;
            break;
          case "low":
            minHeight = 240;
            break;
          default:
            throw new IllegalArgumentException("Unknown preset: " + resolutionPreset);
        }

        CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
        StreamConfigurationMap streamConfigurationMap =
            characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
        //noinspection ConstantConditions
        sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
        //noinspection ConstantConditions
        isFrontFacing =
            characteristics.get(CameraCharacteristics.LENS_FACING)
                == CameraMetadata.LENS_FACING_FRONT;
        computeBestCaptureSize(streamConfigurationMap);
        computeBestPreviewAndRecordingSize(streamConfigurationMap, minHeight, captureSize);

        if (cameraPermissionContinuation != null) {
          result.error("cameraPermission", "Camera permission request ongoing", null);
        }
        cameraPermissionContinuation =
            new Runnable() {
              @Override
              public void run() {
                cameraPermissionContinuation = null;
                if (!hasCameraPermission()) {
                  result.error(
                      "cameraPermission", "MediaRecorderCamera permission not granted", null);
                  return;
                }
                if (!hasAudioPermission()) {
                  result.error(
                      "cameraPermission", "MediaRecorderAudio permission not granted", null);
                  return;
                }
                open(result);
              }
            };
        requestingPermission = false;
        if (hasCameraPermission() && hasAudioPermission()) {
          cameraPermissionContinuation.run();
        } else {
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestingPermission = true;
            registrar
                .activity()
                .requestPermissions(
                    new String[] {Manifest.permission.CAMERA, Manifest.permission.RECORD_AUDIO},
                    CAMERA_REQUEST_ID);
          }
        }
      } catch (CameraAccessException e) {
        result.error("CameraAccess", e.getMessage(), null);
      } catch (IllegalArgumentException e) {
        result.error("IllegalArgumentException", e.getMessage(), null);
      }
    }

    private void registerEventChannel() {
      new EventChannel(
              registrar.messenger(), "flutter.io/cameraPlugin/cameraEvents" + textureEntry.id())
          .setStreamHandler(
              new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object arguments, EventChannel.EventSink eventSink) {
                  Camera.this.eventSink = eventSink;
                }

                @Override
                public void onCancel(Object arguments) {
                  Camera.this.eventSink = null;
                }
              });
    }

    private boolean hasCameraPermission() {
      return Build.VERSION.SDK_INT < Build.VERSION_CODES.M
          || activity.checkSelfPermission(Manifest.permission.CAMERA)
              == PackageManager.PERMISSION_GRANTED;
    }

    private boolean hasAudioPermission() {
      return Build.VERSION.SDK_INT < Build.VERSION_CODES.M
          || registrar.activity().checkSelfPermission(Manifest.permission.RECORD_AUDIO)
              == PackageManager.PERMISSION_GRANTED;
    }

    private void computeBestPreviewAndRecordingSize(
        StreamConfigurationMap streamConfigurationMap, int minHeight, Size captureSize) {
      Size[] sizes = streamConfigurationMap.getOutputSizes(SurfaceTexture.class);

      // Preview size and video size should not be greater than screen resolution or 1080.
      Point screenResolution = new Point();
      Display display = activity.getWindowManager().getDefaultDisplay();
      display.getRealSize(screenResolution);

      final boolean swapWH = getMediaOrientation() % 180 == 90;
      int screenWidth = swapWH ? screenResolution.y : screenResolution.x;
      int screenHeight = swapWH ? screenResolution.x : screenResolution.y;

      List<Size> goodEnough = new ArrayList<>();
      for (Size s : sizes) {
        if (minHeight <= s.getHeight()
            && s.getWidth() <= screenWidth
            && s.getHeight() <= screenHeight
            && s.getHeight() <= 1080) {
          goodEnough.add(s);
        }
      }

      Collections.sort(goodEnough, new CompareSizesByArea());

      if (goodEnough.isEmpty()) {
        previewSize = sizes[0];
        videoSize = sizes[0];
      } else {
        float captureSizeRatio = (float) captureSize.getWidth() / captureSize.getHeight();

        previewSize = goodEnough.get(0);
        for (Size s : goodEnough) {
          if ((float) s.getWidth() / s.getHeight() == captureSizeRatio) {
            previewSize = s;
            break;
          }
        }

        Collections.reverse(goodEnough);
        videoSize = goodEnough.get(0);
        for (Size s : goodEnough) {
          if ((float) s.getWidth() / s.getHeight() == captureSizeRatio) {
            videoSize = s;
            break;
          }
        }
      }
    }

    private void computeBestCaptureSize(StreamConfigurationMap streamConfigurationMap) {
      // For still image captures, we use the largest available size.
      captureSize =
          Collections.max(
              Arrays.asList(streamConfigurationMap.getOutputSizes(ImageFormat.JPEG)),
              new CompareSizesByArea());
    }

    private void prepareMediaRecorder(String outputFilePath) throws IOException {
      if (mediaRecorder != null) {
        mediaRecorder.release();
      }
      mediaRecorder = new MediaRecorder();
      mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
      mediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
      mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
      mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
      mediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
      mediaRecorder.setVideoEncodingBitRate(1024 * 1000);
      mediaRecorder.setAudioSamplingRate(16000);
      mediaRecorder.setVideoFrameRate(27);
      mediaRecorder.setVideoSize(videoSize.getWidth(), videoSize.getHeight());
      mediaRecorder.setOutputFile(outputFilePath);
      mediaRecorder.setOrientationHint(getMediaOrientation());

      mediaRecorder.prepare();
    }

    private void open(@Nullable final Result result) {
      if (!hasCameraPermission()) {
        if (result != null) result.error("cameraPermission", "Camera permission not granted", null);
      } else {
        try {
          pictureImageReader =
              ImageReader.newInstance(
                  captureSize.getWidth(), captureSize.getHeight(), ImageFormat.JPEG, 2);

          // Used to steam image byte data to dart side.
          imageStreamReader =
              ImageReader.newInstance(
                  previewSize.getWidth(), previewSize.getHeight(), ImageFormat.YUV_420_888, 2);

          cameraManager.openCamera(
              cameraName,
              new CameraDevice.StateCallback() {
                @Override
                public void onOpened(@NonNull CameraDevice cameraDevice) {
                  Camera.this.cameraDevice = cameraDevice;
                  try {
                    startPreview();
                  } catch (CameraAccessException e) {
                    if (result != null) result.error("CameraAccess", e.getMessage(), null);
                    cameraDevice.close();
                    Camera.this.cameraDevice = null;
                    return;
                  }

                  if (result != null) {
                    Map<String, Object> reply = new HashMap<>();
                    reply.put("textureId", textureEntry.id());
                    reply.put("previewWidth", previewSize.getWidth());
                    reply.put("previewHeight", previewSize.getHeight());
                    result.success(reply);
                  }
                }

                @Override
                public void onClosed(@NonNull CameraDevice camera) {
                  if (eventSink != null) {
                    Map<String, String> event = new HashMap<>();
                    event.put("eventType", "cameraClosing");
                    eventSink.success(event);
                  }
                  super.onClosed(camera);
                }

                @Override
                public void onDisconnected(@NonNull CameraDevice cameraDevice) {
                  cameraDevice.close();
                  Camera.this.cameraDevice = null;
                  sendErrorEvent("The camera was disconnected.");
                }

                @Override
                public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
                  cameraDevice.close();
                  Camera.this.cameraDevice = null;
                  String errorDescription;
                  switch (errorCode) {
                    case ERROR_CAMERA_IN_USE:
                      errorDescription = "The camera device is in use already.";
                      break;
                    case ERROR_MAX_CAMERAS_IN_USE:
                      errorDescription = "Max cameras in use";
                      break;
                    case ERROR_CAMERA_DISABLED:
                      errorDescription =
                          "The camera device could not be opened due to a device policy.";
                      break;
                    case ERROR_CAMERA_DEVICE:
                      errorDescription = "The camera device has encountered a fatal error";
                      break;
                    case ERROR_CAMERA_SERVICE:
                      errorDescription = "The camera service has encountered a fatal error.";
                      break;
                    default:
                      errorDescription = "Unknown camera error";
                  }
                  sendErrorEvent(errorDescription);
                }
              },
              null);
        } catch (CameraAccessException e) {
          if (result != null) result.error("cameraAccess", e.getMessage(), null);
        }
      }
    }

    private void writeToFile(ByteBuffer buffer, File file) throws IOException {
      try (FileOutputStream outputStream = new FileOutputStream(file)) {
        while (0 < buffer.remaining()) {
          outputStream.getChannel().write(buffer);
        }
      }
    }

    private void takePicture(String filePath, @NonNull final Result result) {
      final File file = new File(filePath);

      if (file.exists()) {
        result.error(
            "fileExists",
            "File at path '" + filePath + "' already exists. Cannot overwrite.",
            null);
        return;
      }

      pictureImageReader.setOnImageAvailableListener(
          new ImageReader.OnImageAvailableListener() {
            @Override
            public void onImageAvailable(ImageReader reader) {
              try (Image image = reader.acquireLatestImage()) {
                ByteBuffer buffer = image.getPlanes()[0].getBuffer();
                writeToFile(buffer, file);
                result.success(null);
              } catch (IOException e) {
                result.error("IOError", "Failed saving image", null);
              }
            }
          },
          null);

      try {
        final CaptureRequest.Builder captureBuilder =
            cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
        captureBuilder.addTarget(pictureImageReader.getSurface());
        captureBuilder.set(CaptureRequest.JPEG_ORIENTATION, getMediaOrientation());

        cameraCaptureSession.capture(
            captureBuilder.build(),
            new CameraCaptureSession.CaptureCallback() {
              @Override
              public void onCaptureFailed(
                  @NonNull CameraCaptureSession session,
                  @NonNull CaptureRequest request,
                  @NonNull CaptureFailure failure) {
                String reason;
                switch (failure.getReason()) {
                  case CaptureFailure.REASON_ERROR:
                    reason = "An error happened in the framework";
                    break;
                  case CaptureFailure.REASON_FLUSHED:
                    reason = "The capture has failed due to an abortCaptures() call";
                    break;
                  default:
                    reason = "Unknown reason";
                }
                result.error("captureFailure", reason, null);
              }
            },
            null);
      } catch (CameraAccessException e) {
        result.error("cameraAccess", e.getMessage(), null);
      }
    }

    private void startVideoRecording(String filePath, @NonNull final Result result) {
      if (cameraDevice == null) {
        result.error("configureFailed", "Camera was closed during configuration.", null);
        return;
      }
      if (new File(filePath).exists()) {
        result.error(
            "fileExists",
            "File at path '" + filePath + "' already exists. Cannot overwrite.",
            null);
        return;
      }
      try {
        closeCaptureSession();
        prepareMediaRecorder(filePath);

        recordingVideo = true;

        SurfaceTexture surfaceTexture = textureEntry.surfaceTexture();
        surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
        captureRequestBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);

        List<Surface> surfaces = new ArrayList<>();

        Surface previewSurface = new Surface(surfaceTexture);
        surfaces.add(previewSurface);
        captureRequestBuilder.addTarget(previewSurface);

        Surface recorderSurface = mediaRecorder.getSurface();
        surfaces.add(recorderSurface);
        captureRequestBuilder.addTarget(recorderSurface);

        cameraDevice.createCaptureSession(
            surfaces,
            new CameraCaptureSession.StateCallback() {
              @Override
              public void onConfigured(@NonNull CameraCaptureSession cameraCaptureSession) {
                try {
                  if (cameraDevice == null) {
                    result.error("configureFailed", "Camera was closed during configuration", null);
                    return;
                  }
                  Camera.this.cameraCaptureSession = cameraCaptureSession;
                  captureRequestBuilder.set(
                      CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
                  cameraCaptureSession.setRepeatingRequest(
                      captureRequestBuilder.build(), null, null);
                  mediaRecorder.start();
                  result.success(null);
                } catch (CameraAccessException e) {
                  result.error("cameraAccess", e.getMessage(), null);
                }
              }

              @Override
              public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
                result.error("configureFailed", "Failed to configure camera session", null);
              }
            },
            null);
      } catch (CameraAccessException | IOException e) {
        result.error("videoRecordingFailed", e.getMessage(), null);
      }
    }

    private void stopVideoRecording(@NonNull final Result result) {
      if (!recordingVideo) {
        result.success(null);
        return;
      }

      try {
        recordingVideo = false;
        mediaRecorder.stop();
        mediaRecorder.reset();
        startPreview();
        result.success(null);
      } catch (CameraAccessException | IllegalStateException e) {
        result.error("videoRecordingFailed", e.getMessage(), null);
      }
    }

    private void startPreview() throws CameraAccessException {
      closeCaptureSession();

      SurfaceTexture surfaceTexture = textureEntry.surfaceTexture();
      surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
      captureRequestBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);

      List<Surface> surfaces = new ArrayList<>();

      Surface previewSurface = new Surface(surfaceTexture);
      surfaces.add(previewSurface);
      captureRequestBuilder.addTarget(previewSurface);

      surfaces.add(pictureImageReader.getSurface());

      cameraDevice.createCaptureSession(
          surfaces,
          new CameraCaptureSession.StateCallback() {

            @Override
            public void onConfigured(@NonNull CameraCaptureSession session) {
              if (cameraDevice == null) {
                sendErrorEvent("The camera was closed during configuration.");
                return;
              }
              try {
                cameraCaptureSession = session;
                captureRequestBuilder.set(
                    CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
                cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
              } catch (CameraAccessException e) {
                sendErrorEvent(e.getMessage());
              }
            }

            @Override
            public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
              sendErrorEvent("Failed to configure the camera for preview.");
            }
          },
          null);
    }

    private void startPreviewWithImageStream() throws CameraAccessException {
      closeCaptureSession();

      SurfaceTexture surfaceTexture = textureEntry.surfaceTexture();
      surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());

      captureRequestBuilder =
          cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);

      List<Surface> surfaces = new ArrayList<>();

      Surface previewSurface = new Surface(surfaceTexture);
      surfaces.add(previewSurface);
      captureRequestBuilder.addTarget(previewSurface);

      surfaces.add(imageStreamReader.getSurface());
      captureRequestBuilder.addTarget(imageStreamReader.getSurface());

      cameraDevice.createCaptureSession(
          surfaces,
          new CameraCaptureSession.StateCallback() {
            @Override
            public void onConfigured(@NonNull CameraCaptureSession session) {
              if (cameraDevice == null) {
                sendErrorEvent("The camera was closed during configuration.");
                return;
              }
              try {
                cameraCaptureSession = session;
                captureRequestBuilder.set(
                    CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
                cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
              } catch (CameraAccessException e) {
                sendErrorEvent(e.getMessage());
              }
            }

            @Override
            public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
              sendErrorEvent("Failed to configure the camera for streaming images.");
            }
          },
          null);

      registerImageStreamEventChannel();
    }

    private void registerImageStreamEventChannel() {
      final EventChannel imageStreamChannel =
          new EventChannel(registrar.messenger(), "plugins.flutter.io/camera/imageStream");

      imageStreamChannel.setStreamHandler(
          new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object o, EventChannel.EventSink eventSink) {
              setImageStreamImageAvailableListener(eventSink);
            }

            @Override
            public void onCancel(Object o) {
              imageStreamReader.setOnImageAvailableListener(null, null);
            }
          });
    }

    private void setImageStreamImageAvailableListener(final EventChannel.EventSink eventSink) {
      imageStreamReader.setOnImageAvailableListener(
          new ImageReader.OnImageAvailableListener() {
            @Override
            public void onImageAvailable(final ImageReader reader) {
              Image img = reader.acquireLatestImage();
              if (img == null) return;

              List<Map<String, Object>> planes = new ArrayList<>();
              for (Image.Plane plane : img.getPlanes()) {
                ByteBuffer buffer = plane.getBuffer();

                byte[] bytes = new byte[buffer.remaining()];
                buffer.get(bytes, 0, bytes.length);

                Map<String, Object> planeBuffer = new HashMap<>();
                planeBuffer.put("bytesPerRow", plane.getRowStride());
                planeBuffer.put("bytesPerPixel", plane.getPixelStride());
                planeBuffer.put("bytes", bytes);

                planes.add(planeBuffer);
              }

              Map<String, Object> imageBuffer = new HashMap<>();
              imageBuffer.put("width", img.getWidth());
              imageBuffer.put("height", img.getHeight());
              imageBuffer.put("format", img.getFormat());
              imageBuffer.put("planes", planes);

              eventSink.success(imageBuffer);
              img.close();
            }
          },
          null);
    }

    private void sendErrorEvent(String errorDescription) {
      if (eventSink != null) {
        Map<String, String> event = new HashMap<>();
        event.put("eventType", "error");
        event.put("errorDescription", errorDescription);
        eventSink.success(event);
      }
    }

    private void closeCaptureSession() {
      if (cameraCaptureSession != null) {
        cameraCaptureSession.close();
        cameraCaptureSession = null;
      }
    }

    private void close() {
      closeCaptureSession();

      if (cameraDevice != null) {
        cameraDevice.close();
        cameraDevice = null;
      }
      if (pictureImageReader != null) {
        pictureImageReader.close();
        pictureImageReader = null;
      }
      if (imageStreamReader != null) {
        imageStreamReader.close();
        imageStreamReader = null;
      }
      if (mediaRecorder != null) {
        mediaRecorder.reset();
        mediaRecorder.release();
        mediaRecorder = null;
      }
    }

    private void dispose() {
      close();
      textureEntry.release();
    }

    private int getMediaOrientation() {
      final int sensorOrientationOffset =
          (currentOrientation == ORIENTATION_UNKNOWN)
              ? 0
              : (isFrontFacing) ? -currentOrientation : currentOrientation;
      return (sensorOrientationOffset + sensorOrientation + 360) % 360;
    }
  }
}
