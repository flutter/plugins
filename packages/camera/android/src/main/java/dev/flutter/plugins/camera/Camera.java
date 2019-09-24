package dev.flutter.plugins.camera;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
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
import android.media.CamcorderProfile;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.os.Build;
import android.util.Size;
import android.view.OrientationEventListener;
import android.view.Surface;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.flutter.view.TextureRegistry.SurfaceTextureEntry;

import static android.view.OrientationEventListener.ORIENTATION_UNKNOWN;
import static dev.flutter.plugins.camera.CameraUtils.computeBestPreviewSize;

public class Camera {
  private final SurfaceTextureEntry flutterTexture;
  private final CameraManager cameraManager;
  private final OrientationEventListener orientationEventListener;
  private final boolean isFrontFacing;
  private final int sensorOrientation;
  private final String cameraName;
  private final Size captureSize;
  private final Size previewSize;
  private final boolean enableAudio;

  private CameraDevice cameraDevice;
  private CameraCaptureSession cameraCaptureSession;
  private ImageReader pictureImageReader;
  private ImageReader imageStreamReader;
  private CameraEventHandler cameraEventHandler;
  private CaptureRequest.Builder captureRequestBuilder;
  private MediaRecorder mediaRecorder;
  private boolean recordingVideo;
  private CamcorderProfile recordingProfile;
  private int currentOrientation = ORIENTATION_UNKNOWN;

  // Mirrors camera.dart
  public enum ResolutionPreset {
    low,
    medium,
    high,
    veryHigh,
    ultraHigh,
    max,
  }

  public Camera(
      final Activity activity,
      final SurfaceTextureEntry flutterTexture,
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
    this.cameraManager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
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
    orientationEventListener.enable();

    CameraCharacteristics characteristics = cameraManager.getCameraCharacteristics(cameraName);
    StreamConfigurationMap streamConfigurationMap =
        characteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
    //noinspection ConstantConditions
    sensorOrientation = characteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
    //noinspection ConstantConditions
    isFrontFacing =
        characteristics.get(CameraCharacteristics.LENS_FACING) == CameraMetadata.LENS_FACING_FRONT;
    ResolutionPreset preset = ResolutionPreset.valueOf(resolutionPreset);
    recordingProfile =
        CameraUtils.getBestAvailableCamcorderProfileForResolutionPreset(cameraName, preset);
    captureSize = new Size(recordingProfile.videoFrameWidth, recordingProfile.videoFrameHeight);
    previewSize = computeBestPreviewSize(cameraName, preset);
  }

  public void setCameraEventHandler(@Nullable CameraEventHandler handler) {
    this.cameraEventHandler = handler;
  }

  private void onError(String description) {
    if (cameraEventHandler != null) {
      cameraEventHandler.onError(description);
    }
  }

  private void onCameraClosed() {
    if (cameraEventHandler != null) {
      cameraEventHandler.onCameraClosed();
    }
  }

  private void prepareMediaRecorder(String outputFilePath) throws IOException {
    if (mediaRecorder != null) {
      mediaRecorder.release();
    }
    mediaRecorder = new MediaRecorder();

    // There's a specific order that mediaRecorder expects. Do not change the order
    // of these function calls.
    if (enableAudio) mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);
    mediaRecorder.setVideoSource(MediaRecorder.VideoSource.SURFACE);
    mediaRecorder.setOutputFormat(recordingProfile.fileFormat);
    if (enableAudio) mediaRecorder.setAudioEncoder(recordingProfile.audioCodec);
    mediaRecorder.setVideoEncoder(recordingProfile.videoCodec);
    mediaRecorder.setVideoEncodingBitRate(recordingProfile.videoBitRate);
    if (enableAudio) mediaRecorder.setAudioSamplingRate(recordingProfile.audioSampleRate);
    mediaRecorder.setVideoFrameRate(recordingProfile.videoFrameRate);
    mediaRecorder.setVideoSize(recordingProfile.videoFrameWidth, recordingProfile.videoFrameHeight);
    mediaRecorder.setOutputFile(outputFilePath);
    mediaRecorder.setOrientationHint(getMediaOrientation());

    mediaRecorder.prepare();
  }

  @SuppressLint("MissingPermission")
  public void open(@NonNull final OnCameraOpenedCallback callback) throws CameraAccessException {
    pictureImageReader = ImageReader.newInstance(
        captureSize.getWidth(),
        captureSize.getHeight(),
        ImageFormat.JPEG,
        2
    );

    // Used to stream image byte data to dart side.
    imageStreamReader = ImageReader.newInstance(
        previewSize.getWidth(),
        previewSize.getHeight(),
        ImageFormat.YUV_420_888,
        2
    );

    cameraManager.openCamera(
        cameraName,
        new CameraDevice.StateCallback() {
          @Override
          public void onOpened(@NonNull CameraDevice device) {
            cameraDevice = device;
            try {
              startPreview();
            } catch (CameraAccessException e) {
              callback.onCameraOpenFailed(e.getMessage());
              close();
              return;
            }
            callback.onCameraOpened(
                flutterTexture.id(),
                previewSize.getWidth(),
                previewSize.getHeight()
            );
          }

          @Override
          public void onClosed(@NonNull CameraDevice camera) {
            onCameraClosed();
            super.onClosed(camera);
          }

          @Override
          public void onDisconnected(@NonNull CameraDevice cameraDevice) {
            close();
            Camera.this.onError("The camera was disconnected.");
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
            Camera.this.onError(errorDescription);
          }
        },
        null);
  }

  private void writeToFile(ByteBuffer buffer, File file) throws IOException {
    try (FileOutputStream outputStream = new FileOutputStream(file)) {
      while (0 < buffer.remaining()) {
        outputStream.getChannel().write(buffer);
      }
    }
  }

  public void takePicture(String filePath, @NonNull final OnPictureTakenCallback callback) {
    final File file = new File(filePath);

    if (file.exists()) {
      callback.onFileAlreadyExists();
      return;
    }

    pictureImageReader.setOnImageAvailableListener(
        reader -> {
          try (Image image = reader.acquireLatestImage()) {
            ByteBuffer buffer = image.getPlanes()[0].getBuffer();
            writeToFile(buffer, file);
            callback.onPictureTaken();
          } catch (IOException e) {
            callback.onFailedToSaveImage();
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
              callback.onCaptureFailure(reason);
            }
          },
          null);
    } catch (CameraAccessException e) {
      callback.onCameraAccessFailure(e.getMessage());
    }
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
            try {
              if (cameraDevice == null) {
                onError("The camera was closed during configuration.");
                return;
              }
              cameraCaptureSession = session;
              captureRequestBuilder.set(
                  CaptureRequest.CONTROL_MODE, CameraMetadata.CONTROL_MODE_AUTO);
              cameraCaptureSession.setRepeatingRequest(captureRequestBuilder.build(), null, null);
              if (onSuccessCallback != null) {
                onSuccessCallback.run();
              }
            } catch (CameraAccessException | IllegalStateException | IllegalArgumentException e) {
              onError(e.getMessage());
            }
          }

          @Override
          public void onConfigureFailed(@NonNull CameraCaptureSession cameraCaptureSession) {
            onError("Failed to configure camera session.");
          }
        };

    // Collect all surfaces we want to render to.
    List<Surface> surfaceList = new ArrayList<>();
    surfaceList.add(flutterSurface);
    surfaceList.addAll(remainingSurfaces);
    // Start the session
    cameraDevice.createCaptureSession(surfaceList, callback, null);
  }

  public void startVideoRecording(String filePath) throws IOException, CameraAccessException, IllegalStateException {
    if (new File(filePath).exists()) {
      throw new IllegalStateException("File " + filePath + " already exists.");
    }

    prepareMediaRecorder(filePath);
    recordingVideo = true;
    createCaptureSession(
        CameraDevice.TEMPLATE_RECORD,
        () -> mediaRecorder.start(),
        mediaRecorder.getSurface()
    );
  }

  public void stopVideoRecording() throws CameraAccessException {
    if (!recordingVideo) {
      return;
    }

    recordingVideo = false;
    mediaRecorder.stop();
    mediaRecorder.reset();
    startPreview();
  }

  public void pauseVideoRecording() throws IllegalStateException, UnsupportedOperationException {
    if (!recordingVideo) {
      return;
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      mediaRecorder.pause();
    } else {
      throw new UnsupportedOperationException("pauseVideoRecording requires Android API +24.");
    }
  }

  public void resumeVideoRecording() throws IllegalStateException, UnsupportedOperationException {
    if (!recordingVideo) {
      return;
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
      mediaRecorder.resume();
    } else {
      throw new UnsupportedOperationException("resumeVideoRecording requires Android API +24.");
    }
  }

  public void startPreview() throws CameraAccessException {
    createCaptureSession(CameraDevice.TEMPLATE_PREVIEW, pictureImageReader.getSurface());
  }

  public void startPreviewWithImageStream(@NonNull CameraPreviewDisplay previewDisplay)
      throws CameraAccessException {
    createCaptureSession(CameraDevice.TEMPLATE_STILL_CAPTURE, imageStreamReader.getSurface());

    previewDisplay.startStreaming(new CameraPreviewDisplay.ImageStreamConnection() {
      @Override
      public void onConnectionReady(@NonNull CameraImageStream stream) {
        startSendingImagesToPreviewDisplay(stream);
      }

      @Override
      public void onConnectionClosed() {
        imageStreamReader.setOnImageAvailableListener(null, null);
      }
    });
  }

  private void startSendingImagesToPreviewDisplay(@NonNull CameraImageStream cameraImageStream) {
    imageStreamReader.setOnImageAvailableListener(
        reader -> {
          Image image = reader.acquireLatestImage();
          if (image == null) return;

          cameraImageStream.sendImage(image);
          image.close();
        },
        null);
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
    orientationEventListener.disable();
  }

  private int getMediaOrientation() {
    final int sensorOrientationOffset =
        (currentOrientation == ORIENTATION_UNKNOWN)
            ? 0
            : (isFrontFacing) ? -currentOrientation : currentOrientation;
    return (sensorOrientationOffset + sensorOrientation + 360) % 360;
  }

  /**
   * Callback invoked when this {@link Camera} is opened.
   *
   * <p>Reports either success or failure.
   */
  /* package */ interface OnCameraOpenedCallback {
    /**
     * The associated {@link Camera} was successfully opened and is tied to
     * a {@link SurfaceTexture} with the given {@code textureId}, displayed
     * at the given {@code previewWidth} and {@code previewHeight}.
     */
    void onCameraOpened(long textureId, int previewWidth, int previewHeight);

    /**
     * The associated {@link Camera} attempted to open, but failed.
     *
     * <p>The {@code Exception}'s {@code message} is provided.
     */
    void onCameraOpenFailed(@NonNull String message);
  }

  /**
   * Callback invoked when this {@link Camera} takes a picture.
   *
   * <p>Reports either success or one of many causes of failure.
   */
  /* package */ interface OnPictureTakenCallback {
    void onPictureTaken();

    void onFileAlreadyExists();

    void onFailedToSaveImage();

    void onCaptureFailure(@NonNull String reason);

    void onCameraAccessFailure(@NonNull String message);
  }

  /**
   * Handler that, when registered with a {@link Camera}, is notified of errors
   * and when the camera closes.
   */
  /* package */ interface CameraEventHandler {
    void onError(String description);

    void onCameraClosed();
  }
}
