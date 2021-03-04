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
import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.CameraDevice;
import android.hardware.camera2.CameraManager;
import android.hardware.camera2.CameraMetadata;
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
import android.os.HandlerThread;
import android.os.Looper;
import android.util.Log;
import android.util.Range;
import android.util.Rational;
import android.util.Size;
import android.util.SparseIntArray;
import android.view.Surface;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.engine.systemchannels.PlatformChannel;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.camera.media.MediaRecorderBuilder;
import io.flutter.plugins.camera.types.ExposureMode;
import io.flutter.plugins.camera.types.FlashMode;
import io.flutter.plugins.camera.types.FocusMode;
import io.flutter.plugins.camera.types.ResolutionPreset;
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

public class Camera {
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

  private final SurfaceTextureEntry flutterTexture;
  private final DeviceOrientationManager deviceOrientationListener;
  private final boolean isFrontFacing;
  private final int sensorOrientation;
  private final Size captureSize;
  private final Size previewSize;
  private final boolean enableAudio;
  private final Context applicationContext;
  private final CamcorderProfile recordingProfile;
  private final DartMessenger dartMessenger;
  private final CameraZoom cameraZoom;
  private final CameraProperties cameraProperties;
  private final Activity activity;
  /** This manages the state of the camera and the current capture request. */
  PictureCaptureRequest pictureCaptureRequest;
  /** Whether the current camera device supports auto focus or not. */
  private boolean mAutoFocusSupported = true;
  /** The state of the camera. By default we are in the preview state. */
  private CameraState cameraState = CameraState.STATE_PREVIEW;
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
          // Log.i(TAG, "onImageAvailable");

          // Use acquireNextImage since our image reader is only for 1 image.
          mBackgroundHandler.post(
              new ImageSaver(
                  reader.acquireNextImage(), pictureCaptureRequest.file, pictureCaptureRequest));
          cameraState = CameraState.STATE_PREVIEW;
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
  /** {@link CaptureRequest} generated by {@link #mPreviewRequestBuilder} */
  private MediaRecorder mediaRecorder;

  private boolean recordingVideo;
  private File videoRecordingFile;
  /**
   * Flash mode setting of the current camera. Initialize to off because we don't know if the
   * current camera supports flash yet.
   */
  private FlashMode currentFlashMode;
  /**
   * Exposure mode setting of the current camera. Initialize to auto because all cameras support
   * autoexposure by default.
   */
  private ExposureMode currentExposureMode;
  /**
   * Focus mode setting of the current camera. Initialize to locked because we don't know if the
   * current camera supports autofocus yet.
   */
  private FocusMode currentFocusMode;
  /** Whether or not to use autofocus. */
  private boolean useAutoFocus = false;
  /** Whether the current camera device supports Flash or not. */
  private boolean mFlashSupported = false;

  private CameraRegions cameraRegions;
  private int exposureOffset;
  /** A {@link CameraCaptureSession.CaptureCallback} that handles events related to JPEG capture. */
  private final CameraCaptureSession.CaptureCallback mCaptureCallback =
      new CameraCaptureSession.CaptureCallback() {

        private void process(CaptureResult result) {
          Integer aeState = result.get(CaptureResult.CONTROL_AE_STATE);
          Integer afState = result.get(CaptureResult.CONTROL_AF_STATE);

          if (cameraState != CameraState.STATE_PREVIEW) {
            // Log.i(TAG, "mCaptureCallback | state: " + cameraState + " | afState: " + afState + " | aeState: " + aeState);
          }

          switch (cameraState) {
            case STATE_PREVIEW:
              {
                // We have nothing to do when the camera preview is working normally.
                break;
              }

            case STATE_WAITING_FOCUS:
              {
                if (afState == null) {
                  return;
                } else if (afState == CaptureRequest.CONTROL_AF_STATE_PASSIVE_SCAN
                    || afState == CaptureRequest.CONTROL_AF_STATE_FOCUSED_LOCKED
                    || afState == CaptureRequest.CONTROL_AF_STATE_NOT_FOCUSED_LOCKED) {
                  // CONTROL_AE_STATE can be null on some devices

                  if (aeState == null || aeState == CaptureRequest.CONTROL_AE_STATE_CONVERGED) {
                    takePictureAfterPrecapture();
                  } else {
                    runPrecaptureSequence();
                  }
                }
                break;
              }

            case STATE_WAITING_PRECAPTURE_START:
              {
                // CONTROL_AE_STATE can be null on some devices
                if (aeState == null
                    || aeState == CaptureResult.CONTROL_AE_STATE_CONVERGED
                    || aeState == CaptureResult.CONTROL_AE_STATE_PRECAPTURE
                    || aeState == CaptureResult.CONTROL_AE_STATE_FLASH_REQUIRED) {
                  cameraState = CameraState.STATE_WAITING_PRECAPTURE_DONE;
                  pictureCaptureRequest.setState(
                      PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_DONE);
                }
                break;
              }

            case STATE_WAITING_PRECAPTURE_DONE:
              {
                // CONTROL_AE_STATE can be null on some devices
                if (aeState == null || aeState != CaptureResult.CONTROL_AE_STATE_PRECAPTURE) {
                  takePictureAfterPrecapture();
                } else {
                  if (pictureCaptureRequest.hitPreCaptureTimeout()) {
                    // Log.i(TAG, "===> Hit precapture timeout");
                    unlockAutoFocus();
                  }
                }
                break;
              }
          }
        }

        @Override
        public void onCaptureProgressed(
            @NonNull CameraCaptureSession session,
            @NonNull CaptureRequest request,
            @NonNull CaptureResult partialResult) {
          process(partialResult);
        }

        @Override
        public void onCaptureCompleted(
            @NonNull CameraCaptureSession session,
            @NonNull CaptureRequest request,
            @NonNull TotalCaptureResult result) {
          process(result);
        }
      };

  private Range<Integer> fpsRange;
  private PlatformChannel.DeviceOrientation lockedCaptureOrientation;

  public Camera(
      final Activity activity,
      final SurfaceTextureEntry flutterTexture,
      final DartMessenger dartMessenger,
      final CameraProperties cameraProperties,
      final ResolutionPreset resolutionPreset,
      final boolean enableAudio) {
    this(
        activity,
        flutterTexture,
        dartMessenger,
        cameraProperties,
        resolutionPreset,
        enableAudio,
        null);
  }

  public Camera(
      final Activity activity,
      final SurfaceTextureEntry flutterTexture,
      final DartMessenger dartMessenger,
      final CameraProperties cameraProperties,
      final ResolutionPreset resolutionPreset,
      final boolean enableAudio,
      @Nullable final DeviceOrientationManager deviceOrientationManager) {

    if (activity == null) {
      throw new IllegalStateException("No activity available!");
    }

    this.activity = activity;
    this.enableAudio = enableAudio;
    this.flutterTexture = flutterTexture;
    this.dartMessenger = dartMessenger;
    this.applicationContext = activity.getApplicationContext();
    this.cameraProperties = cameraProperties;
    this.currentFlashMode = FlashMode.off;
    this.currentExposureMode = ExposureMode.auto;
    this.currentFocusMode = FocusMode.auto;
    this.exposureOffset = 0;

    // Get camera characteristics and check for supported features
    getAvailableFpsRange(cameraProperties);
    mAutoFocusSupported = checkAutoFocusSupported(cameraProperties);
    checkFlashSupported();

    // Setup orientation
    sensorOrientation = cameraProperties.getSensorOrientation();
    isFrontFacing = cameraProperties.getLensFacing() == CameraMetadata.LENS_FACING_FRONT;

    deviceOrientationListener =
        deviceOrientationManager != null
            ? deviceOrientationManager
            : new DeviceOrientationManager(
                activity, dartMessenger, isFrontFacing, sensorOrientation);
    deviceOrientationListener.start();

    String cameraName = cameraProperties.getCameraName();

    // Resolution configuration
    recordingProfile =
        CameraUtils.getBestAvailableCamcorderProfileForResolutionPreset(
            cameraName, resolutionPreset);
    captureSize = new Size(recordingProfile.videoFrameWidth, recordingProfile.videoFrameHeight);
    // Log.i(TAG, "captureSize: " + captureSize);

    previewSize = computeBestPreviewSize(cameraName, resolutionPreset);

    // Zoom setup
    cameraZoom =
        new CameraZoom(
            cameraProperties.getSensorInfoActiveArraySize(),
            cameraProperties.getScalerAvailableMaxDigitalZoom());

    // Start background thread.
    startBackgroundThread();
  }

  /** Get the current camera state (use for testing). */
  public CameraState getState() {
    return this.cameraState;
  }

  /**
   * Check if the auto focus is supported by the current camera. We look at the available AF modes
   * and the available lens focusing distance to determine if its' a fixed length lens or not as
   * well.
   */
  public static boolean checkAutoFocusSupported(CameraProperties cameraProperties) {
    int[] modes = cameraProperties.getControlAutoFocusAvailableModes();
    // Log.i(TAG, "checkAutoFocusSupported | modes:");
    for (int mode : modes) {
      // Log.i(TAG, "checkAutoFocusSupported | ==> " + mode);
    }

    // Check if fixed focal length lens. If LENS_INFO_MINIMUM_FOCUS_DISTANCE=0, then this is fixed.
    // Can be null on some devices.
    final Float minFocus = cameraProperties.getLensInfoMinimumFocusDistance();
    // final Float maxFocus = cameraCharacteristics.get(CameraCharacteristics.LENS_INFO_HYPERFOCAL_DISTANCE);

    // Value can be null on some devices:
    // https://developer.android.com/reference/android/hardware/camera2/CameraCharacteristics#LENS_INFO_MINIMUM_FOCUS_DISTANCE
    boolean isFixedLength;
    if (minFocus == null) {
      isFixedLength = true;
    } else {
      isFixedLength = minFocus == 0;
    }
    // Log.i(TAG, "checkAutoFocusSupported | minFocus " + minFocus + " | maxFocus: " + maxFocus);

    return !isFixedLength
        && !(modes == null
            || modes.length == 0
            || (modes.length == 1 && modes[0] == CameraCharacteristics.CONTROL_AF_MODE_OFF));
    // Log.i(TAG, "checkAutoFocusSupported: " + mAutoFocusSupported);
  }

  /** Check if the flash is supported. */
  private void checkFlashSupported() {
    Boolean available = cameraProperties.getFlashInfoAvailable();
    mFlashSupported = available != null && available;
  }

  /**
   * Load available FPS range for the current camera and update the available fps range with it.
   *
   * @param cameraProperties
   */
  private void getAvailableFpsRange(CameraProperties cameraProperties) {
    // Log.i(TAG, "getAvailableFpsRange");

    try {
      Range<Integer>[] ranges = cameraProperties.getControlAutoExposureAvailableTargetFpsRanges();

      if (ranges != null) {
        for (Range<Integer> range : ranges) {
          int upper = range.getUpper();
          // Log.i("Camera", "[FPS Range Available] is:" + range);
          if (upper >= 10) {
            if (fpsRange == null || upper > fpsRange.getUpper()) {
              fpsRange = range;
            }
          }
        }
      }
    } catch (Exception e) {
      pictureCaptureRequest.error("cameraAccess", e.getMessage(), null);
    }
    // Log.i("Camera", "[FPS Range] is:" + fpsRange);
  }

  private void prepareMediaRecorder(String outputFilePath) throws IOException {
    // Log.i(TAG, "prepareMediaRecorder");

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
    // We always capture using JPEG format.
    pictureImageReader =
        ImageReader.newInstance(
            captureSize.getWidth(), captureSize.getHeight(), ImageFormat.JPEG, 1);

    // For image streaming, we use the provided image format or fall back to YUV420.
    Integer imageFormat = supportedImageFormats.get(imageFormatGroup);
    if (imageFormat == null) {
      Log.w(TAG, "The selected imageFormatGroup is not supported by Android. Defaulting to yuv420");
      imageFormat = ImageFormat.YUV_420_888;
    }
    imageStreamReader =
        ImageReader.newInstance(previewSize.getWidth(), previewSize.getHeight(), imageFormat, 1);

    // Open the camera now
    CameraManager cameraManager = CameraUtils.getCameraManager(activity);
    cameraManager.openCamera(
        cameraProperties.getCameraName(),
        new CameraDevice.StateCallback() {
          @Override
          public void onOpened(@NonNull CameraDevice device) {
            // Log.i(TAG, "open | onOpened");

            cameraDevice = device;
            try {
              startPreview();
              dartMessenger.sendCameraInitializedEvent(
                  previewSize.getWidth(),
                  previewSize.getHeight(),
                  currentExposureMode,
                  currentFocusMode,
                  isExposurePointSupported(),
                  isFocusPointSupported());
            } catch (CameraAccessException e) {
              dartMessenger.sendCameraErrorEvent(e.getMessage());
              close();
            }
          }

          @Override
          public void onClosed(@NonNull CameraDevice camera) {
            // Log.i(TAG, "open | onClosed");

            dartMessenger.sendCameraClosingEvent();
            super.onClosed(camera);
          }

          @Override
          public void onDisconnected(@NonNull CameraDevice cameraDevice) {
            // Log.i(TAG, "open | onDisconnected");

            close();
            dartMessenger.sendCameraErrorEvent("The camera was disconnected.");
          }

          @Override
          public void onError(@NonNull CameraDevice cameraDevice, int errorCode) {
            // Log.i(TAG, "open | onError");

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
    // Log.i(TAG, "createCaptureSession");

    // Close any existing capture session.
    closeCaptureSession();

    // Create a new capture builder.
    mPreviewRequestBuilder = cameraDevice.createCaptureRequest(templateType);

    // Build Flutter surface to render to
    SurfaceTexture surfaceTexture = flutterTexture.surfaceTexture();
    surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
    Surface flutterSurface = new Surface(surfaceTexture);
    mPreviewRequestBuilder.addTarget(flutterSurface);

    List<Surface> remainingSurfaces = Arrays.asList(surfaces);
    if (templateType != CameraDevice.TEMPLATE_PREVIEW) {
      // If it is not preview mode, add all surfaces as targets.
      for (Surface surface : remainingSurfaces) {
        mPreviewRequestBuilder.addTarget(surface);
      }
    }

    cameraRegions = new CameraRegions(getRegionBoundaries());

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

            updateFpsRange();
            updateFocusMode(mPreviewRequestBuilder);
            updateFlash(mPreviewRequestBuilder);
            updateExposureMode(mPreviewRequestBuilder);

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
    // Log.i(TAG, "refreshPreviewCaptureSession");
    if (captureSession == null) {
      // Log.i(TAG, "[refreshPreviewCaptureSession] mPreviewSession null, returning");
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
    // Log.i(TAG, "takePicture | useAutoFocus: " + useAutoFocus);

    // Only take one 1 picture at a time.
    if (pictureCaptureRequest != null && !pictureCaptureRequest.isFinished()) {
      result.error("captureAlreadyActive", "Picture is currently already being captured", null);
      return;
    }

    // Create temporary file
    final File outputDir = applicationContext.getCacheDir();
    try {
      final File file = File.createTempFile("CAP", ".jpg", outputDir);

      // Start a new capture
      pictureCaptureRequest = new PictureCaptureRequest(result, file, dartMessenger);
    } catch (IOException | SecurityException e) {
      pictureCaptureRequest.error("cannotCreateFile", e.getMessage(), null);
      return;
    }

    // Listen for picture being taken
    pictureImageReader.setOnImageAvailableListener(mOnImageAvailableListener, mBackgroundHandler);

    if (useAutoFocus) {
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
    // Log.i(TAG, "runPrecaptureSequence");
    try {
      // First set precapture state to idle or else it can hang in STATE_WAITING_PRECAPTURE
      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE);
      captureSession.capture(mPreviewRequestBuilder.build(), mCaptureCallback, mBackgroundHandler);

      // Repeating request to refresh preview session
      refreshPreviewCaptureSession(
          null, (code, message) -> pictureCaptureRequest.error("cameraAccess", message, null));

      // Start precapture now
      cameraState = CameraState.STATE_WAITING_PRECAPTURE_START;

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
    // Log.i(TAG, "captureStillPicture");
    cameraState = CameraState.STATE_CAPTURING;
    pictureCaptureRequest.setState(PictureCaptureRequestState.STATE_CAPTURING);

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

      // Set focus / flash from preview mode
      updateFlash(stillBuilder);
      updateFocusMode(stillBuilder);
      updateExposureMode(stillBuilder);

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
              // Log.i(TAG, "onCaptureStarted");
            }

            @Override
            public void onCaptureProgressed(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                @NonNull CaptureResult partialResult) {
              // Log.i(TAG, "onCaptureProgressed");
            }

            @Override
            public void onCaptureCompleted(
                @NonNull CameraCaptureSession session,
                @NonNull CaptureRequest request,
                @NonNull TotalCaptureResult result) {
              // Log.i(TAG, "onCaptureCompleted");
              unlockAutoFocus();
            }
          };

      captureSession.stopRepeating();
      captureSession.abortCaptures();
      // Log.i(TAG, "sending capture request");
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
   * Sync the requestBuilder exposure mode setting ot the current exposure mode setting of the
   * camera.
   */
  void updateExposureMode(CaptureRequest.Builder requestBuilder) {
    // Log.i(TAG, "updateExposureMode");

    // Applying auto exposure
    MeteringRectangle aeRect = cameraRegions.getAEMeteringRectangle();
    requestBuilder.set(
        CaptureRequest.CONTROL_AE_REGIONS,
        aeRect == null ? null : new MeteringRectangle[] {cameraRegions.getAEMeteringRectangle()});

    switch (currentExposureMode) {
      case locked:
        requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, true);
        break;
      case auto:
      default:
        requestBuilder.set(CaptureRequest.CONTROL_AE_LOCK, false);
        break;
    }

    // TODO: move this to its own setting (exposure offset)
    requestBuilder.set(CaptureRequest.CONTROL_AE_EXPOSURE_COMPENSATION, exposureOffset);
  }

  /** Sync the requestBuilder flash setting to the current flash mode setting of the camera. */
  void updateFlash(CaptureRequest.Builder requestBuilder) {
    // Log.i(TAG, "updateFlash");

    if (!mFlashSupported) {
      return;
    }

    switch (currentFlashMode) {
      case off:
        requestBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
        requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
        break;

      case always:
        requestBuilder.set(
            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_ALWAYS_FLASH);
        requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
        break;

      case torch:
        requestBuilder.set(CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON);
        requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_TORCH);
        break;

      case auto:
        requestBuilder.set(
            CaptureRequest.CONTROL_AE_MODE, CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH);
        requestBuilder.set(CaptureRequest.FLASH_MODE, CaptureRequest.FLASH_MODE_OFF);
        break;

        // TODO: to be implemented someday. Need to add it to dart/iOS as another flash mode setting.
        //      case autoRedEye:
        //        requestBuilder.set(CaptureRequest.CONTROL_AE_MODE,
        //                CaptureRequest.CONTROL_AE_MODE_ON_AUTO_FLASH_REDEYE);
        //        requestBuilder.set(CaptureRequest.FLASH_MODE,
        //                CaptureRequest.FLASH_MODE_OFF);
        //        break;
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
    return (ORIENTATIONS.get(rotation) + sensorOrientation + 270) % 360;
  }

  /** Start capturing a picture, doing autofocus first. */
  private void runPictureAutoFocus() {
    // Log.i(TAG, "runPictureAutoFocus");
    assert (pictureCaptureRequest != null);

    cameraState = CameraState.STATE_WAITING_FOCUS;
    pictureCaptureRequest.setState(PictureCaptureRequestState.STATE_WAITING_FOCUS);
    lockAutoFocus();
  }

  /** Start the autofocus routine on the current capture request. */
  private void lockAutoFocus() {
    // Log.i(TAG, "lockAutoFocus");
    pictureCaptureRequest.setState(PictureCaptureRequestState.STATE_WAITING_PRECAPTURE_START);

    mPreviewRequestBuilder.set(
        CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_START);

    refreshPreviewCaptureSession(
        null, (code, message) -> pictureCaptureRequest.error(code, message, null));
  }

  /** Cancel and reset auto focus state and refresh the preview session. */
  private void unlockAutoFocus() {
    // Log.i(TAG, "unlockAutoFocus");
    try {
      // Cancel existing AF state
      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_CANCEL);
      captureSession.capture(mPreviewRequestBuilder.build(), null, mBackgroundHandler);

      // Set AE state to idle again
      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER,
          CaptureRequest.CONTROL_AE_PRECAPTURE_TRIGGER_IDLE);

      // Set AF state to idle again
      mPreviewRequestBuilder.set(
          CaptureRequest.CONTROL_AF_TRIGGER, CameraMetadata.CONTROL_AF_TRIGGER_IDLE);

      captureSession.capture(mPreviewRequestBuilder.build(), null, mBackgroundHandler);
    } catch (CameraAccessException e) {
      // Log.i(TAG, "Error unlocking focus: " + e.getMessage());
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
   * @param result
   * @param newMode
   * @throws CameraAccessException
   */
  public void setFlashMode(@NonNull final Result result, FlashMode newMode) {
    // Save the new flash mode setting
    currentFlashMode = newMode;
    updateFlash(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        () -> result.success(null),
        (code, message) -> result.error("setFlashModeFailed", "Could not set flash mode.", null));
  }

  /**
   * Dart handler for setting new exposure mode setting.
   *
   * @param result
   * @param newMode
   * @throws CameraAccessException
   */
  public void setExposureMode(@NonNull final Result result, ExposureMode newMode)
      throws CameraAccessException {
    currentExposureMode = newMode;
    updateExposureMode(mPreviewRequestBuilder);

    refreshPreviewCaptureSession(
        null,
        (code, message) ->
            result.error("setExposureModeFailed", "Could not set exposure mode.", null));

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
    else cameraRegions.setAutoExposureMeteringRectangleFromPoint(y, 1 - x);
    // Apply it
    updateExposureMode(mPreviewRequestBuilder);
    refreshPreviewCaptureSession(
        () -> result.success(null), (code, message) -> result.error("CameraAccess", message, null));
  }

  /**
   * Set new focus mode from dart.
   *
   * @param result
   * @param newMode
   * @throws CameraAccessException
   */
  public void setFocusMode(@NonNull final Result result, FocusMode newMode)
      throws CameraAccessException {
    // Log.i(TAG, "setFocusMode: " + newMode);

    // Set new focus mode
    currentFocusMode = newMode;

    // Sync new focus mode to the current capture request builder
    updateFocusMode(mPreviewRequestBuilder);

    // Now depending on the new mode we either want to restart the AF routine (if setting to auto)
    // or we want to trigger a one-time focus and then set AF to idle (locked mode).
    switch (newMode) {
      case auto:
        // Log.i(TAG, "Triggering AF start with mode " + currentFocusMode);
        // Reset state of autofocus so it goes back to passive scanning.
        mPreviewRequestBuilder.set(
            CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_CANCEL);

        // Refresh preview session using repeating request as it will be in CONTROL_AF_MODE_CONTINUOUS_PICTURE
        refreshPreviewCaptureSession(
            () -> result.success(null),
            (code, message) -> result.error("setFocusMode", message, null));
        break;

      case locked:
        // AF mode will be in Auto so we just want to perform one AF routine
        mPreviewRequestBuilder.set(
            CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_START);

        // Refresh the AF once. When the AF start is completed triggering then we will set it to idle mode.
        // If we don't wait for the callback like this, then setting it to idle just resets the focus to infinity
        // on some devices like Sony XZ.
        try {
          captureSession.capture(
              mPreviewRequestBuilder.build(),
              new CameraCaptureSession.CaptureCallback() {
                @Override
                public void onCaptureCompleted(
                    @NonNull CameraCaptureSession session,
                    @NonNull CaptureRequest request,
                    @NonNull TotalCaptureResult _result) {
                  // Log.i(TAG, "Success after triggering AF start for locked focus");

                  mPreviewRequestBuilder.set(
                      CaptureRequest.CONTROL_AF_TRIGGER, CaptureRequest.CONTROL_AF_TRIGGER_IDLE);
                  refreshPreviewCaptureSession(
                      null, (code, message) -> result.error("setFocusMode", message, null));
                }
              },
              mBackgroundHandler);

          result.success(null);
        } catch (CameraAccessException e) {
          result.error("setFocusMode", e.getMessage(), null);
        }
        break;
    }
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
      cameraRegions.setAutoFocusMeteringRectangleFromPoint(y, 1 - x);
    }

    // Apply the new metering rectangle
    setFocusMode(result, currentFocusMode);
  }

  @TargetApi(VERSION_CODES.P)
  private boolean supportsDistortionCorrection() {
    int[] availableDistortionCorrectionModes =
        cameraProperties.getDistortionCorrectionAvailableModes();
    if (availableDistortionCorrectionModes == null) availableDistortionCorrectionModes = new int[0];
    long nonOffModesSupported =
        Arrays.stream(availableDistortionCorrectionModes)
            .filter((value) -> value != CaptureRequest.DISTORTION_CORRECTION_MODE_OFF)
            .count();
    return nonOffModesSupported > 0;
  }

  private Size getRegionBoundaries() {
    // No distortion correction support
    if (android.os.Build.VERSION.SDK_INT < VERSION_CODES.P || !supportsDistortionCorrection()) {
      return cameraProperties.getSensorInfoPixelArraySize();
    }
    // Get the current distortion correction mode
    Integer distortionCorrectionMode =
        mPreviewRequestBuilder.get(CaptureRequest.DISTORTION_CORRECTION_MODE);
    // Return the correct boundaries depending on the mode
    android.graphics.Rect rect;
    if (distortionCorrectionMode == null
        || distortionCorrectionMode == CaptureRequest.DISTORTION_CORRECTION_MODE_OFF) {
      rect = cameraProperties.getSensorInfoPreCorrectionActiveArraySize();
    } else {
      rect = cameraProperties.getSensorInfoActiveArraySize();
    }
    return rect == null ? null : new Size(rect.width(), rect.height());
  }

  private boolean isExposurePointSupported() {
    Integer supportedRegions = cameraProperties.getControlMaxRegionsAutoExposure();
    return supportedRegions != null && supportedRegions > 0;
  }

  private boolean isFocusPointSupported() {
    Integer supportedRegions = cameraProperties.getControlMaxRegionsAutoFocus();
    return supportedRegions != null && supportedRegions > 0;
  }

  public double getMinExposureOffset() {
    Range<Integer> range = cameraProperties.getControlAutoExposureCompensationRange();
    double minStepped = range == null ? 0 : range.getLower();
    double stepSize = getExposureOffsetStepSize();
    return minStepped * stepSize;
  }

  public double getMaxExposureOffset() {
    Range<Integer> range = cameraProperties.getControlAutoExposureCompensationRange();
    double maxStepped = range == null ? 0 : range.getUpper();
    double stepSize = getExposureOffsetStepSize();
    return maxStepped * stepSize;
  }

  public double getExposureOffsetStepSize() {
    Rational stepSize = cameraProperties.getControlAutoExposureCompensationStep();
    return stepSize == null ? 0.0 : stepSize.doubleValue();
  }

  public void setExposureOffset(@NonNull final Result result, double offset) {
    // Set the exposure offset
    double stepSize = getExposureOffsetStepSize();
    exposureOffset = (int) (offset / stepSize);
    // Apply it
    updateExposureMode(mPreviewRequestBuilder);

    // Refresh capture session
    refreshPreviewCaptureSession(
        () -> result.success(offset),
        (code, message) ->
            result.error("setExposureModeFailed", "Could not set flash mode.", null));
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
    if (mPreviewRequestBuilder != null) {
      final Rect computedZoom = cameraZoom.computeZoom(zoom);
      mPreviewRequestBuilder.set(CaptureRequest.SCALER_CROP_REGION, computedZoom);
      captureSession.setRepeatingRequest(mPreviewRequestBuilder.build(), null, mBackgroundHandler);
    }

    result.success(null);
  }

  public void lockCaptureOrientation(PlatformChannel.DeviceOrientation orientation) {
    this.lockedCaptureOrientation = orientation;
  }

  public void unlockCaptureOrientation() {
    this.lockedCaptureOrientation = null;
  }

  /** Set current fps range setting to the current preview request builder */
  private void updateFpsRange() {
    if (fpsRange == null) {
      return;
    }

    mPreviewRequestBuilder.set(CaptureRequest.CONTROL_AE_TARGET_FPS_RANGE, fpsRange);
  }

  /**
   * Sync the focus mode setting to the provided capture request builder.
   *
   * @param requestBuilder
   */
  private void updateFocusMode(CaptureRequest.Builder requestBuilder) {
    // Log.i(TAG, "updateFocusMode currentFocusMode: " + currentFocusMode);

    if (!mAutoFocusSupported) {
      useAutoFocus = false;
      requestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_OFF);
    } else {
      switch (currentFocusMode) {
        case locked:
          useAutoFocus = false;
          requestBuilder.set(CaptureRequest.CONTROL_AF_MODE, CaptureRequest.CONTROL_AF_MODE_AUTO);
          break;

        case auto:
          useAutoFocus = true;
          requestBuilder.set(
              CaptureRequest.CONTROL_AF_MODE,
              recordingVideo
                  ? CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_VIDEO
                  : CaptureRequest.CONTROL_AF_MODE_CONTINUOUS_PICTURE);
        default:
          break;
      }
    }

    // Some devices use an extremely high noise reduction setting by default (pixel 4 selfie mode), which
    // causes the preview/capture to look blurry and out of focus. To fix this we set NR to off.
    // TODO: we should add a noise reduction setting in dart/ios in the future.
    requestBuilder.set(
        CaptureRequest.NOISE_REDUCTION_MODE, CaptureRequest.NOISE_REDUCTION_MODE_OFF);

    // Update metering
    MeteringRectangle afRect = cameraRegions.getAFMeteringRectangle();
    requestBuilder.set(
        CaptureRequest.CONTROL_AF_REGIONS,
        afRect == null ? null : new MeteringRectangle[] {afRect});
  }

  public void startPreview() throws CameraAccessException {
    if (pictureImageReader == null || pictureImageReader.getSurface() == null) return;
    // Log.i(TAG, "startPreview");

    createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, pictureImageReader.getSurface());
  }

  public void startPreviewWithImageStream(EventChannel imageStreamChannel)
      throws CameraAccessException {
    createCaptureSession(CameraDevice.TEMPLATE_RECORD, imageStreamReader.getSurface());
    // Log.i(TAG, "startPreviewWithImageStream");

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
      // Log.i(TAG, "closeCaptureSession");

      captureSession.close();
      captureSession = null;
    }
  }

  public void close() {
    // Log.i(TAG, "close");
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
    // Log.i(TAG, "dispose");

    close();
    flutterTexture.release();
    deviceOrientationListener.stop();
  }
}
