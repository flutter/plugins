// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import static io.flutter.plugins.camera.CameraUtils.computeBestPreviewSize;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraCaptureSession.CaptureCallback;
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureFailure;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
import android.hardware.camera2.params.MeteringRectangle;
import android.hardware.camera2.params.OutputConfiguration;
import android.hardware.camera2.params.SessionConfiguration;
import android.media.CamcorderProfile;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.util.Range;
import android.util.Rational;
import android.util.Size;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.camera.PictureCaptureRequest.State;
import io.flutter.plugins.camera.media.MediaRecorderBuilder;
import io.flutter.plugins.camera.types.ExposureMode;
import io.flutter.plugins.camera.types.FlashMode;
import io.flutter.plugins.camera.types.FocusMode;
import io.flutter.plugins.camera.types.ResolutionPreset;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.Executors;

@FunctionalInterface
interface ErrorCallback {
  void onError(String errorCode, String errorMessage);
}

public class Camera {
  private static final String TAG = "Camera";

  private final SurfaceTextureEntry flutterTexture;
  private final CameraManager cameraManager;
  private final DeviceOrientationManager deviceOrientationListener;
  private final boolean isFrontFacing;
  private final int sensorOrientation;
  private final String cameraName;
  private final Size captureSize;
  private final Size previewSize;
  private final boolean enableAudio;
  private final Context applicationContext;
  private final CamcorderProfile recordingProfile;
  private final DartMessenger dartMessenger;
  private final CameraZoom cameraZoom;
  private final CameraCharacteristics cameraCharacteristics;

  private CameraDevice cameraDevice;
  private CameraCaptureSession cameraCaptureSession;
  private ImageReader pictureImageReader;
  private ImageReader imageStreamReader;
  private CaptureRequest.Builder captureRequestBuilder;
  private MediaRecorder mediaRecorder;
  private boolean recordingVideo;
  private File videoRecordingFile;
  private FlashMode flashMode;
  private ExposureMode exposureMode;
  private FocusMode focusMode;
  private PictureCaptureRequest pictureCaptureRequest;
  private CameraRegions cameraRegions;
  private int exposureOffset;
  private boolean useAutoFocus = true;
  private Range<Integer> fpsRange;
  private PlatformChannel.DeviceOrientation lockedCaptureOrientation;

  private static final HashMap<String, Integer> supportedImageFormats;
  // Current supported outputs
  static {
    supportedImageFormats = new HashMap<>();
    supportedImageFormats.put("yuv420", 35);
    supportedImageFormats.put("jpeg", 256);
  }

  public Camera(
      final Activity activity,
      final SurfaceTextureEntry flutterTexture,
      final DartMessenger dartMessenger,
      final String cameraName,
      final String resolutionPreset,
      final boolean enableAudio)
      throws CameraAccessException {
    if (activity == null) {
      throw new IllegalStateException("No activity available!");
    }
    this.cameraName = cameraName;
    this.enableAudio = enableAudio;
    this.flutterTexture = flutterTexture;
    this.dartMessenger = dartMessenger;
    this.cameraManager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
    this.applicationContext = activity.getApplicationContext();
    this.flashMode = FlashMode.auto;
    this.exposureMode = ExposureMode.auto;
    this.focusMode = FocusMode.auto;
    this.exposureOffset = 0;

    cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraName);
    initFps(cameraCharacteristics);
    sensorOrientation = cameraCharacteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
    isFrontFacing =
        cameraCharacteristics.get(CameraCharacteristics.LENS_FACING)
            == CameraMetadata.LENS_FACING_FRONT;
    ResolutionPreset preset = ResolutionPreset.valueOf(resolutionPreset);
    recordingProfile =
        CameraUtils.getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset);
    captureSize = new Size(recordingProfile.videoFrameWidth, recordingProfile.videoFrameHeight);
    previewSize = computeBestPreviewSize(cameraName, preset);
    cameraZoom =
        new CameraZoom(
            cameraCharacteristics.get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE),
            cameraCharacteristics.get(CameraCharacteristics.SCALER_AVAILABLE_MAX_DIGITAL_ZOOM));

    deviceOrientationListener =
        new DeviceOrientationManager(activity, dartMessenger, isFrontFacing, sensorOrientation);
    deviceOrientationListener.start();
  }

  private void initFps(CameraCharacteristics cameraCharacteristics) {
    try {
      Range<Integer>[] ranges =
          cameraCharacteristics.get(CameraCharacteristics.CONTROL_AE_AVAILABLE_TARGET_FPS_RANGES);
      if (ranges != null) {
        for (Range<Integer> range : ranges) {
          int upper = range.getUpper();
          Log.i("Camera", "[FPS Range Available] is:" + range);
          if (upper >= 10) {
            if (fpsRange == null || upper > fpsRange.getUpper()) {
              fpsRange = range;
            }
          }
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
    Log.i("Camera", "[FPS Range] is:" + fpsRange);
  }

  private void prepareMediaRecorder(String outputFilePath) throws IOException {
    if (mediaRecorder != null) {
      mediaRecorder.release();
    }

    mediaRecorder =
        new MediaRecorderBuilder(recordingProfile, outputFilePath)
            .setEnableAudio(enableAudio)
            .setMediaOrientation(
                lockedCaptureOrientation == null
                    ? deviceOrientationListener.getMediaOrientation()
                    : deviceOrientationListener.getMediaOrientation(lockedCaptureOrientation))
            .build();
  }

  @SuppressLint("MissingPermission")
  public void open(String imageFormatGroup) throws CameraAccessException {
    pictureImageReader =
        ImageReader.newInstance(
            captureSize.getWidth(), captureSize.getHeight(), ImageFormat.JPEG, 2);

    Integer imageFormat = supportedImageFormats.get(imageFormatGroup);
    if (imageFormat == null) {
      Log.w(TAG, "The selected imageFormatGroup is not supported by Android. Defaulting to yuv420");
      imageFormat = ImageFormat.YUV_420_888;
    }

    // Used to steam image byte data to dart side.
    imageStreamReader =
        ImageReader.newInstance(previewSize.getWidth(), previewSize.getHeight(), imageFormat, 2);

    cameraManager.openCamera(
        cameraName,
        new CameraDevice.StateCallback() {
          @Override
          public void onOpened(@NonNull CameraDevice device) {
            cameraDevice = device;
            try {
              cameraRegions = new CameraRegions(getRegionBoundaries());
              startPreview();
              dartMessenger.sendCameraInitializedEvent(
                  previewSize.getWidth(),
                  previewSize.getHeight(),
                  exposureMode,
                  focusMode,
                  isExposurePointSupported(),
                  isFocusPointSupported());
            } catch (CameraAccessException e) {
              dartMessenger.sendCameraErrorEvent(e.getMessage());
              close();
            }
          }

          @Override
          public void onClosed(@NonNull CameraDevice camera) {
            dartMessenger.sendCameraClosingEvent();
            super.onClosed(camera);
          }

          @Override
          public void onDisconnected(@NonNull CameraDevice cameraDevice) {
            close();
            dartMessenger.sendCameraErrorEvent("The camera was disconnected.");
          }

          @Override
          public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
            close();
            String errorDescription;
            switch (errorCode) {
              case ERROR_CAMERA_IN_USE:
                errorDescription = "The camera device is in use already.";
                break;
              case ERROR_MAX_CAMERAS_IN_USE:
                errorDescription = "Max cameras in use";
                break;
              case ERROR_CAMERA_DISABLED:
                errorDescription = "The camera device could not be opened due to a device policy.";
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
            dartMessenger.sendCameraErrorEvent(errorDescription);
          }
        },
        null);
  }

  private void createCaptureSession(int templateType, Surface... surfaces)
      throws CameraAccessException {
    createCaptureSession(templateType, null, surfaces);
  }

  private void createCaptureSession(
      int templateType, Runnable onSuccessCallback, Surface... surfaces)
      throws CameraAccessException {
    // Close any existing capture session.
    closeCaptureSession();

    // Create a new capture builder.
    captureRequestBuilder = cameraDevice.createCaptureRequest(templateType);

    // Build Flutter surface to render to
    SurfaceTexture surfaceTexture = flutterTexture.surfaceTexture();
    surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
    Surface flutterSurface = new Surface(surfaceTexture);
    captureRequestBuilder.addTarget(flutterSurface);

    List<Surface> remainingSurfaces = Arrays.asList(surfaces);
    if (templateType != CameraDevice.TEMPLATE_PREVIEW) {
      // If it is not preview mode, add all surfaces as targets.
      for (Surface surface : remainingSurfaces) {
        captureRequestBuilder.addTarget(surface);
      }
    }

    // Prepare the callback
    CameraCaptureSession.StateCallback callback =
        new CameraCaptureSession.StateCallback() {
          @Override
          public void onConfigured(@NonNull CameraCaptureSession session) {
            if (cameraDevice == null) {
              dartMessenger.sendCameraErrorEvent("The camera was closed during configuration.");
              return;
            }
            cameraCaptureSession = session;

            updateFpsRange();
            updateFocus(focusMode);
            updateFlash(flashMode);
            updateExposure(exposureMode);

            refreshPreviewCaptureSession(
                onSuccessCallback, (code, message) -> dartMessenger.sendCameraErrorEvent(message));
          }

          @Override
          public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
            dartMessenger.sendCameraErrorEvent("Failed to configure camera session.");
          }
        };

    // Start the session
    if (VERSION.SDK_INT >= VERSION_CODES.P) {
      // Collect all surfaces we want to render to.
      List<OutputConfiguration> configs = new ArrayList<>();
      configs.add(new OutputConfiguration(flutterSurface));
      for (Surface surface : remainingSurfaces) {
        configs.add(new OutputConfiguration(surface));
      }
      createCaptureSessionWithSessionConfig(configs, callback);
    } else {
      // Collect all surfaces we want to render to.
      List<Surface> surfaceList = new ArrayList<>();
      surfaceList.add(flutterSurface);
      surfaceList.addAll(remainingSurfaces);
      createCaptureSession(surfaceList, callback);
    }
  }

  @TargetApi(VERSION_CODES.P)
  private void createCaptureSessionWithSessionConfig(
      List<OutputConfiguration> outputConfigs, CameraCaptureSession.StateCallback callback)
      throws CameraAccessException {
    cameraDevice.createCaptureSession(
        new SessionConfiguration(
            SessionConfiguration.SESSION_REGULAR,
            outputConfigs,
            Executors.newSingleThreadExecutor(),
            callback));
  }

  @TargetApi(VERSION_CODES.LOLLIPOP)
  @SuppressWarnings("deprecation")
  private void createCaptureSession(
      List<Surface> surfaces, CameraCaptureSession.StateCallback callback)
      throws CameraAccessException {
    cameraDevice.createCaptureSession(surfaces, callback, null);
  }

  private void refreshPreviewCaptureSession(
      @Nullable Runnable onSuccessCallback, @NonNull ErrorCallback onErrorCallback) {
    if (cameraCaptureSession == null) {
      return;
    }

    try {
      cameraCaptureSession.setRepeatingRequest(
          captureRequestBuilder.build(),
          pictureCaptureCallback,
          new Handler(Looper.getMainLooper()));

      if (onSuccessCallback != null) {
        onSuccessCallback.run();
      }
    } catch (CameraAccessException | IllegalStateException | IllegalArgumentException e) {
      onErrorCallback.onError("cameraAccess", e.getMessage());
    }
  }

  private void writeToFile(ByteBuffer buffer, File file) throws IOException {
    try (FileOutputStream outputStream = new FileOutputStream(file)) {
      while (0 < buffer.remaining()) {
        outputStream.getChannel().write(buffer);
      }
    }
  }

  public void takePicture(@NonNull final Result result) {
    // Only take 1 picture at a time
    if (pictureCaptureRequest != null && !pictureCaptureRequest.isFinished()) {
      result.error("captureAlreadyActive", "Picture is currently already being captured", null);
      return;
    }
    // Store the result
    this.pictureCaptureRequest = new PictureCaptureRequest(result);

    // Create temporary file
    final File outputDir = applicationContext.getCacheDir();
    final File file;
    try {
      file = File.createTempFile("CAP", ".jpg", outputDir);
    } catch (IOException | SecurityException e) {
      pictureCaptureRequest.error("cannotCreateFile", e.getMessage(), null);
      return;
    }

    // Listen for picture being taken
    pictureImageReader.setOnImageAvailableListener(
        reader -> {
          try (Image image = reader.acquireLatestImage()) {
            ByteBuffer buffer = image.getPlanes()[0].getBuffer();
            writeToFile(buffer, file);
            pictureCaptureRequest.finish(file.getAbsolutePath());
          } catch (IOException e) {
            pictureCaptureRequest.error("IOError", "Failed saving image", null);
          }
        },
        null);

    if (useAutoFocus) {
      runPictureAutoFocus();
    } else {
      runPicturePreCapture();
    }
  }

  private final CameraCaptureSession.CaptureCallback pictureCaptureCallback =
      new CameraCaptureSession.CaptureCallback() {
        @Override
        public void onCaptureCompleted(
            @NonNull CameraCaptureSession session,
            @NonNull CaptureRequest request,
            @NonNull TotalCaptureResult result) {
          processCapture(result);
        }

        @Override
        public void onCaptureProgressed(
            @NonNull CameraCaptureSession session,
            @NonNull CaptureRequest request,
            @NonNull CaptureResult partialResult) {
          processCapture(partialResult);
        }

        @Override
        public void onCaptureFailed(
            @NonNull CameraCaptureSession session,
            @NonNull CaptureRequest request,
            @NonNull CaptureFailure failure) {
          if (pictureCaptureRequest == null || pictureCaptureRequest.isFinished()) {
            return;
          }
          String reason;
          boolean fatalFailure = false;
          switch (failure.getReason()) {
            case CaptureFailure.REASON_ERROR:
              reason = "An error happened in the framework";
              break;
            case CaptureFailure.REASON_FLUSHED:
              reason = "The capture has failed due to an abortCaptures() call";
              fatalFailure = true;
              break;
            default:
              reason = "Unknown reason";
          }
          Log.w("Camera", "pictureCaptureCallback.onCaptureFailed(): " + reason);
          if (fatalFailure) pictureCaptureRequest.error("captureFailure", reason, null);
        }

        private void processCapture(CaptureResult result) {
          if (pictureCaptureRequest == null) {
            return;
          }

          Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
          Integer afState = result.get(CaptureResult.CONTROL_AF_STATE);
          switch (pictureCaptureRequest.getState()) {
            case focusing:
              if (afState == null) {
                return;
              } else if (afState == CaptureResult.CONTROL_AF_STATE_FOCUSED_LOCKED
                  || afState == CaptureResult.CONTROL_AF_STATE_NOT_FOCUSED_LOCKED) {
                // Some devices might return null here, in which case we will also continue.
                if (aeState == null || aeState == CaptureResult.CONTROL_AE_STATE_CONVERGED) {
                  runPictureCapture();
                } else {
                  runPicturePreCapture();
                }
              }
              break;
            case preCapture:
              // Some devices might return null here, in which case we will also continue.
              if (aeState == null
                  || aeState == CaptureRequest.CONTROL_AE_STATE_PRECAPTURE
                  || aeState == CaptureRequest.CONTROL_AE_STATE_FLASH_REQUIRED
                  || aeState == CaptureRequest.CONTROL_AE_STATE_CONVERGED) {
                pictureCaptureRequest.setState(State.waitingPreCaptureReady);
              }
              break;
            case waitingPreCaptureReady:
              if (aeState == null || aeState != CaptureRequest.CONTROL_AE_STATE_PRECAPTURE) {
                runPictureCapture();
              }
          }
        }
      };

  private void runPictureAutoFocus() {
    assert (pictureCaptureRequest != null);

    pictureCaptureRequest.setState(PictureCaptureRequest.State.focusing);
    lockAutoFocus(pictureCaptureCallback);
  }

  private void runPicturePreCapture() {
    assert (pictureCaptureRequest != null);
    pictureCaptureRequest.setState(PictureCaptureRequest.State.preCapture);

    captureRequestBuilder.set(
        CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
        CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_START);

    refreshPreviewCaptureSession(
        () ->
            captureRequestBuilder.set(
                CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
                CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE),
        (code, message) -> pictureCaptureRequest.error(code, message, null));
  }

  private void runPictureCapture() {
    assert (pictureCaptureRequest != null);
    pictureCaptureRequest.setState(PictureCaptureRequest.State.capturing);
    try {
      final CaptureRequest.Builder captureBuilder =
          cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
      captureBuilder.addTarget(pictureImageReader.getSurface());
      captureBuilder.set(
          CaptureRequest.JPEG_ORIENTATION,
          lockedCaptureOrientation == null
              ? deviceOrientationListener.getMediaOrientation()
              : deviceOrientationListener.getMediaOrientation(lockedCaptureOrientation));
      switch (flashMode) {
        case off:
          captureBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
          captureBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
          break;
        case auto:
          captureBuilder.set(
              CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
          break;
        case always:
        default:
          captureBuilder.set(
              CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
          break;
      }
      cameraCaptureSession.stopRepeating();
      cameraCaptureSession.capture(
          captureBuilder.build(),
          new CameraCaptureSession.CaptureCallback() {
            @Override
            public void onCaptureCompleted(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                @NonNull TotalCaptureResult result) {
              unlockAutoFocus();
            }
          },
          null);
    } catch (CameraAccessException e) {
      pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
    }
  }

  private void lockAutoFocus(CaptureCallback callback) {
    captureRequestBuilder.set(
        CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_START);

    refreshPreviewCaptureSession(
        null, (code, message) -> pictureCaptureRequest.error(code, message, null));
  }

  private void unlockAutoFocus() {
    captureRequestBuilder.set(
        CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_CANCEL);
    updateFocus(focusMode);
    try {
      cameraCaptureSession.capture(captureRequestBuilder.build(), null, null);
    } catch (CameraAccessException ignored) {
    }
    captureRequestBuilder.set(
        CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_IDLE);

    refreshPreviewCaptureSession(
        null,
        (errorCode, errorMessage) -> pictureCaptureRequest.error(errorCode, errorMessage, null));
  }

  public void startVideoRecording(Result result) {
    final File outputDir = applicationContext.getCacheDir();
    try {
      videoRecordingFile = File.createTempFile("REC", ".mp4", outputDir);
    } catch (IOException | SecurityException e) {
      result.error("cannotCreateFile", e.getMessage(), null);
      return;
    }

    try {
      prepareMediaRecorder(videoRecordingFile.getAbsolutePath());
      recordingVideo = true;
      createCaptureSession(
          CameraDevice.TEMPLATE_RECORD, () -> mediaRecorder.start(), mediaRecorder.getSurface());
      result.success(null);
    } catch (CameraAccessException | IOException e) {
      recordingVideo = false;
      videoRecordingFile = null;
      result.error("videoRecordingFailed", e.getMessage(), null);
    }
  }

  public void stopVideoRecording(@NonNull final Result result) {
    if (!recordingVideo) {
      result.success(null);
      return;
    }

    try {
      recordingVideo = false;

      try {
        cameraCaptureSession.abortCaptures();
        mediaRecorder.stop();
      } catch (CameraAccessException | IllegalStateException e) {
        // Ignore exceptions and try to continue (changes are camera session already aborted capture)
      }

      mediaRecorder.reset();
      startPreview();
      result.success(videoRecordingFile.getAbsolutePath());
      videoRecordingFile = null;
    } catch (CameraAccessException | IllegalStateException e) {
      result.error("videoRecordingFailed", e.getMessage(), null);
    }
  }

  public void pauseVideoRecording(@NonNull final Result result) {
    if (!recordingVideo) {
      result.success(null);
      return;
    }

    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        mediaRecorder.pause();
      } else {
        result.error("videoRecordingFailed", "pauseVideoRecording requires Android API +24.", null);
        return;
      }
    } catch (IllegalStateException e) {
      result.error("videoRecordingFailed", e.getMessage(), null);
      return;
    }

    result.success(null);
  }

  public void resumeVideoRecording(@NonNull final Result result) {
    if (!recordingVideo) {
      result.success(null);
      return;
    }

    try {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        mediaRecorder.resume();
      } else {
        result.error(
            "videoRecordingFailed", "resumeVideoRecording requires Android API +24.", null);
        return;
      }
    } catch (IllegalStateException e) {
      result.error("videoRecordingFailed", e.getMessage(), null);
      return;
    }

    result.success(null);
  }

  public void setFlashMode(@NonNull final Result result, FlashMode mode)
      throws CameraAccessException {
    // Get the flash availability
    Boolean flashAvailable =
        cameraManager
            .getCameraCharacteristics(cameraDevice.getId())
            .get(CameraCharacteristics.FLASH_INFO_AVAILABLE);

    // Check if flash is available.
    if (flashAvailable == null || !flashAvailable) {
      result.error("setFlashModeFailed", "Device does not have flash capabilities", null);
      return;
    }

    // If switching directly from torch to auto or on, make sure we turn off the torch.
    if (flashMode == FlashMode.torch && mode != FlashMode.torch && mode != FlashMode.off) {
      updateFlash(FlashMode.off);

      this.cameraCaptureSession.setRepeatingRequest(
          captureRequestBuilder.build(),
          new CaptureCallback() {
            private boolean isFinished = false;

            @Override
            public void onCaptureCompleted(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                @NonNull TotalCaptureResult captureResult) {
              if (isFinished) {
                return;
              }

              updateFlash(mode);
              refreshPreviewCaptureSession(
                  () -> {
                    result.success(null);
                    isFinished = true;
                  },
                  (code, message) ->
                      result.error("setFlashModeFailed", "Could not set flash mode.", null));
            }

            @Override
            public void onCaptureFailed(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                @NonNull CaptureFailure failure) {
              if (isFinished) {
                return;
              }

              result.error("setFlashModeFailed", "Could not set flash mode.", null);
              isFinished = true;
            }
          },
          null);
    } else {
      updateFlash(mode);

      refreshPreviewCaptureSession(
          () -> result.success(null),
          (code, message) -> result.error("setFlashModeFailed", "Could not set flash mode.", null));
    }
  }

  public void setExposureMode(@NonNull final Result result, ExposureMode mode)
      throws CameraAccessException {
    updateExposure(mode);
    cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
    result.success(null);
  }

  public void setExposurePoint(@NonNull final Result result, Double x, Double y)
      throws CameraAccessException {
    // Check if exposure point functionality is available.
    if (!isExposurePointSupported()) {
      result.error(
          "setExposurePointFailed", "Device does not have exposure point capabilities", null);
      return;
    }
    // Check if the current region boundaries are known
    if (cameraRegions.getMaxBoundaries() == null) {
      result.error("setExposurePointFailed", "Could not determine max region boundaries", null);
      return;
    }
    // Set the metering rectangle
    if (x == null || y == null) cameraRegions.resetAutoExposureMeteringRectangle();
    else cameraRegions.setAutoExposureMeteringRectangleFromPoint(x, y);
    // Apply it
    updateExposure(exposureMode);
    refreshPreviewCaptureSession(
        () -> result.success(null), (code, message) -> result.error("CameraAccess", message, null));
  }

  public void setFocusMode(@NonNull final Result result, FocusMode mode)
      throws CameraAccessException {
    this.focusMode = mode;

    updateFocus(mode);

    switch (mode) {
      case auto:
        refreshPreviewCaptureSession(
            null, (code, message) -> result.error("setFocusMode", message, null));
        break;
      case locked:
        lockAutoFocus(
            new CaptureCallback() {
              @Override
              public void onCaptureCompleted(
                  @NonNull CameraCaptureSession session,
                  @NonNull CaptureRequest request,
                  @NonNull TotalCaptureResult result) {
                unlockAutoFocus();
              }
            });
        break;
    }
    result.success(null);
  }

  public void setFocusPoint(@NonNull final Result result, Double x, Double y)
      throws CameraAccessException {
    // Check if focus point functionality is available.
    if (!isFocusPointSupported()) {
      result.error("setFocusPointFailed", "Device does not have focus point capabilities", null);
      return;
    }

    // Check if the current region boundaries are known
    if (cameraRegions.getMaxBoundaries() == null) {
      result.error("setFocusPointFailed", "Could not determine max region boundaries", null);
      return;
    }

    // Set the metering rectangle
    if (x == null || y == null) {
      cameraRegions.resetAutoFocusMeteringRectangle();
    } else {
      cameraRegions.setAutoFocusMeteringRectangleFromPoint(x, y);
    }

    // Apply the new metering rectangle
    setFocusMode(result, focusMode);
  }

  @TargetApi(VERSION_CODES.P)
  private boolean supportsDistortionCorrection() throws CameraAccessException {
    int[] availableDistortionCorrectionModes =
        cameraManager
            .getCameraCharacteristics(cameraDevice.getId())
            .get(CameraCharacteristics.DISTORTION_CORRECTION_AVAILABLE_MODES);
    if (availableDistortionCorrectionModes == null) availableDistortionCorrectionModes = new int[0];
    long nonOffModesSupported =
        Arrays.stream(availableDistortionCorrectionModes)
            .filter((value) -> value != CaptureRequest.DISTORTION_CORRECTION_MODE_OFF)
            .count();
    return nonOffModesSupported > 0;
  }

  private Size getRegionBoundaries() throws CameraAccessException {
    // No distortion correction support
    if (android.os.Build.VERSION.SDK_INT < VERSION_CODES.P || !supportsDistortionCorrection()) {
      return cameraManager
          .getCameraCharacteristics(cameraDevice.getId())
          .get(CameraCharacteristics.SENSOR_INFO_PIXEL_ARRAY_SIZE);
    }
    // Get the current distortion correction mode
    Integer distortionCorrectionMode =
        captureRequestBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE);
    // Return the correct boundaries depending on the mode
    android.graphics.Rect rect;
    if (distortionCorrectionMode == null
        || distortionCorrectionMode == CaptureRequest.DISTORTION_CORRECTION_MODE_OFF) {
      rect =
          cameraManager
              .getCameraCharacteristics(cameraDevice.getId())
              .get(CameraCharacteristics.SENSOR_INFO_PRE_CORRECTION_ACTIVE_ARRAY_SIZE);
    } else {
      rect =
          cameraManager
              .getCameraCharacteristics(cameraDevice.getId())
              .get(CameraCharacteristics.SENSOR_INFO_ACTIVE_ARRAY_SIZE);
    }
    return rect == null ? null : new Size(rect.width(), rect.height());
  }

  private boolean isExposurePointSupported() throws CameraAccessException {
    Integer supportedRegions =
        cameraManager
            .getCameraCharacteristics(cameraDevice.getId())
            .get(CameraCharacteristics.CONTROL_MAX_REGIONS_AE);
    return supportedRegions != null && supportedRegions > 0;
  }

  private boolean isFocusPointSupported() throws CameraAccessException {
    Integer supportedRegions =
        cameraManager
            .getCameraCharacteristics(cameraDevice.getId())
            .get(CameraCharacteristics.CONTROL_MAX_REGIONS_AF);
    return supportedRegions != null && supportedRegions > 0;
  }

  public double getMinExposureOffset() throws CameraAccessException {
    Range<Integer> range =
        cameraManager
            .getCameraCharacteristics(cameraDevice.getId())
            .get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE);
    double minStepped = range == null ? 0 : range.getLower();
    double stepSize = getExposureOffsetStepSize();
    return minStepped * stepSize;
  }

  public double getMaxExposureOffset() throws CameraAccessException {
    Range<Integer> range =
        cameraManager
            .getCameraCharacteristics(cameraDevice.getId())
            .get(CameraCharacteristics.CONTROL_AE_COMPENSATION_RANGE);
    double maxStepped = range == null ? 0 : range.getUpper();
    double stepSize = getExposureOffsetStepSize();
    return maxStepped * stepSize;
  }

  public double getExposureOffsetStepSize() throws CameraAccessException {
    Rational stepSize =
        cameraManager
            .getCameraCharacteristics(cameraDevice.getId())
            .get(CameraCharacteristics.CONTROL_AE_COMPENSATION_STEP);
    return stepSize == null ? 0.0 : stepSize.doubleValue();
  }

  public void setExposureOffset(@NonNull final Result result, double offset)
      throws CameraAccessException {
    // Set the exposure offset
    double stepSize = getExposureOffsetStepSize();
    exposureOffset = (int) (offset / stepSize);
    // Apply it
    updateExposure(exposureMode);
    this.cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
    result.success(offset);
  }

  public float getMaxZoomLevel() {
    return cameraZoom.maxZoom;
  }

  public float getMinZoomLevel() {
    return CameraZoom.DEFAULT_ZOOM_FACTOR;
  }

  public void setZoomLevel(@NonNull final Result result, float zoom) throws CameraAccessException {
    float maxZoom = cameraZoom.maxZoom;
    float minZoom = CameraZoom.DEFAULT_ZOOM_FACTOR;

    if (zoom > maxZoom || zoom < minZoom) {
      String errorMessage =
          String.format(
              Locale.ENGLISH,
              "Zoom level out of bounds (zoom level should be between %f and %f).",
              minZoom,
              maxZoom);
      result.error("ZOOM_ERROR", errorMessage, null);
      return;
    }

    //Zoom area is calculated relative to sensor area (activeRect)
    if (captureRequestBuilder != null) {
      final Rect computedZoom = cameraZoom.computeZoom(zoom);
      captureRequestBuilder.set(CaptureRequest.SCALER_CROP_REGION, computedZoom);
      cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
    }

    result.success(null);
  }

  public void lockCaptureOrientation(PlatformChannel.DeviceOrientation orientation) {
    this.lockedCaptureOrientation = orientation;
  }

  public void unlockCaptureOrientation() {
    this.lockedCaptureOrientation = null;
  }

  private void updateFpsRange() {
    if (fpsRange == null) {
      return;
    }

    captureRequestBuilder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, fpsRange);
  }

  private void updateFocus(FocusMode mode) {
    if (useAutoFocus) {
      int[] modes = cameraCharacteristics.get(CameraCharacteristics.CONTROL_AF_AVAILABLE_MODES);
      // Auto focus is not supported
      if (modes == null
          || modes.length == 0
          || (modes.length == 1 && modes[0] == CameraCharacteristics.CONTROL_AF_MODE_OFF)) {
        useAutoFocus = false;
        captureRequestBuilder.set(
            CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_OFF);
      } else {
        // Applying auto focus
        switch (mode) {
          case locked:
            captureRequestBuilder.set(
                CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO);
            break;
          case auto:
            captureRequestBuilder.set(
                CaptureRequest.CONTROL_AF_MODE,
                recordingVideo
                    ? CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO
                    : CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
          default:
            break;
        }
        MeteringRectangle afRect = cameraRegions.getAFMeteringRectangle();
        captureRequestBuilder.set(
            CaptureRequest.CONTROL_AF_REGIONS,
            afRect == null ? null : new MeteringRectangle[] {afRect});
      }
    } else {
      captureRequestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_OFF);
    }
  }

  private void updateExposure(ExposureMode mode) {
    exposureMode = mode;

    // Applying auto exposure
    MeteringRectangle aeRect = cameraRegions.getAEMeteringRectangle();
    captureRequestBuilder.set(
        CaptureRequest.CONTROL_AE_REGIONS,
        aeRect == null ? null : new MeteringRectangle[] {cameraRegions.getAEMeteringRectangle()});

    switch (mode) {
      case locked:
        captureRequestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, true);
        break;
      case auto:
      default:
        captureRequestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        break;
    }

    captureRequestBuilder.set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, exposureOffset);
  }

  private void updateFlash(FlashMode mode) {
    // Get flash
    flashMode = mode;

    // Applying flash modes
    switch (flashMode) {
      case off:
        captureRequestBuilder.set(
            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
        captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
        break;
      case auto:
        captureRequestBuilder.set(
            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
        captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
        break;
      case always:
        captureRequestBuilder.set(
            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
        captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
        break;
      case torch:
      default:
        captureRequestBuilder.set(
            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
        captureRequestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_TORCH);
        break;
    }
  }

  public void startPreview() throws CameraAccessException {
    if (pictureImageReader == null || pictureImageReader.getSurface() == null) return;

    createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, pictureImageReader.getSurface());
  }

  public void startPreviewWithImageStream(EventChannel imageStreamChannel)
      throws CameraAccessException {
    createCaptureSession(CameraDevice.TEMPLATE_RECORD, imageStreamReader.getSurface());

    imageStreamChannel.setStreamHandler(
        new EventChannel.StreamHandler() {
          @Override
          public void onListen(Object o, EventChannel.EventSink imageStreamSink) {
            setImageStreamImageAvailableListener(imageStreamSink);
          }

          @Override
          public void onCancel(Object o) {
            imageStreamReader.setOnImageAvailableListener(null, null);
          }
        });
  }

  private void setImageStreamImageAvailableListener(final EventChannel.EventSink imageStreamSink) {
    imageStreamReader.setOnImageAvailableListener(
        reader -> {
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

          imageStreamSink.success(imageBuffer);
          img.close();
        },
        null);
  }

  public void stopImageStream() throws CameraAccessException {
    if (imageStreamReader != null) {
      imageStreamReader.setOnImageAvailableListener(null, null);
    }
    startPreview();
  }

  private void closeCaptureSession() {
    if (cameraCaptureSession != null) {
      cameraCaptureSession.close();
      cameraCaptureSession = null;
    }
  }

  public void close() {
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

  public void dispose() {
    close();
    flutterTexture.release();
    deviceOrientationListener.stop();
  }
}
