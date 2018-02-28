package io.flutter.plugins.camera;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.ImageFormat;
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
import android.media.MediaCodec;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.Size;
import android.util.SparseIntArray;
import android.view.Surface;
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

// add log feature for debug
import android.util.Log;

// Handle date for file name
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;



public class CameraPlugin implements MethodCallHandler {

  private static final int cameraRequestId = 513469796;
  private static final SparseIntArray ORIENTATIONS = new SparseIntArray();
  private static CameraManager cameraManager;
  private static final String TAG = "VideoCALL:";

  @SuppressLint("UseSparseArrays")
  private static Map<Long, Cam> cams = new HashMap<>();

  static {
    ORIENTATIONS.append(Surface.ROTATION_0, 0);
    ORIENTATIONS.append(Surface.ROTATION_90, 90);
    ORIENTATIONS.append(Surface.ROTATION_180, 180);
    ORIENTATIONS.append(Surface.ROTATION_270, 270);
  }

  private final FlutterView view;
  private Activity activity;
  private Registrar registrar;
  // The code to run after requesting the permission.
  private Runnable cameraPermissionContinuation;

  private CameraPlugin(Registrar registrar, FlutterView view, Activity activity) {
    this.registrar = registrar;

    registrar.addRequestPermissionsResultListener(new CameraRequestPermissionsListener());
    this.view = view;
    this.activity = activity;

    activity
        .getApplication()
        .registerActivityLifecycleCallbacks(
            new Application.ActivityLifecycleCallbacks() {
              @Override
              public void onActivityCreated(Activity activity, Bundle savedInstanceState) {}

              @Override
              public void onActivityStarted(Activity activity) {}

              @Override
              public void onActivityResumed(Activity activity) {
                if (activity == CameraPlugin.this.activity) {
                  for (Cam cam : cams.values()) {
                    cam.resume();
                  }
                }
              }

              @Override
              public void onActivityPaused(Activity activity) {
                if (activity == CameraPlugin.this.activity) {
                  for (Cam cam : cams.values()) {
                    cam.pause();
                  }
                }
              }

              @Override
              public void onActivityStopped(Activity activity) {
                if (activity == CameraPlugin.this.activity) {
                  disposeAllCams();
                }
              }

              @Override
              public void onActivitySaveInstanceState(Activity activity, Bundle outState) {}

              @Override
              public void onActivityDestroyed(Activity activity) {}
            });
  }

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/camera");
    cameraManager = (CameraManager) registrar.activity().getSystemService(Context.CAMERA_SERVICE);

    channel.setMethodCallHandler(
        new CameraPlugin(registrar, registrar.view(), registrar.activity()));
  }

  private Size getBestPreviewSize(
      StreamConfigurationMap streamConfigurationMap, Size minPreviewSize, Size captureSize) {
    Size[] sizes = streamConfigurationMap.getOutputSizes(SurfaceTexture.class);
    List<Size> goodEnough = new ArrayList<>();
    for (Size s : sizes) {
      if (s.getHeight() * captureSize.getWidth() == s.getWidth() * captureSize.getHeight()
          && minPreviewSize.getWidth() < s.getWidth()
          && minPreviewSize.getHeight() < s.getHeight()) {
        goodEnough.add(s);
      }
    }
    if (goodEnough.isEmpty()) {
      return sizes[0];
    }
    return Collections.min(goodEnough, new CompareSizesByArea());
  }

  private Size getBestCaptureSize(StreamConfigurationMap streamConfigurationMap) {
    // For still image captures, we use the largest available size.
    return Collections.max(
        Arrays.asList(streamConfigurationMap.getOutputSizes(ImageFormat.JPEG)),
        new CompareSizesByArea());
  }

  private static Size chooseVideoSize(Size[] choices) {
    for (Size size : choices) {
        if (size.getWidth() == size.getHeight() * 4 / 3 && size.getWidth() <= 1080) {
            return size;
        }
    }
    Log.e(TAG, "Couldn't find any suitable video size");
    return choices[choices.length - 1];
  }


  private Cam getCamOfCall(MethodCall call) {
    return cams.get(textureIdOfCall(call));
  }

  private void disposeAllCams() {
    for (Cam cam : cams.values()) {
      cam.dispose();
    }
    cams.clear();
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    switch (call.method) {
      case "init":
        disposeAllCams();
        result.success(null);
        break;
      case "list":
        try {
          String[] cameraNames = cameraManager.getCameraIdList();
          List<Map<String, Object>> cameras = new ArrayList<>();
          for (String cameraName : cameraNames) {
            HashMap<String, Object> details = new HashMap<>();
            CameraCharacteristics characteristics =
                cameraManager.getCameraCharacteristics(cameraName);
            details.put("name", cameraName);
            @SuppressWarnings("ConstantConditions")
            int lens_facing = characteristics.get(CameraCharacteristics.LENS_FACING);
            switch (lens_facing) {
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
      case "create":
        {
          FlutterView.SurfaceTextureEntry surfaceTexture = view.createSurfaceTexture();
          final EventChannel eventChannel =
              new EventChannel(
                  registrar.messenger(),
                  "flutter.io/cameraPlugin/cameraEvents" + surfaceTexture.id());
          String cameraName = call.argument("cameraName");
          String resolutionPreset = call.argument("resolutionPreset");
          Cam cam = new Cam(eventChannel, surfaceTexture, cameraName, resolutionPreset, result);
          cams.put(cam.getTextureId(), cam);
          break;
        }
      case "start":
        {
          Cam cam = getCamOfCall(call);
          cam.start();
          result.success(null);
          break;
        }
      case "capture":
        {
          Cam cam = getCamOfCall(call);
          cam.capture((String) call.argument("path"), result);
          break;
        }
      case "stop":
        {
          Cam cam = getCamOfCall(call);
          cam.stop();
          result.success(null);
          break;
        }
      case "video":
      {
          ////Cam cam = getCamOfCall(call);
          final String msg = call.argument("path");
          final String video = "Hello Video call from Android , this is the path sent: " + msg;
          result.success(video);
          break;
      }
      case "videostart":
      {
          Cam cam = getCamOfCall(call);
          final String msg = call.argument("path");
          final String video = "Hello VideoStart call from Android , this is the path sent: " + msg;
          cam.videostart((String) call.argument("path"), result);
          break;
      }
      case "videostop":
      {
          Cam cam = getCamOfCall(call);
          final String msg = call.argument("path");
          final String video = "Hello VideoStop call from Android , this is the path sent: " + msg;
          cam.videostop(result);
          break;
      }
      case "dispose":
        {
          Cam cam = getCamOfCall(call);
          if (cam != null) {
            cam.dispose();
          }
          cams.remove(textureIdOfCall(call));
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
      // We cast here to ensure the multiplications won't overflow
      return Long.signum(
          (long) lhs.getWidth() * lhs.getHeight() - (long) rhs.getWidth() * rhs.getHeight());
    }
  }

  private class CameraRequestPermissionsListener
      implements PluginRegistry.RequestPermissionsResultListener {
    @Override
    public boolean onRequestPermissionsResult(int id, String[] permissions, int[] grantResults) {
      if (id == cameraRequestId) {
        cameraPermissionContinuation.run();
        return true;
      }
      return false;
    }
  }

  private class Cam {
    private final FlutterView.SurfaceTextureEntry textureEntry;
    private CameraDevice cameraDevice;
    private Surface previewSurface;
    private CameraCaptureSession cameraCaptureSession;
    private EventChannel.EventSink eventSink;
    private ImageReader imageReader;
    private boolean started = false;
    private int sensorOrientation;
    private boolean facingFront;
    private String cameraName;
    private boolean initialized = false;
    private Size captureSize;
    private Size previewSize;

    // New Media Recorder
    private Size mVideoSize;
    private MediaRecorder mMediaRecorder;
    private String mNextVideoAbsolutePath;
    private boolean mIsRecordingVideo;


    Cam(
        final EventChannel eventChannel,
        final FlutterView.SurfaceTextureEntry textureEntry,
        final String cameraName,
        final String resolutionPreset,
        final Result result) {

      this.textureEntry = textureEntry;
      this.cameraName = cameraName;
      try {
        CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);

        Size minPreviewSize;
        switch (resolutionPreset) {
          case "high":
            minPreviewSize = new Size(1024, 768);
            break;
          case "medium":
            minPreviewSize = new Size(640, 480);
            break;
          case "low":
            minPreviewSize = new Size(320, 240);
            break;
          default:
            throw new IllegalArgumentException("Unknown preset: " + resolutionPreset);
        }
        StreamConfigurationMap streamConfigurationMap =
            characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
        captureSize = getBestCaptureSize(streamConfigurationMap);
        mVideoSize = chooseVideoSize(streamConfigurationMap.getOutputSizes(MediaRecorder.class));
        previewSize = getBestPreviewSize(streamConfigurationMap, minPreviewSize, captureSize);
        imageReader =
            ImageReader.newInstance(
                captureSize.getWidth(), captureSize.getHeight(), ImageFormat.JPEG, 2);
        startMRec();
        // Set up Surface for the MediaRecorder
        // mMediaRecorder = new MediaRecorder();
        // mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
        // mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
        // mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
        // mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
        // mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
        // if (mNextVideoAbsolutePath == null || mNextVideoAbsolutePath.isEmpty()) {
        //     //mNextVideoAbsolutePath = getVideoFilePath(activity);
        //     String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date());
        //   //  final int videotime = ((int) System.currentTimeMillis()/1000);
        //     mNextVideoAbsolutePath = "/sdcard/Movies/VID_" + timeStamp + ".mp4";
        // }
        //
        // mMediaRecorder.setVideoEncodingBitRate(1024 * 1000);
        // mMediaRecorder.setVideoFrameRate(27);
        // mMediaRecorder.setVideoSize(mVideoSize.getWidth(), mVideoSize.getHeight());
        // mMediaRecorder.setOutputFile(mNextVideoAbsolutePath);
        //mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
        //int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        // int vdisplayRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        // int vdisplayOrientation = ORIENTATIONS.get(vdisplayRotation);
        //   Log.v(TAG, "Rotation:  " + rotation);
        // switch (sensorOrientation) {
        //     case SENSOR_ORIENTATION_DEFAULT_DEGREES:
        //         mMediaRecorder.setOrientationHint(DEFAULT_ORIENTATIONS.get(rotation));
        //         break;
        //     case SENSOR_ORIENTATION_INVERSE_DEGREES:
        //         mMediaRecorder.setOrientationHint(INVERSE_ORIENTATIONS.get(rotation));
        //         break;
        // }

        // mMediaRecorder.setOrientationHint((vdisplayOrientation + sensorOrientation) % 360);
        //Surface recorderSurface = mMediaRecorder.getSurface();
        SurfaceTexture surfaceTexture = textureEntry.surfaceTexture();
        surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());

      Log.v(TAG, "VideoHH=" + mVideoSize.getHeight()+ "VideoWW=" + mVideoSize.getWidth() + "preHH" + previewSize.getHeight() + "preWW=" + previewSize.getWidth() );
        previewSurface = new Surface(surfaceTexture);
        eventChannel.setStreamHandler(
            new EventChannel.StreamHandler() {
              @Override
              public void onListen(Object arguments, EventChannel.EventSink eventSink) {
                Cam.this.eventSink = eventSink;
              }

              @Override
              public void onCancel(Object arguments) {
                Cam.this.eventSink = null;
              }
            });
        if (cameraPermissionContinuation != null) {
          result.error("cameraPermission", "Camera permission request ongoing", null);
        }
        cameraPermissionContinuation =
            new Runnable() {
              @Override
              public void run() {
                cameraPermissionContinuation = null;
                openCamera(result);
              }
            };
        if (hasCameraPermission()) {
          cameraPermissionContinuation.run();
        } else {
          activity.requestPermissions(new String[] {Manifest.permission.CAMERA}, cameraRequestId);
        }
      } catch (CameraAccessException e) {
        result.error("cameraAccess", e.getMessage(), null);
      }
    }




    private boolean hasCameraPermission() {
      return Build.VERSION.SDK_INT < Build.VERSION_CODES.M
          || activity.checkSelfPermission(Manifest.permission.CAMERA)
              == PackageManager.PERMISSION_GRANTED;
    }

    private void startMRec() {
      mMediaRecorder = new MediaRecorder();
      mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
      mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
      mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
      mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
      mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
      if (mNextVideoAbsolutePath == null || mNextVideoAbsolutePath.isEmpty()) {
          //mNextVideoAbsolutePath = getVideoFilePath(activity);
          String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.US).format(new Date());
        //  final int videotime = ((int) System.currentTimeMillis()/1000);
          mNextVideoAbsolutePath = "/sdcard/Movies/VID_" + timeStamp + ".mp4";
      }

      mMediaRecorder.setVideoEncodingBitRate(1024 * 1000);
      mMediaRecorder.setVideoFrameRate(27);
      mMediaRecorder.setVideoSize(mVideoSize.getWidth(), mVideoSize.getHeight());
      mMediaRecorder.setOutputFile(mNextVideoAbsolutePath);
    }

    private void openCamera(final Result result) {
      if (!hasCameraPermission()) {
        result.error("cameraPermission", "Camera permission not granted", null);
      } else {
        try {
          CameraCharacteristics characteristics =
              cameraManager.getCameraCharacteristics(cameraName);

          //noinspection ConstantConditions
          sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
          //noinspection ConstantConditions
          facingFront =
              characteristics.get(CameraCharacteristics.LENS_FACING)
                  == CameraMetadata.LENS_FACING_FRONT;
                  int vdisplayRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
                  int vdisplayOrientation = ORIENTATIONS.get(vdisplayRotation);
                  mMediaRecorder.setOrientationHint((vdisplayOrientation + sensorOrientation) % 360);
                  //Surface recorderSurface = mMediaRecorder.getSurface();
                  try {
                       mMediaRecorder.prepare();
                   } catch (Exception e) {
                       e.printStackTrace();
                       return;
                   }
          cameraManager.openCamera(
              cameraName,
              new CameraDevice.StateCallback() {
                @Override
                public void onOpened(@NonNull CameraDevice cameraDevice) {
                  Cam.this.cameraDevice = cameraDevice;
                  List<Surface> surfaceList = new ArrayList<>();
                  surfaceList.add(previewSurface);
                  surfaceList.add(imageReader.getSurface());
                  surfaceList.add(mMediaRecorder.getSurface());


                  try {
                    cameraDevice.createCaptureSession(
                        surfaceList,
                        new CameraCaptureSession.StateCallback() {
                          @Override
                          public void onConfigured(
                              @NonNull CameraCaptureSession cameraCaptureSession) {
                            Cam.this.cameraCaptureSession = cameraCaptureSession;
                            initialized = true;
                            Map<String, Object> reply = new HashMap<>();
                            reply.put("textureId", textureEntry.id());
                            reply.put("previewWidth", previewSize.getWidth());
                            reply.put("previewHeight", previewSize.getHeight());
                            result.success(reply);
                          }

                          @Override
                          public void onConfigureFailed(
                              @NonNull CameraCaptureSession cameraCaptureSession) {
                            result.error(
                                "configureFailed", "Failed to configure camera session", null);
                          }
                        },
                        null);
                  } catch (CameraAccessException e) {
                    result.error("cameraAccess", e.getMessage(), null);
                  }
                }

                @Override
                public void onDisconnected(@NonNull CameraDevice cameraDevice) {
                  if (eventSink != null) {
                    Map<String, String> event = new HashMap<>();
                    event.put("eventType", "error");
                    event.put("errorDescription", "The camera was disconnected");
                    eventSink.success(event);
                  }
                }

                @Override
                public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
                  if (eventSink != null) {
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
                    Map<String, String> event = new HashMap<>();
                    event.put("eventType", "error");
                    event.put("errorDescription", errorDescription);
                    eventSink.success(event);
                  }
                }
              },
              null);
        } catch (CameraAccessException e) {
          result.error("cameraAccess", e.getMessage(), null);
        }
      }
    }



    // private void setUpMediaRecorder() {
    //   try {
    //     //final Activity activity = getActivity();
    //     if (null == activity) {
    //         return;
    //     }
    //
    //     //mMediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    //     mMediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
    //     mMediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
    //     if (mNextVideoAbsolutePath == null || mNextVideoAbsolutePath.isEmpty()) {
    //         mNextVideoAbsolutePath = getVideoFilePath(activity);
    //     }
    //     mMediaRecorder.setOutputFile(mNextVideoAbsolutePath);
    //     mMediaRecorder.setVideoEncodingBitRate(10000000);
    //     mMediaRecorder.setVideoFrameRate(30);
    //     mMediaRecorder.setVideoSize(mVideoSize.getWidth(), mVideoSize.getHeight());
    //     mMediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
    //     //mMediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);
    //     //int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
    //     int vdisplayRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
    //     int vdisplayOrientation = ORIENTATIONS.get(vdisplayRotation);
    //     //   Log.v(TAG, "Rotation:  " + rotation);
    //     // switch (sensorOrientation) {
    //     //     case SENSOR_ORIENTATION_DEFAULT_DEGREES:
    //     //         mMediaRecorder.setOrientationHint(DEFAULT_ORIENTATIONS.get(rotation));
    //     //         break;
    //     //     case SENSOR_ORIENTATION_INVERSE_DEGREES:
    //     //         mMediaRecorder.setOrientationHint(INVERSE_ORIENTATIONS.get(rotation));
    //     //         break;
    //     // }
    //
    //     mMediaRecorder.setOrientationHint((vdisplayOrientation + sensorOrientation) % 360);
    //     //mMediaRecorder.prepare();
    //   } catch (CameraAccessException exception) {
    //     // Theoretically image.close() could throw, so only report the error
    //     // if we have not successfully written the file.
    //     // if (!success) {
    //     //   result.error("IOError", "Failed init video", null);
    //     // }
    //     //Log.e(TAG, e);
    //   }
    // }

    private String getVideoFilePath(Context context) {
           final File dir = context.getExternalFilesDir(null);
           return (dir == null ? "" : (dir.getAbsolutePath() + "/"))
                   + System.currentTimeMillis() + ".mp4";
       }

    void start() {
      if (!initialized) {
        return;
      }
      try {
        final CaptureRequest.Builder previewRequestBuilder =
            cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_RECORD);
        previewRequestBuilder.set(
            CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);

        previewRequestBuilder.addTarget(previewSurface);
        previewRequestBuilder.addTarget(mMediaRecorder.getSurface());
        CaptureRequest previewRequest = previewRequestBuilder.build();
        cameraCaptureSession.setRepeatingRequest(
            previewRequest,
            new CameraCaptureSession.CaptureCallback() {
              @Override
              public void onCaptureBufferLost(
                  @NonNull CameraCaptureSession session,
                  @NonNull CaptureRequest request,
                  @NonNull Surface target,
                  long frameNumber) {
                super.onCaptureBufferLost(session, request, target, frameNumber);
                if (eventSink != null) {
                  eventSink.success("lost buffer");
                }
              }
            },
            null);
      } catch (CameraAccessException exception) {
        Map<String, String> event = new HashMap<>();
        event.put("eventType", "error");
        event.put("errorDescription", "Unable to start camera");
        eventSink.success(event);
      }
      started = true;
    }

    void pause() {
      if (!initialized) {
        return;
      }
      if (started && cameraCaptureSession != null) {
        try {
          cameraCaptureSession.stopRepeating();
        } catch (CameraAccessException e) {
          Map<String, String> event = new HashMap<>();
          event.put("eventType", "error");
          event.put("errorDescription", "Unable to pause camera");
          eventSink.success(event);
        }
      }
      if (cameraCaptureSession != null) {
        cameraCaptureSession.close();
        cameraCaptureSession = null;
      }
      if (cameraDevice != null) {
        cameraDevice.close();
        cameraDevice = null;
      }
    }

    void resume() {
      if (!initialized) {
        return;
      }
      openCamera(
          new Result() {
            @Override
            public void success(Object o) {
              if (started) {
                start();
              }
            }

            @Override
            public void error(String s, String s1, Object o) {}

            @Override
            public void notImplemented() {}
          });
    }

    private void writeToFile(ByteBuffer buffer, File file) throws IOException {
      try (FileOutputStream outputStream = new FileOutputStream(file)) {
        while (0 < buffer.remaining()) {
          outputStream.getChannel().write(buffer);
        }
      }
    }

    void capture(String path, final Result result) {
      final File file = new File(path);
      imageReader.setOnImageAvailableListener(
          new ImageReader.OnImageAvailableListener() {
            @Override
            public void onImageAvailable(ImageReader reader) {
              boolean success = false;
              try (Image image = reader.acquireLatestImage()) {
                ByteBuffer buffer = image.getPlanes()[0].getBuffer();
                writeToFile(buffer, file);
                success = true;
                result.success(null);
              } catch (IOException e) {
                // Theoretically image.close() could throw, so only report the error
                // if we have not successfully written the file.
                if (!success) {
                  result.error("IOError", "Failed saving image", null);
                }
              }
            }
          },
          null);

      try {
        final CaptureRequest.Builder captureBuilder =
            cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
        captureBuilder.addTarget(imageReader.getSurface());
        int displayRotation = activity.getWindowManager().getDefaultDisplay().getRotation();
        int displayOrientation = ORIENTATIONS.get(displayRotation);
        if (facingFront) displayOrientation = -displayOrientation;

        captureBuilder.set(
            CaptureRequest.JPEG_ORIENTATION, (-displayOrientation + sensorOrientation) % 360);

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

void videostart(String path, final Result result) {
Log.v(TAG, path );
  try{

    // Start recording
    mMediaRecorder.start();
    mIsRecordingVideo = true;
    result.success(null);

  }  catch (Exception e) {
    result.error("captureFailure", "an exception was thrown", null);
    //  e.printStackTrace();
      return;
  }

// try{
  // Set up Surface for the MediaRecorder
  //Surface recorderSurface = mMediaRecorder.getSurface();
  //surfaces.add(recorderSurface);




  // Start a capture session
  // Once the session starts, we can update the UI and start recording

  // cameraDevice.capture(
  //     videoBuilder.build(),
  //     new CameraCaptureSession.CaptureCallback() {
  //
  //
  //     @Override
  //     public void onConfigured(@NonNull CameraCaptureSession cameraCaptureSession) {
          // mPreviewSession = cameraCaptureSession;
          // updatePreview();
          // getActivity().runOnUiThread(new Runnable() {
          //     @Override
          //     public void run() {
          //         // UI
          //         mButtonVideo.setText(R.string.stop);
                  // mIsRecordingVideo = true;

                  // Start recording
                  // mMediaRecorder.start();
          //     }
          // });
  //     }
  //
  //     @Override
  //     public void onCaptureFailed(
  //         @NonNull CameraCaptureSession session,
  //         @NonNull CaptureRequest request,
  //         @NonNull CaptureFailure failure) {
  //       String reason;
  //       switch (failure.getReason()) {
  //         case CaptureFailure.REASON_ERROR:
  //           reason = "An error happened in the framework";
  //           break;
  //         case CaptureFailure.REASON_FLUSHED:
  //           reason = "The capture has failed due to an abortCaptures() call";
  //           break;
  //         default:
  //           reason = "Unknown reason";
  //       }
  //       result.error("captureFailure", reason, null);
  //     }
  // }, null);
  // } catch (CameraAccessException | IOException e) {
  // e.printStackTrace();
  // }

  }

void videostop(final Result result) {

  try{
    if(mIsRecordingVideo){
      // stop recording

      mIsRecordingVideo = false;
      //pause();
      mMediaRecorder.stop();
      //stop();
      mMediaRecorder.reset();
      //startMRec();
      //start();
      //start();
      //resume();
      Log.d(TAG, "Video saved: " + mNextVideoAbsolutePath);
      //dispose();
      result.success(mNextVideoAbsolutePath);
      mNextVideoAbsolutePath = null;
    }
  }  catch (Exception e) {
      result.error("captureFailure", "videostop: an exception was thrown", null);
      //e.printStackTrace();
      return;
  }


}

    void stop() {
      try {
        cameraCaptureSession.stopRepeating();
        started = false;
      } catch (CameraAccessException e) {
        Map<String, String> event = new HashMap<>();
        event.put("eventType", "error");
        event.put("errorDescription", "Unable to pause camera");
        eventSink.success(event);
      }
    }

    long getTextureId() {
      return textureEntry.id();
    }

    void dispose() {
      if (mMediaRecorder != null) {
                mMediaRecorder.reset();
                mMediaRecorder.release();
                mMediaRecorder = null;
                mNextVideoAbsolutePath = null;
        }
      if (cameraCaptureSession != null) {
        cameraCaptureSession.close();
        cameraCaptureSession = null;
      }
      if (cameraDevice != null) {
        cameraDevice.close();
        cameraDevice = null;
      }
      textureEntry.release();
    }
  }

}
