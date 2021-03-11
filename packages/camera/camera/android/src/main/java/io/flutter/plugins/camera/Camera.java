// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.camera;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.hardware.camera2.CameraAccessException;
import android.hardware.camera2.CameraCaptureSession;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.TotalCaptureResult;
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
import android.os.HandlerThread;
import android.os.Looper;
import android.util.Log;
import android.util.Size;
import android.util.SparseIntArray;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.camera.features.CameraFeature;
import io.flutter.plugins.camera.features.CameraFeatureFactory;
import io.flutter.plugins.camera.features.CameraFeatures;
import io.flutter.plugins.camera.features.Point;
import io.flutter.plugins.camera.features.autofocus.AutoFocusFeature;
import io.flutter.plugins.camera.features.autofocus.FocusMode;
import io.flutter.plugins.camera.features.exposurelock.ExposureLockFeature;
import io.flutter.plugins.camera.features.exposurelock.ExposureMode;
import io.flutter.plugins.camera.features.exposureoffset.ExposureOffsetFeature;
import io.flutter.plugins.camera.features.exposureoffset.ExposureOffsetValue;
import io.flutter.plugins.camera.features.exposurepoint.ExposurePointFeature;
import io.flutter.plugins.camera.features.flash.FlashFeature;
import io.flutter.plugins.camera.features.flash.FlashMode;
import io.flutter.plugins.camera.features.focuspoint.FocusPointFeature;
import io.flutter.plugins.camera.features.regionboundaries.CameraRegions;
import io.flutter.plugins.camera.features.regionboundaries.RegionBoundariesFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionFeature;
import io.flutter.plugins.camera.features.resolution.ResolutionPreset;
import io.flutter.plugins.camera.features.sensororientation.DeviceOrientationManager;
import io.flutter.plugins.camera.features.sensororientation.SensorOrientationFeature;
import io.flutter.plugins.camera.features.zoomlevel.CameraZoom;
import io.flutter.plugins.camera.features.zoomlevel.ZoomLevelFeature;
import io.flutter.plugins.camera.media.MediaRecorderBuilder;
import io.flutter.view.TextureRegistry.SurfaceTextureEntry;
import java.io.File;
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

/**
 * Note: at this time we do not implement zero shutter lag (ZSL) capture. This is a potential
 * improvement we can use in the future. The idea is in a TEMPLATE_ZERO_SHUTTER_LAG capture session,
 * the system maintains a ring buffer of images from the preview. It must be in full auto moved
 * (flash, ae, focus, etc). When you capture an image, it simply picks one out of the ring buffer,
 * thus capturing an image with zero shutter lag.
 *
 * <p>This is a potential improvement for the future. A good example is the AOSP camera here:
 * https://android.googlesource.com/platform/packages/apps/Camera2/+/9c94ab3/src/com/android/camera/one/v2/OneCameraZslImpl.java
 *
 * <p>But one note- they mention sometimes ZSL captures can be very low quality so it might not be
 * preferred on some devices. If we do add support for this in the future, we should allow it to be
 * enabled from dart.
 */
class Camera implements CameraCaptureCallback.CameraCaptureStateListener {
  private static final String TAG = "Camera";

  /** Conversion from screen rotation to JPEG orientation. */
  private static final SparseIntArray ORIENTATIONS = new SparseIntArray();

  private static final HashMap<String, Integer> supportedImageFormats;

  static {
    ORIENTATIONS.append(Surface.ROTATION_0, 90);
    ORIENTATIONS.append(Surface.ROTATION_90, 0);
    ORIENTATIONS.append(Surface.ROTATION_180, 270);
    ORIENTATIONS.append(Surface.ROTATION_270, 180);
  }

  // Current supported outputs
  static {
    supportedImageFormats = new HashMap<>();
    supportedImageFormats.put("yuv420", ImageFormat.YUV_420_888);
    supportedImageFormats.put("jpeg", ImageFormat.JPEG);
  }

  /**
   * Holds all of the camera features/settings and will be used to update the request builder when
   * one changes.
   */
  private final Map<CameraFeatures, CameraFeature> cameraFeatures;

  private final SurfaceTextureEntry flutterTexture;
  private final boolean enableAudio;
  private final Context applicationContext;
  private final DartMessenger dartMessenger;
  private final CameraProperties cameraProperties;
  private final Activity activity;
  /** A {@link CameraCaptureSession.CaptureCallback} that handles events related to JPEG capture. */
  private final CameraCaptureCallback mCaptureCallback;
  /** A {@link Handler} for running tasks in the background. */
  private Handler mBackgroundHandler;
  /**
   * This a callback object for the {@link ImageReader}. "onImageAvailable" will be called when a
   * still image is ready to be saved.
   */
  private final ImageReader.OnImageAvailableListener mOnImageAvailableListener =
      new ImageReader.OnImageAvailableListener() {
        @Override
        public void onImageAvailable(ImageReader reader) {
          Log.i(TAG, "onImageAvailable");

          // Use acquireNextImage since our image reader is only for 1 image.
          mBackgroundHandler.post(
              new ImageSaver(
                  reader.acquireNextImage(), pictureCaptureRequest.file, pictureCaptureRequest));
          mCaptureCallback.setCameraState(CameraState.STATE_PREVIEW);
        }
      };
  /** An additional thread for running tasks that shouldn't block the UI. */
  private HandlerThread mBackgroundThread;

  private CameraDevice cameraDevice;
  private CameraCaptureSession captureSession;
  private ImageReader pictureImageReader;
  private ImageReader imageStreamReader;
  /** {@link CaptureRequest.Builder} for the camera preview */
  private CaptureRequest.Builder mPreviewRequestBuilder;
  private MediaRecorder mediaRecorder;
  /** True when recording video. */
  private boolean recordingVideo;

  private File videoRecordingFile;

  /** Holds the current picture capture request and its related timeouts */
  private PictureCaptureRequest pictureCaptureRequest;

  public Camera(
      final Activity activity,
      final SurfaceTextureEntry flutterTexture,
      final CameraFeatureFactory cameraFeatureFactory,
      final DartMessenger dartMessenger,
      final CameraProperties cameraProperties,
      final ResolutionPreset resolutionPreset,
      final boolean enableAudio) {

    if (activity == null) {
      throw new IllegalStateException("No activity available!");
    }
    this.activity = activity;
    this.enableAudio = enableAudio;
    this.flutterTexture = flutterTexture;
    this.dartMessenger = dartMessenger;
    this.applicationContext = activity.getApplicationContext();
    this.cameraProperties = cameraProperties;

    // Setup camera features
    this.cameraFeatures =
        new HashMap<CameraFeatures, CameraFeature>() {
          {
            put(
                CameraFeatures.resolution,
                cameraFeatureFactory.createResolutionFeature(
                    cameraProperties, resolutionPreset, cameraProperties.getCameraName()));
            put(
                CameraFeatures.autoFocus,
                cameraFeatureFactory.createAutoFocusFeature(cameraProperties, false));
            put(
                CameraFeatures.sensorOrientation,
                cameraFeatureFactory.createSensorOrientationFeature(
                    cameraProperties, activity, dartMessenger));
            put(
                CameraFeatures.exposureLock,
                cameraFeatureFactory.createExposureLockFeature(cameraProperties));
            put(
                CameraFeatures.exposureOffset,
                cameraFeatureFactory.createExposureOffsetFeature(cameraProperties));
            put(
                CameraFeatures.exposurePoint,
                cameraFeatureFactory.createExposurePointFeature(
                    cameraProperties, () -> getCameraRegions()));
            put(
                CameraFeatures.focusPoint,
                cameraFeatureFactory.createFocusPointFeature(
                    cameraProperties, () -> getCameraRegions()));
            put(CameraFeatures.flash, cameraFeatureFactory.createFlashFeature(cameraProperties));
            put(
                CameraFeatures.fpsRange,
                cameraFeatureFactory.createFpsRangeFeature(cameraProperties));
            put(
                CameraFeatures.noiseReduction,
                cameraFeatureFactory.createNoiseReductionFeature(cameraProperties));
            put(
                CameraFeatures.zoomLevel,
                cameraFeatureFactory.createZoomLevelFeature(cameraProperties));

            // Note: CameraFeatures.regionBoundaries will be created in CreateCaptureSession.
          }
        };

    // Create capture callback
    mCaptureCallback = CameraCaptureCallback.create(this);

    // Start background thread.
    startBackgroundThread();
  }

  @Override
  public void onConverged() {
    takePictureAfterPrecapture();
  }

  @Override
  public void onPrecapture() {
    runPrecaptureSequence();
  }

  /**
   * Update the builder settings with all of our available features.
   *
   * @param requestBuilder request builder to update.
   */
  private void updateBuilderSettings(CaptureRequest.Builder requestBuilder) {
    for (Map.Entry<CameraFeatures, CameraFeature> feature : cameraFeatures.entrySet()) {
      Log.i(TAG, "Updating builder with feature: " + feature.getValue().getDebugName());
      feature.getValue().updateBuilder(requestBuilder);
    }
  }

  private void prepareMediaRecorder(String outputFilePath) throws IOException {
    Log.i(TAG, "prepareMediaRecorder");

    if (mediaRecorder != null) {
      mediaRecorder.release();
    }

    final PlatformChannel.DeviceOrientation lockedOrientation =
        ((SensorOrientationFeature) cameraFeatures.get(CameraFeatures.sensorOrientation))
            .getLockedCaptureOrientation();

    mediaRecorder =
        new MediaRecorderBuilder(getRecordingProfile(), outputFilePath)
            .setEnableAudio(enableAudio)
            .setMediaOrientation(
                lockedOrientation == null
                    ? getDeviceOrientationManager().getMediaOrientation()
                    : getDeviceOrientationManager().getMediaOrientation(lockedOrientation))
            .build();
  }

  @SuppressLint("MissingPermission")
  public void open(String imageFormatGroup) throws CameraAccessException {
    // We always capture using JPEG format.
    pictureImageReader =
        ImageReader.newInstance(
            getCaptureSize().getWidth(), getCaptureSize().getHeight(), ImageFormat.JPEG, 1);

    // For image streaming, we use the provided image format or fall back to YUV420.
    Integer imageFormat = supportedImageFormats.get(imageFormatGroup);
    if (imageFormat == null) {
      Log.w(TAG, "The selected imageFormatGroup is not supported by Android. Defaulting to yuv420");
      imageFormat = ImageFormat.YUV_420_888;
    }
    imageStreamReader =
        ImageReader.newInstance(
            getPreviewSize().getWidth(), getPreviewSize().getHeight(), imageFormat, 1);

    // Open the camera now
    CameraManager cameraManager = CameraUtils.getCameraManager(activity);
    cameraManager.openCamera(
        cameraProperties.getCameraName(),
        new CameraDevice.StateCallback() {
          @Override
          public void onOpened(@NonNull CameraDevice device) {
            Log.i(TAG, "open | onOpened");

            cameraDevice = device;
            try {
              startPreview();

              final boolean isExposurePointSupported =
                  cameraFeatures.get(CameraFeatures.exposurePoint).checkIsSupported();
              final boolean isFocusPointSupported =
                  cameraFeatures.get(CameraFeatures.focusPoint).checkIsSupported();

              dartMessenger.sendCameraInitializedEvent(
                  getPreviewSize().getWidth(),
                  getPreviewSize().getHeight(),
                  (ExposureMode) cameraFeatures.get(CameraFeatures.exposureLock).getValue(),
                  (FocusMode) cameraFeatures.get(CameraFeatures.autoFocus).getValue(),
                  isExposurePointSupported,
                  isFocusPointSupported);
            } catch (CameraAccessException e) {
              dartMessenger.sendCameraErrorEvent(e.getMessage());
              close();
            }
          }

          @Override
          public void onClosed(@NonNull CameraDevice camera) {
            Log.i(TAG, "open | onClosed");

            dartMessenger.sendCameraClosingEvent();
            super.onClosed(camera);
          }

          @Override
          public void onDisconnected(@NonNull CameraDevice cameraDevice) {
            Log.i(TAG, "open | onDisconnected");

            close();
            dartMessenger.sendCameraErrorEvent("The camera was disconnected.");
          }

          @Override
          public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
            Log.i(TAG, "open | onError");

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
        mBackgroundHandler);
  }

  private void createCaptureSession(int templateType, Surface... surfaces)
      throws CameraAccessException {
    createCaptureSession(templateType, null, surfaces);
  }

  private void createCaptureSession(
      int templateType, Runnable onSuccessCallback, Surface... surfaces)
      throws CameraAccessException {
    Log.i(TAG, "createCaptureSession");

    // Close any existing capture session.
    closeCaptureSession();

    // Create a new capture builder.
    mPreviewRequestBuilder = cameraDevice.createCaptureRequest(templateType);

    // Build Flutter surface to render to
    SurfaceTexture surfaceTexture = flutterTexture.surfaceTexture();
    surfaceTexture.setDefaultBufferSize(getPreviewSize().getWidth(), getPreviewSize().getHeight());
    Surface flutterSurface = new Surface(surfaceTexture);
    mPreviewRequestBuilder.addTarget(flutterSurface);

    List<Surface> remainingSurfaces = Arrays.asList(surfaces);
    if (templateType != CameraDevice.TEMPLATE_PREVIEW) {
      // If it is not preview mode, add all surfaces as targets.
      for (Surface surface : remainingSurfaces) {
        mPreviewRequestBuilder.addTarget(surface);
      }
    }

    // Update camera regions
    cameraFeatures.put(
        CameraFeatures.regionBoundaries,
        new RegionBoundariesFeature(cameraProperties, mPreviewRequestBuilder));

    // Prepare the callback
    CameraCaptureSession.StateCallback callback =
        new CameraCaptureSession.StateCallback() {
          @Override
          public void onConfigured(@NonNull CameraCaptureSession session) {
            // Camera was already closed.
            if (cameraDevice == null) {
              dartMessenger.sendCameraErrorEvent("The camera was closed during configuration.");
              return;
            }
            captureSession = session;

            Log.i(TAG, "Updating builder settings");
            updateBuilderSettings(mPreviewRequestBuilder);

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
    cameraDevice.createCaptureSession(surfaces, callback, mBackgroundHandler);
  }

  // Send a repeating request to refresh our capture session.
  private void refreshPreviewCaptureSession(
      @Nullable Runnable onSuccessCallback, @NonNull ErrorCallback onErrorCallback) {
    Log.i(TAG, "refreshPreviewCaptureSession");
    if (captureSession == null) {
      Log.i(TAG, "[refreshPreviewCaptureSession] mPreviewSession null, returning");
      return;
    }

    try {
      captureSession.setRepeatingRequest(
          mPreviewRequestBuilder.build(), mCaptureCallback, mBackgroundHandler);

      if (onSuccessCallback != null) {
        onSuccessCallback.run();
      }

    } catch (CameraAccessException | IllegalStateException | IllegalArgumentException e) {
      onErrorCallback.onError("cameraAccess", e.getMessage());
    }
  }

  public void takePicture(@NonNull final Result result) {
    Log.i(
        TAG,
        "takePicture | useAutoFocus: " + cameraFeatures.get(CameraFeatures.autoFocus).getValue());

    // Only take one 1 picture at a time.
    if (mCaptureCallback.getCameraState() != CameraState.STATE_PREVIEW) {
      result.error("captureAlreadyActive", "Picture is currently already being captured", null);
      return;
    }

    // Create temporary file
    final File outputDir = applicationContext.getCacheDir();
    try {
      final File file = File.createTempFile("CAP", ".jpg", outputDir);

      // Start a new capture
      pictureCaptureRequest = PictureCaptureRequest.create(result, file, 3000, 3000);
      mCaptureCallback.setPictureCaptureRequest(pictureCaptureRequest);
    } catch (IOException | SecurityException e) {
      pictureCaptureRequest.error("cannotCreateFile", e.getMessage(), null);
      return;
    }

    // Listen for picture being taken
    pictureImageReader.setOnImageAvailableListener(mOnImageAvailableListener, mBackgroundHandler);

    final AutoFocusFeature autoFocusFeature =
        (AutoFocusFeature) cameraFeatures.get(CameraFeatures.autoFocus);
    final boolean isAutoFocusSupported = autoFocusFeature.checkIsSupported();
    if (isAutoFocusSupported && autoFocusFeature.getValue() == FocusMode.auto) {
      runPictureAutoFocus();
    } else {
      runPrecaptureSequence();
    }
  }

  /**
   * Run the precapture sequence for capturing a still image. This method should be called when we
   * get a response in {@link #mCaptureCallback} from lockFocus().
   */
  private void runPrecaptureSequence() {
    Log.i(TAG, "runPrecaptureSequence");
    try {
      // First set precapture state to idle or else it can hang in STATE_WAITING_PRECAPTURE_START
      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE);
      captureSession.capture(mPreviewRequestBuilder.build(), mCaptureCallback, mBackgroundHandler);

      // Repeating request to refresh preview session
      refreshPreviewCaptureSession(
          null, (code, message) -> pictureCaptureRequest.error("cameraAccess", message, null));

      // Start precapture now
      mCaptureCallback.setCameraState(CameraState.STATE_WAITING_PRECAPTURE_START);

      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_START);

      // Trigger one capture to start AE sequence
      captureSession.capture(mPreviewRequestBuilder.build(), mCaptureCallback, mBackgroundHandler);

    } catch (CameraAccessException e) {
      e.printStackTrace();
    }
  }

  /**
   * Capture a still picture. This method should be called when we get a response in {@link
   * #mCaptureCallback} from both lockFocus().
   */
  private void takePictureAfterPrecapture() {
    Log.i(TAG, "captureStillPicture");
    mCaptureCallback.setCameraState(CameraState.STATE_CAPTURING);

    try {
      if (null == cameraDevice) {
        return;
      }
      // This is the CaptureRequest.Builder that we use to take a picture.
      final CaptureRequest.Builder stillBuilder =
          cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_STILL_CAPTURE);
      stillBuilder.addTarget(pictureImageReader.getSurface());

      // Zoom
      stillBuilder.set(
          CaptureRequest.SCALER_CROP_REGION,
          mPreviewRequestBuilder.get(CaptureRequest.SCALER_CROP_REGION));

      // Update builder settings
      updateBuilderSettings(stillBuilder);

      // Orientation
      int rotation = activity.getWindowManager().getDefaultDisplay().getRotation();
      stillBuilder.set(CaptureRequest.JPEG_ORIENTATION, getOrientation(rotation));

      CameraCaptureSession.CaptureCallback captureCallback =
          new CameraCaptureSession.CaptureCallback() {

            @Override
            public void onCaptureStarted(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                long timestamp,
                long frameNumber) {
              Log.i(TAG, "onCaptureStarted");
            }

            @Override
            public void onCaptureProgressed(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                @NonNull CaptureResult partialResult) {
              Log.i(TAG, "onCaptureProgressed");
            }

            @Override
            public void onCaptureCompleted(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                @NonNull TotalCaptureResult result) {
              Log.i(TAG, "onCaptureCompleted");
              unlockAutoFocus();
            }
          };

      captureSession.stopRepeating();
      captureSession.abortCaptures();
      Log.i(TAG, "sending capture request");
      captureSession.capture(stillBuilder.build(), captureCallback, mBackgroundHandler);
    } catch (CameraAccessException e) {
      pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
    }
  }

  /** Starts a background thread and its {@link Handler}. TODO: call when activity resumed */
  private void startBackgroundThread() {
    mBackgroundThread = new HandlerThread("CameraBackground");
    mBackgroundThread.start();
    mBackgroundHandler = new Handler(mBackgroundThread.getLooper());
  }

  /** Stops the background thread and its {@link Handler}. TODO: call when activity paused */
  private void stopBackgroundThread() {
    try {
      if (mBackgroundThread != null) {
        mBackgroundThread.quitSafely();
        mBackgroundThread.join();
        mBackgroundThread = null;
      }

      mBackgroundHandler = null;
    } catch (InterruptedException e) {
      pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
    }
  }

  /**
   * Retrieves the JPEG orientation from the specified screen rotation.
   *
   * @param rotation The screen rotation.
   * @return The JPEG orientation (one of 0, 90, 270, and 360)
   */
  private int getOrientation(int rotation) {
    // Sensor orientation is 90 for most devices, or 270 for some devices (eg. Nexus 5X)
    // We have to take that into account and rotate JPEG properly.
    // For devices with orientation of 90, we simply return our mapping from ORIENTATIONS.
    // For devices with orientation of 270, we need to rotate the JPEG 180 degrees.
    final Integer sensorOrientation =
        (Integer) cameraFeatures.get(CameraFeatures.sensorOrientation).getValue();
    return (ORIENTATIONS.get(rotation) + sensorOrientation + 270) % 360;
  }

  /** Start capturing a picture, doing autofocus first. */
  private void runPictureAutoFocus() {
    Log.i(TAG, "runPictureAutoFocus");
    assert (pictureCaptureRequest != null);

    mCaptureCallback.setCameraState(CameraState.STATE_WAITING_FOCUS);
    lockAutoFocus();
  }

  /**
   * Start the autofocus routine on the current capture request and calls the onCompleted callback.
   */
  private void lockAutoFocus() {
    Log.i(TAG, "lockAutoFocus");

    // Trigger AF to start
    mPreviewRequestBuilder.set(
        CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_START);

    try {
      captureSession.capture(mPreviewRequestBuilder.build(), null, mBackgroundHandler);
    } catch (CameraAccessException e) {
      Log.i(TAG, "Error unlocking focus: " + e.getMessage());
      dartMessenger.sendCameraErrorEvent(e.getMessage());
      return;
    }
  }

  /** Cancel and reset auto focus state and refresh the preview session. */
  private void unlockAutoFocus() {
    Log.i(TAG, "unlockAutoFocus");
    try {
      // Cancel existing AF state
      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_CANCEL);
      captureSession.capture(mPreviewRequestBuilder.build(), null, mBackgroundHandler);

      // Set AF state to idle again
      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_IDLE);

      captureSession.capture(mPreviewRequestBuilder.build(), null, mBackgroundHandler);
    } catch (CameraAccessException e) {
      Log.i(TAG, "Error unlocking focus: " + e.getMessage());
      dartMessenger.sendCameraErrorEvent(e.getMessage());
      return;
    }

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

      // Re-create autofocus feature so it's using video focus mode now
      cameraFeatures.put(CameraFeatures.autoFocus, new AutoFocusFeature(cameraProperties, true));
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
      // Re-create autofocus feature so it's using continuous capture focus mode now
      cameraFeatures.put(CameraFeatures.autoFocus, new AutoFocusFeature(cameraProperties, false));
      recordingVideo = false;

      try {
        captureSession.abortCaptures();
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

  /**
   * Dart handler when it's time to set a new flash mode. This will try to set a new flash mode to
   * the current camera.
   *
   * @param result Flutter result.
   * @param newMode new mode.
   */
  public void setFlashMode(@NonNull final Result result, FlashMode newMode) {
    // Save the new flash mode setting
    ((FlashFeature) cameraFeatures.get(CameraFeatures.flash)).setValue(newMode);
    cameraFeatures.get(CameraFeatures.flash).updateBuilder(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(null),
        (code, message) -> result.error("setFlashModeFailed", "Could not set flash mode.", null));
  }

  /**
   * Dart handler for setting new exposure mode setting.
   *
   * @param result Flutter result.
   * @param newMode new mode.
   */
  public void setExposureMode(@NonNull final Result result, ExposureMode newMode) {
    ((ExposureLockFeature) cameraFeatures.get(CameraFeatures.exposureLock)).setValue(newMode);
    cameraFeatures.get(CameraFeatures.exposureLock).updateBuilder(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(null),
        (code, message) ->
            result.error("setExposureModeFailed", "Could not set exposure mode.", null));
  }

  /**
   * Get the current camera regions. Used in ExposurePoint feature so it can always get a reference
   * to the latest camera regions instance here.
   *
   * <p>The CameraRegions will be replaced every time a new capture session is started.
   *
   * @return camera region object.
   */
  public CameraRegions getCameraRegions() {
    final RegionBoundariesFeature regionBoundaries =
        (RegionBoundariesFeature) cameraFeatures.get(CameraFeatures.regionBoundaries);
    return regionBoundaries.getCameraRegions();
  }

  /**
   * Set new exposure point from dart.
   *
   * @param result Flutter result.
   * @param x new x.
   * @param y new y.
   */
  public void setExposurePoint(@NonNull final Result result, Double x, Double y) {
    ((ExposurePointFeature) cameraFeatures.get(CameraFeatures.exposurePoint))
        .setValue(new Point(x, y));
    cameraFeatures.get(CameraFeatures.exposurePoint).updateBuilder(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(null),
        (code, message) ->
            result.error("setExposurePointFailed", "Could not set exposure point.", null));
  }

  /** Return the max exposure offset value supported by the camera to dart. */
  public double getMaxExposureOffset() {
    final ExposureOffsetValue val =
        (ExposureOffsetValue) cameraFeatures.get(CameraFeatures.exposureOffset).getValue();
    return val.max;
  }

  /** Return the min exposure offset value supported by the camera to dart. */
  public double getMinExposureOffset() {
    final ExposureOffsetValue val =
        (ExposureOffsetValue) cameraFeatures.get(CameraFeatures.exposureOffset).getValue();
    return val.min;
  }

  /** Return the exposure offset step size to dart. */
  public double getExposureOffsetStepSize() {
    final ExposureOffsetFeature val =
        (ExposureOffsetFeature) cameraFeatures.get(CameraFeatures.exposureOffset);
    return val.getExposureOffsetStepSize();
  }

  /**
   * Set new focus mode from dart.
   *
   * @param result Flutter result.
   * @param newMode New mode.
   */
  public void setFocusMode(@NonNull final Result result, FocusMode newMode) {
    ((AutoFocusFeature) cameraFeatures.get(CameraFeatures.autoFocus)).setValue(newMode);

    cameraFeatures.get(CameraFeatures.autoFocus).updateBuilder(mPreviewRequestBuilder);

    /*
     * For focus mode we need to do an extra step of actually locking/unlocking the
     * focus in order to ensure it goes into the correct state.
     */
    switch (newMode) {
      case locked:
        // Perform a single focus trigger
        lockAutoFocus();

        // Set AF state to idle again
        mPreviewRequestBuilder.set(
            CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_IDLE);

        try {
          captureSession.setRepeatingRequest(
              mPreviewRequestBuilder.build(), null, mBackgroundHandler);
        } catch (CameraAccessException e) {
          result.error("setFocusModeFailed", "Error setting focus mode: " + e.getMessage(), null);
        }
        break;

      case auto:
        // Cancel current AF trigger and set AF to idle again
        unlockAutoFocus();
        break;
    }

    result.success(null);
  }

  /**
   * Sets new focus point from dart.
   *
   * @param result Flutter result.
   * @param x new x.
   * @param y new y.
   */
  public void setFocusPoint(@NonNull final Result result, Double x, Double y) {
    ((FocusPointFeature) cameraFeatures.get(CameraFeatures.focusPoint)).setValue(new Point(x, y));
    cameraFeatures.get(CameraFeatures.focusPoint).updateBuilder(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(null),
        (code, message) -> result.error("setFocusPointFailed", "Could not set focus point.", null));
  }

  /**
   * Set a new exposure offset from dart. From dart the offset comes as a double, like +1.3 or -1.3.
   *
   * @param result flutter result.
   * @param offset new value.
   */
  public void setExposureOffset(@NonNull final Result result, double offset) {
    ((ExposureOffsetFeature) cameraFeatures.get(CameraFeatures.exposureOffset))
        .setValue(new ExposureOffsetValue(offset));
    cameraFeatures.get(CameraFeatures.exposureOffset).updateBuilder(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(null),
        (code, message) -> result.error("setFocusModeFailed", "Could not set focus mode.", null));
  }

  public float getMaxZoomLevel() {
    final ZoomLevelFeature zoomLevel =
        (ZoomLevelFeature) cameraFeatures.get(CameraFeatures.zoomLevel);
    return zoomLevel.getCameraZoom().maxZoom;
  }

  public float getMinZoomLevel() {
    return CameraZoom.DEFAULT_ZOOM_FACTOR;
  }

  /** Shortcut to get current preview size. */
  Size getPreviewSize() {
    return ((ResolutionFeature) cameraFeatures.get(CameraFeatures.resolution)).getPreviewSize();
  }

  /** Shortcut to get current capture size. */
  Size getCaptureSize() {
    return ((ResolutionFeature) cameraFeatures.get(CameraFeatures.resolution)).getCaptureSize();
  }

  /** Shortcut to get current recording profile. */
  CamcorderProfile getRecordingProfile() {
    return ((ResolutionFeature) cameraFeatures.get(CameraFeatures.resolution))
        .getRecordingProfile();
  }

  /** Shortut to get deviceOrientationListener. */
  DeviceOrientationManager getDeviceOrientationManager() {
    return ((SensorOrientationFeature) cameraFeatures.get(CameraFeatures.sensorOrientation))
        .getDeviceOrientationManager();
  }

  /**
   * Set zoom level from dart.
   *
   * @param result Flutter result.
   * @param zoom new value.
   */
  public void setZoomLevel(@NonNull final Result result, float zoom) throws CameraAccessException {
    final ZoomLevelFeature zoomLevel =
        (ZoomLevelFeature) cameraFeatures.get(CameraFeatures.zoomLevel);
    float maxZoom = zoomLevel.getCameraZoom().maxZoom;
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

    zoomLevel.setValue(zoom);
    zoomLevel.updateBuilder(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(null),
        (code, message) -> result.error("setZoomLevelFailed", "Could not set zoom level.", null));
  }

  /**
   * Lock capture orientation from dart.
   *
   * @param orientation new orientation.
   */
  public void lockCaptureOrientation(PlatformChannel.DeviceOrientation orientation) {
    ((SensorOrientationFeature) cameraFeatures.get(CameraFeatures.sensorOrientation))
        .lockCaptureOrientation(orientation);
  }

  /** Unlock capture orientation from dart. */
  public void unlockCaptureOrientation() {
    ((SensorOrientationFeature) cameraFeatures.get(CameraFeatures.sensorOrientation))
        .unlockCaptureOrientation();
  }

  public void startPreview() throws CameraAccessException {
    if (pictureImageReader == null || pictureImageReader.getSurface() == null) return;
    Log.i(TAG, "startPreview");

    createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, pictureImageReader.getSurface());
  }

  public void startPreviewWithImageStream(EventChannel imageStreamChannel)
      throws CameraAccessException {
    createCaptureSession(CameraDevice.TEMPLATE_RECORD, imageStreamReader.getSurface());
    Log.i(TAG, "startPreviewWithImageStream");

    imageStreamChannel.setStreamHandler(
        new EventChannel.StreamHandler() {
          @Override
          public void onListen(Object o, EventChannel.EventSink imageStreamSink) {
            setImageStreamImageAvailableListener(imageStreamSink);
          }

          @Override
          public void onCancel(Object o) {
            imageStreamReader.setOnImageAvailableListener(null, mBackgroundHandler);
          }
        });
  }

  private void setImageStreamImageAvailableListener(final EventChannel.EventSink imageStreamSink) {
    imageStreamReader.setOnImageAvailableListener(
        reader -> {
          // Use acquireNextImage since our image reader is only for 1 image.
          Image img = reader.acquireNextImage();
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

          final Handler handler = new Handler(Looper.getMainLooper());
          handler.post(() -> imageStreamSink.success(imageBuffer));
          img.close();
        },
        mBackgroundHandler);
  }

  private void closeCaptureSession() {
    if (captureSession != null) {
      Log.i(TAG, "closeCaptureSession");

      captureSession.close();
      captureSession = null;
    }
  }

  public void close() {
    Log.i(TAG, "close");
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

    stopBackgroundThread();
  }

  public void dispose() {
    Log.i(TAG, "dispose");

    close();
    flutterTexture.release();
    getDeviceOrientationManager().stop();
  }
}
