// Copyright 2018 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package io.flutter.plugins.firebasemlvision.live;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.ImageFormat;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.hardware.Camera.CameraInfo;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresPermission;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.WindowManager;

import com.google.android.gms.common.images.Size;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;

import java.io.IOException;
import java.lang.Thread.State;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemlvision.BarcodeDetector;
import io.flutter.plugins.firebasemlvision.Detector;
import io.flutter.plugins.firebasemlvision.DetectorException;
import io.flutter.plugins.firebasemlvision.TextDetector;
import io.flutter.view.FlutterView;

/**
 * Manages the camera and allows UI updates on top of it (e.g. overlaying extra Graphics or
 * displaying extra information). This receives preview frames from the camera at a specified rate,
 * sending those frames to child classes' detectors / classifiers as fast as it is able to process.
 */
@SuppressLint("MissingPermission")
public class LegacyCamera {
  @SuppressLint("InlinedApi")
  public static final int CAMERA_FACING_BACK = CameraInfo.CAMERA_FACING_BACK;

  @SuppressLint("InlinedApi")
  public static final int CAMERA_FACING_FRONT = CameraInfo.CAMERA_FACING_FRONT;

  private static final String TAG = "MIDemoApp:CameraSource";

  public interface OnCameraOpenedCallback {
    void onOpened(long textureId, int width, int height);
    void onFailed(Exception e);
  }

  /**
   * The dummy surface texture must be assigned a chosen name. Since we never use an OpenGL context,
   * we can choose any ID we want here. The dummy surface texture is not a crazy hack - it is
   * actually how the camera team recommends using the camera without a preview.
   */
  private static final int DUMMY_TEXTURE_NAME = 100;

  /**
   * If the absolute difference between a preview size aspect ratio and a picture size aspect ratio
   * is less than this tolerance, they are considered to be the same aspect ratio.
   */
  private static final float ASPECT_RATIO_TOLERANCE = 0.01f;

  protected Activity activity;

  private PluginRegistry.Registrar registrar;

  private final FlutterView.SurfaceTextureEntry textureEntry;

  private EventChannel.EventSink eventSink;

  private Camera camera;

  protected int facing = CAMERA_FACING_BACK;

  /**
   * Rotation of the device, and thus the associated preview images captured from the device. See
   * Frame.Metadata#getRotation().
   */
  private int rotation;

  private Size previewSize;

  // These values may be requested by the caller.  Due to hardware limitations, we may need to
  // select close, but not exactly the same values for these.
  private final float requestedFps = 20.0f;
  private final int requestedPreviewWidth = 1280;
  private final int requestedPreviewHeight = 960;
  private final boolean requestedAutoFocus = true;

  // These instances need to be held onto to avoid GC of their underlying resources.  Even though
  // these aren't used outside of the method that creates them, they still must have hard
  // references maintained to them.
  private SurfaceTexture dummySurfaceTexture;

  // True if a SurfaceTexture is being used for the preview, false if a SurfaceHolder is being
  // used for the preview.  We want to be compatible back to Gingerbread, but SurfaceTexture
  // wasn't introduced until Honeycomb.  Since the interface cannot use a SurfaceTexture, if the
  // developer wants to display a preview we must use a SurfaceHolder.  If the developer doesn't
  // want to display a preview we use a SurfaceTexture if we are running at least Honeycomb.
  private boolean usingSurfaceTexture;

  /**
   * Dedicated thread and associated runnable for calling into the detector with frames, as the
   * frames become available from the camera.
   */
  private Thread processingThread;

  private final FrameProcessingRunnable processingRunnable;

  private final Object processorLock = new Object();
  private Detector detector;

  /**
   * Map to convert between a byte array, received from the camera, and its associated byte buffer.
   * We use byte buffers internally because this is a more efficient way to call into native code
   * later (avoids a potential copy).
   * <p>
   * <p><b>Note:</b> uses IdentityHashMap here instead of HashMap because the behavior of an array's
   * equals, hashCode and toString methods is both useless and unexpected. IdentityHashMap enforces
   * identity ('==') check on the keys.
   */
  private final Map<byte[], ByteBuffer> bytesToByteBuffer = new IdentityHashMap<>();

  private Detector.OperationFinishedCallback liveDetectorFinishedCallback = new Detector.OperationFinishedCallback() {
    @Override
    public void success(Detector detector, Object data) {
      Map<String, Object> event = new HashMap<>();
      event.put("eventType", "recognized");
      String dataType;
      String dataLabel;
      if (detector instanceof BarcodeDetector) {
        dataType = "barcode";
        dataLabel = "barcodeData";
      } else if (detector instanceof TextDetector) {
        dataType = "text";
        dataLabel = "textData";
      } else {
        // unsupported live detector
        return;
      }
      event.put("recognitionType", dataType);
      event.put(dataLabel, data);
      eventSink.success(event);
    }

    @Override
    public void error(DetectorException e) {
      e.sendError(eventSink);
    }
  };


  public LegacyCamera(PluginRegistry.Registrar registrar) {
    this.registrar = registrar;
    this.activity = registrar.activity();
    this.textureEntry = registrar.view().createSurfaceTexture();
    processingRunnable = new FrameProcessingRunnable();

    registerEventChannel();
  }

  private void registerEventChannel() {
    new EventChannel(
      registrar.messenger(), "plugins.flutter.io/firebase_ml_vision/liveViewEvents" + textureEntry.id())
      .setStreamHandler(
        new EventChannel.StreamHandler() {
          @Override
          public void onListen(Object arguments, EventChannel.EventSink eventSink) {
            LegacyCamera.this.eventSink = eventSink;
          }

          @Override
          public void onCancel(Object arguments) {
            LegacyCamera.this.eventSink = null;
          }
        });
  }

  // ==============================================================================================
  // Public
  // ==============================================================================================

  /**
   * Stops the camera and releases the resources of the camera and underlying detector.
   */
  public void release() {
    synchronized (processorLock) {
      stop();
      processingRunnable.release();

      if (detector != null) {
        detector.close(null);
      }
    }
  }

//  /**
//   * Opens the camera and starts sending preview frames to the underlying detector. The preview
//   * frames are not displayed.
//   *
//   * @throws IOException if the camera's preview texture or display could not be initialized
//   */
//  @SuppressLint("MissingPermission")
//  @RequiresPermission(Manifest.permission.CAMERA)
//  public synchronized LegacyCamera start(OnCameraOpenedCallback callback) throws IOException {
//    if (camera != null) {
//      return this;
//    }
//
//    camera = createCamera(callback);
//    dummySurfaceTexture = new SurfaceTexture(DUMMY_TEXTURE_NAME);
//    camera.setPreviewTexture(dummySurfaceTexture);
//    usingSurfaceTexture = true;
//    camera.startPreview();
//
//    processingThread = new Thread(processingRunnable);
//    processingRunnable.setActive(true);
//    processingThread.start();
//    return this;
//  }

  /**
   * Opens the camera and starts sending preview frames to the underlying detector. The supplied
   * surface holder is used for the preview so frames can be displayed to the user.
   *
//   * @param surfaceHolder the surface holder to use for the preview frames
   * @throws IOException if the supplied surface holder could not be used as the preview display
   */
  @RequiresPermission(Manifest.permission.CAMERA)
  public synchronized LegacyCamera start(OnCameraOpenedCallback callback) throws IOException {
    if (camera != null) {
      return this;
    }

    camera = createCamera(callback);

    SurfaceTexture surfaceTexture = textureEntry.surfaceTexture();
    surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());

    camera.setPreviewTexture(surfaceTexture);
    usingSurfaceTexture = true;
    camera.startPreview();

    processingThread = new Thread(processingRunnable);
    processingRunnable.setActive(true);
    processingThread.start();

    return this;
  }

  /**
   * Closes the camera and stops sending frames to the underlying frame detector.
   * <p>
   * <p>This camera source may be restarted again by calling {@link
   * #start(OnCameraOpenedCallback)}.
   * <p>
   * <p>Call {@link #release()} instead to completely shut down this camera source and release the
   * resources of the underlying detector.
   */
  public synchronized void stop() {
    processingRunnable.setActive(false);
    if (processingThread != null) {
      try {
        // Wait for the thread to complete to ensure that we can't have multiple threads
        // executing at the same time (i.e., which would happen if we called start too
        // quickly after stop).
        processingThread.join();
      } catch (InterruptedException e) {
        Log.d(TAG, "Frame processing thread interrupted on release.");
      }
      processingThread = null;
    }

    if (camera != null) {
      camera.stopPreview();
      camera.setPreviewCallbackWithBuffer(null);
      try {
        if (usingSurfaceTexture) {
          camera.setPreviewTexture(null);
        } else {
          camera.setPreviewDisplay(null);
        }
      } catch (Exception e) {
        Log.e(TAG, "Failed to clear camera preview: " + e);
      }
      camera.release();
      camera = null;
    }

    // Release the reference to any image buffers, since these will no longer be in use.
    bytesToByteBuffer.clear();
  }

  /**
   * Changes the facing of the camera.
   */
  public synchronized void setFacing(int facing) {
    if ((facing != CAMERA_FACING_BACK) && (facing != CAMERA_FACING_FRONT)) {
      throw new IllegalArgumentException("Invalid camera: " + facing);
    }
    this.facing = facing;
  }

  /**
   * Returns the preview size that is currently in use by the underlying camera.
   */
  public Size getPreviewSize() {
    return previewSize;
  }

  /**
   * Returns the selected camera; one of {@link #CAMERA_FACING_BACK} or {@link
   * #CAMERA_FACING_FRONT}.
   */
  public int getCameraFacing() {
    return facing;
  }

  /**
   * Opens the camera and applies the user settings.
   *
   * @throws IOException if camera cannot be found or preview cannot be processed
   */
  @SuppressLint("InlinedApi")
  private Camera createCamera(@Nullable OnCameraOpenedCallback callback) throws IOException {
    int requestedCameraId = getIdForRequestedCamera(facing);
    if (requestedCameraId == -1) {
      throw new IOException("Could not find requested camera.");
    }
    Camera camera = Camera.open(requestedCameraId);

    SizePair sizePair = selectSizePair(camera, requestedPreviewWidth, requestedPreviewHeight);
    if (sizePair == null) {
      throw new IOException("Could not find suitable preview size.");
    }
    Size pictureSize = sizePair.pictureSize();
    previewSize = sizePair.previewSize();

    int[] previewFpsRange = selectPreviewFpsRange(camera, requestedFps);
    if (previewFpsRange == null) {
      throw new IOException("Could not find suitable preview frames per second range.");
    }

    Camera.Parameters parameters = camera.getParameters();

    if (pictureSize != null) {
      parameters.setPictureSize(pictureSize.getWidth(), pictureSize.getHeight());
    }
    parameters.setPreviewSize(previewSize.getWidth(), previewSize.getHeight());
    parameters.setPreviewFpsRange(
      previewFpsRange[Camera.Parameters.PREVIEW_FPS_MIN_INDEX],
      previewFpsRange[Camera.Parameters.PREVIEW_FPS_MAX_INDEX]);
    parameters.setPreviewFormat(ImageFormat.NV21);

    setRotation(camera, parameters, requestedCameraId);

    if (requestedAutoFocus) {
      if (parameters
        .getSupportedFocusModes()
        .contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO)) {
        parameters.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO);
      } else {
        Log.i(TAG, "Camera auto focus is not supported on this device.");
      }
    }

    camera.setParameters(parameters);

    if (callback != null) {
      callback.onOpened(textureEntry.id(), previewSize.getWidth(), previewSize.getHeight());
    }

    // Four frame buffers are needed for working with the camera:
    //
    //   one for the frame that is currently being executed upon in doing detection
    //   one for the next pending frame to process immediately upon completing detection
    //   two for the frames that the camera uses to populate future preview images
    //
    // Through trial and error it appears that two free buffers, in addition to the two buffers
    // used in this code, are needed for the camera to work properly.  Perhaps the camera has
    // one thread for acquiring images, and another thread for calling into user code.  If only
    // three buffers are used, then the camera will spew thousands of warning messages when
    // detection takes a non-trivial amount of time.
    camera.setPreviewCallbackWithBuffer(new CameraPreviewCallback());
    camera.addCallbackBuffer(createPreviewBuffer(previewSize));
    camera.addCallbackBuffer(createPreviewBuffer(previewSize));
    camera.addCallbackBuffer(createPreviewBuffer(previewSize));
    camera.addCallbackBuffer(createPreviewBuffer(previewSize));

    return camera;
  }

  /**
   * Gets the id for the camera specified by the direction it is facing. Returns -1 if no such
   * camera was found.
   *
   * @param facing the desired camera (front-facing or rear-facing)
   */
  private static int getIdForRequestedCamera(int facing) {
    CameraInfo cameraInfo = new CameraInfo();
    for (int i = 0; i < Camera.getNumberOfCameras(); ++i) {
      Camera.getCameraInfo(i, cameraInfo);
      if (cameraInfo.facing == facing) {
        return i;
      }
    }
    return -1;
  }

  public static List<Map<String, Object>> listAvailableCameraDetails() {
    List<Map<String, Object>> availableCameraDetails = new ArrayList<>();
    int cameraCount = Camera.getNumberOfCameras();
    for (int i = 0; i < cameraCount; ++i) {
      Map<String, Object> detailsMap = new HashMap<>();
      CameraInfo info = new CameraInfo();
      Camera.getCameraInfo(i, info);
      detailsMap.put("name", i);
      Log.d("ML", "camera Name: " + i);
      if (info.facing == CAMERA_FACING_BACK) {
        detailsMap.put("lensFacing", "back");
      } else {
        detailsMap.put("lensFacing", "front");
      }
      availableCameraDetails.add(detailsMap);
    }
    return availableCameraDetails;
  }

  /**
   * Selects the most suitable preview and picture size, given the desired width and height.
   * <p>
   * <p>Even though we only need to find the preview size, it's necessary to find both the preview
   * size and the picture size of the camera together, because these need to have the same aspect
   * ratio. On some hardware, if you would only set the preview size, you will get a distorted
   * image.
   *
   * @param camera        the camera to select a preview size from
   * @param desiredWidth  the desired width of the camera preview frames
   * @param desiredHeight the desired height of the camera preview frames
   * @return the selected preview and picture size pair
   */
  private static SizePair selectSizePair(Camera camera, int desiredWidth, int desiredHeight) {
    List<SizePair> validPreviewSizes = generateValidPreviewSizeList(camera);

    // The method for selecting the best size is to minimize the sum of the differences between
    // the desired values and the actual values for width and height.  This is certainly not the
    // only way to select the best size, but it provides a decent tradeoff between using the
    // closest aspect ratio vs. using the closest pixel area.
    SizePair selectedPair = null;
    int minDiff = Integer.MAX_VALUE;
    for (SizePair sizePair : validPreviewSizes) {
      Size size = sizePair.previewSize();
      int diff =
        Math.abs(size.getWidth() - desiredWidth) + Math.abs(size.getHeight() - desiredHeight);
      if (diff < minDiff) {
        selectedPair = sizePair;
        minDiff = diff;
      }
    }

    return selectedPair;
  }

  /**
   * Stores a preview size and a corresponding same-aspect-ratio picture size. To avoid distorted
   * preview images on some devices, the picture size must be set to a size that is the same aspect
   * ratio as the preview size or the preview may end up being distorted. If the picture size is
   * null, then there is no picture size with the same aspect ratio as the preview size.
   */
  private static class SizePair {
    private final Size preview;
    private Size picture;

    SizePair(
      android.hardware.Camera.Size previewSize,
      @Nullable android.hardware.Camera.Size pictureSize) {
      preview = new Size(previewSize.width, previewSize.height);
      if (pictureSize != null) {
        picture = new Size(pictureSize.width, pictureSize.height);
      }
    }

    Size previewSize() {
      return preview;
    }

    @Nullable
    Size pictureSize() {
      return picture;
    }
  }

  /**
   * Generates a list of acceptable preview sizes. Preview sizes are not acceptable if there is not
   * a corresponding picture size of the same aspect ratio. If there is a corresponding picture size
   * of the same aspect ratio, the picture size is paired up with the preview size.
   * <p>
   * <p>This is necessary because even if we don't use still pictures, the still picture size must
   * be set to a size that is the same aspect ratio as the preview size we choose. Otherwise, the
   * preview images may be distorted on some devices.
   */
  private static List<SizePair> generateValidPreviewSizeList(Camera camera) {
    Camera.Parameters parameters = camera.getParameters();
    List<Camera.Size> supportedPreviewSizes =
      parameters.getSupportedPreviewSizes();
    List<Camera.Size> supportedPictureSizes =
      parameters.getSupportedPictureSizes();
    List<SizePair> validPreviewSizes = new ArrayList<>();
    for (android.hardware.Camera.Size previewSize : supportedPreviewSizes) {
      float previewAspectRatio = (float) previewSize.width / (float) previewSize.height;

      // By looping through the picture sizes in order, we favor the higher resolutions.
      // We choose the highest resolution in order to support taking the full resolution
      // picture later.
      for (android.hardware.Camera.Size pictureSize : supportedPictureSizes) {
        float pictureAspectRatio = (float) pictureSize.width / (float) pictureSize.height;
        if (Math.abs(previewAspectRatio - pictureAspectRatio) < ASPECT_RATIO_TOLERANCE) {
          validPreviewSizes.add(new SizePair(previewSize, pictureSize));
          break;
        }
      }
    }

    // If there are no picture sizes with the same aspect ratio as any preview sizes, allow all
    // of the preview sizes and hope that the camera can handle it.  Probably unlikely, but we
    // still account for it.
    if (validPreviewSizes.size() == 0) {
      Log.w(TAG, "No preview sizes have a corresponding same-aspect-ratio picture size");
      for (android.hardware.Camera.Size previewSize : supportedPreviewSizes) {
        // The null picture size will let us know that we shouldn't set a picture size.
        validPreviewSizes.add(new SizePair(previewSize, null));
      }
    }

    return validPreviewSizes;
  }

  /**
   * Selects the most suitable preview frames per second range, given the desired frames per second.
   *
   * @param camera            the camera to select a frames per second range from
   * @param desiredPreviewFps the desired frames per second for the camera preview frames
   * @return the selected preview frames per second range
   */
  @SuppressLint("InlinedApi")
  private static int[] selectPreviewFpsRange(Camera camera, float desiredPreviewFps) {
    // The camera API uses integers scaled by a factor of 1000 instead of floating-point frame
    // rates.
    int desiredPreviewFpsScaled = (int) (desiredPreviewFps * 1000.0f);

    // The method for selecting the best range is to minimize the sum of the differences between
    // the desired value and the upper and lower bounds of the range.  This may select a range
    // that the desired value is outside of, but this is often preferred.  For example, if the
    // desired frame rate is 29.97, the range (30, 30) is probably more desirable than the
    // range (15, 30).
    int[] selectedFpsRange = null;
    int minDiff = Integer.MAX_VALUE;
    List<int[]> previewFpsRangeList = camera.getParameters().getSupportedPreviewFpsRange();
    for (int[] range : previewFpsRangeList) {
      int deltaMin = desiredPreviewFpsScaled - range[Camera.Parameters.PREVIEW_FPS_MIN_INDEX];
      int deltaMax = desiredPreviewFpsScaled - range[Camera.Parameters.PREVIEW_FPS_MAX_INDEX];
      int diff = Math.abs(deltaMin) + Math.abs(deltaMax);
      if (diff < minDiff) {
        selectedFpsRange = range;
        minDiff = diff;
      }
    }
    return selectedFpsRange;
  }

  /**
   * Calculates the correct rotation for the given camera id and sets the rotation in the
   * parameters. It also sets the camera's display orientation and rotation.
   *
   * @param parameters the camera parameters for which to set the rotation
   * @param cameraId   the camera id to set rotation based on
   */
  private void setRotation(Camera camera, Camera.Parameters parameters, int cameraId) {
    WindowManager windowManager = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
    int degrees = 0;
    int rotation = windowManager.getDefaultDisplay().getRotation();
    switch (rotation) {
      case Surface.ROTATION_0:
        degrees = 0;
        break;
      case Surface.ROTATION_90:
        degrees = 90;
        break;
      case Surface.ROTATION_180:
        degrees = 180;
        break;
      case Surface.ROTATION_270:
        degrees = 270;
        break;
      default:
        Log.e(TAG, "Bad rotation value: " + rotation);
    }

    CameraInfo cameraInfo = new CameraInfo();
    Camera.getCameraInfo(cameraId, cameraInfo);

    int angle;
    int displayAngle;
    if (cameraInfo.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
      angle = (cameraInfo.orientation + degrees) % 360;
      displayAngle = (360 - angle) % 360; // compensate for it being mirrored
    } else { // back-facing
      angle = (cameraInfo.orientation - degrees + 360) % 360;
      displayAngle = angle;
    }

    // This corresponds to the rotation constants.
    this.rotation = angle / 90;

    camera.setDisplayOrientation(displayAngle);
    parameters.setRotation(angle);
  }

  /**
   * Creates one buffer for the camera preview callback. The size of the buffer is based off of the
   * camera preview size and the format of the camera image.
   *
   * @return a new preview buffer of the appropriate size for the current camera settings
   */
  @SuppressLint("InlinedApi")
  private byte[] createPreviewBuffer(Size previewSize) {
    int bitsPerPixel = ImageFormat.getBitsPerPixel(ImageFormat.NV21);
    long sizeInBits = (long) previewSize.getHeight() * previewSize.getWidth() * bitsPerPixel;
    int bufferSize = (int) Math.ceil(sizeInBits / 8.0d) + 1;

    // Creating the byte array this way and wrapping it, as opposed to using .allocate(),
    // should guarantee that there will be an array to work with.
    byte[] byteArray = new byte[bufferSize];
    ByteBuffer buffer = ByteBuffer.wrap(byteArray);
    if (!buffer.hasArray() || (buffer.array() != byteArray)) {
      // I don't think that this will ever happen.  But if it does, then we wouldn't be
      // passing the preview content to the underlying detector later.
      throw new IllegalStateException("Failed to create valid buffer for camera source.");
    }

    bytesToByteBuffer.put(byteArray, buffer);
    return byteArray;
  }

  // ==============================================================================================
  // Frame processing
  // ==============================================================================================

  /**
   * Called when the camera has a new preview frame.
   */
  private class CameraPreviewCallback implements Camera.PreviewCallback {
    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
      processingRunnable.setNextFrame(data, camera);
    }
  }

  public void setMachineLearningFrameProcessor(Detector processor) {
    synchronized (processorLock) {
      if (detector != null) {
        detector.close(null);
      }
      detector = processor;
    }
  }

  /**
   * This runnable controls access to the underlying receiver, calling it to process frames when
   * available from the camera. This is designed to run detection on frames as fast as possible
   * (i.e., without unnecessary context switching or waiting on the next frame).
   * <p>
   * <p>While detection is running on a frame, new frames may be received from the camera. As these
   * frames come in, the most recent frame is held onto as pending. As soon as detection and its
   * associated processing is done for the previous frame, detection on the mostly recently received
   * frame will immediately start on the same thread.
   */
  private class FrameProcessingRunnable implements Runnable {

    // This lock guards all of the member variables below.
    private final Object lock = new Object();
    private boolean active = true;

    // These pending variables hold the state associated with the new frame awaiting processing.
    private ByteBuffer pendingFrameData;

    FrameProcessingRunnable() {
    }

    /**
     * Releases the underlying receiver. This is only safe to do after the associated thread has
     * completed, which is managed in camera source's release method above.
     */
    @SuppressLint("Assert")
    void release() {
      assert (processingThread.getState() == State.TERMINATED);
    }

    /**
     * Marks the runnable as active/not active. Signals any blocked threads to continue.
     */
    void setActive(boolean active) {
      synchronized (lock) {
        this.active = active;
        lock.notifyAll();
      }
    }

    /**
     * Sets the frame data received from the camera. This adds the previous unused frame buffer (if
     * present) back to the camera, and keeps a pending reference to the frame data for future use.
     */
    void setNextFrame(byte[] data, Camera camera) {
      synchronized (lock) {
        if (pendingFrameData != null) {
          camera.addCallbackBuffer(pendingFrameData.array());
          pendingFrameData = null;
        }

        if (!bytesToByteBuffer.containsKey(data)) {
          Log.d(
            TAG,
            "Skipping frame. Could not find ByteBuffer associated with the image "
              + "data from the camera.");
          return;
        }

        pendingFrameData = bytesToByteBuffer.get(data);

        // Notify the processor thread if it is waiting on the next frame (see below).
        lock.notifyAll();
      }
    }

    /**
     * As long as the processing thread is active, this executes detection on frames continuously.
     * The next pending frame is either immediately available or hasn't been received yet. Once it
     * is available, we transfer the frame info to local variables and run detection on that frame.
     * It immediately loops back for the next frame without pausing.
     * <p>
     * <p>If detection takes longer than the time in between new frames from the camera, this will
     * mean that this loop will run without ever waiting on a frame, avoiding any context switching
     * or frame acquisition time latency.
     * <p>
     * <p>If you find that this is using more CPU than you'd like, you should probably decrease the
     * FPS setting above to allow for some idle time in between frames.
     */
    @SuppressLint("InlinedApi")
    @SuppressWarnings("GuardedBy")
    @Override
    public void run() {
      ByteBuffer data;

      while (true) {
        synchronized (lock) {
          while (active && (pendingFrameData == null)) {
            try {
              // Wait for the next frame to be received from the camera, since we
              // don't have it yet.
              lock.wait();
            } catch (InterruptedException e) {
              Log.d(TAG, "Frame processing loop terminated.", e);
              return;
            }
          }

          if (!active) {
            // Exit the loop once this camera source is stopped or released.  We check
            // this here, immediately after the wait() above, to handle the case where
            // setActive(false) had been called, triggering the termination of this
            // loop.
            return;
          }

          // Hold onto the frame data locally, so that we can use this for detection
          // below.  We need to clear pendingFrameData to ensure that this buffer isn't
          // recycled back to the camera before we are done using that data.
          data = pendingFrameData;
          pendingFrameData = null;
        }

        // The code below needs to run outside of synchronization, because this will allow
        // the camera to add pending frame(s) while we are running detection on the current
        // frame.

        try {
          synchronized (processorLock) {
            FirebaseVisionImageMetadata metadata =
              new FirebaseVisionImageMetadata.Builder()
                .setFormat(FirebaseVisionImageMetadata.IMAGE_FORMAT_NV21)
                .setWidth(previewSize.getWidth())
                .setHeight(previewSize.getHeight())
                .setRotation(rotation)
                .build();
            FirebaseVisionImage image = FirebaseVisionImage.fromByteBuffer(data, metadata);
            detector.handleDetection(image, liveDetectorFinishedCallback);
          }
        } catch (Throwable t) {
          Log.e(TAG, "Exception thrown from receiver.", t);
        } finally {
          camera.addCallbackBuffer(data.array());
        }
      }
    }
  }
}
