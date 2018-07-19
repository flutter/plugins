package io.flutter.plugins.firebasemlvision.live;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
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
import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.params.StreamConfigurationMap;
import android.media.Image;
import android.media.ImageReader;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.annotation.RequiresApi;
import android.util.Log;
import android.util.Size;
import android.util.SparseIntArray;
import android.view.Surface;
import android.view.WindowManager;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugins.firebasemlvision.BarcodeDetector;
import io.flutter.plugins.firebasemlvision.DetectorException;
import io.flutter.plugins.firebasemlvision.TextDetector;
import io.flutter.view.FlutterView;

import io.flutter.plugins.firebasemlvision.Detector;

import static io.flutter.plugins.firebasemlvision.FirebaseMlVisionPlugin.CAMERA_REQUEST_ID;

@TargetApi(Build.VERSION_CODES.LOLLIPOP)
public class Camera {
  private static final SparseIntArray ORIENTATIONS = new SparseIntArray(4);

  static {
    ORIENTATIONS.append(Surface.ROTATION_0, 90);
    ORIENTATIONS.append(Surface.ROTATION_90, 0);
    ORIENTATIONS.append(Surface.ROTATION_180, 270);
    ORIENTATIONS.append(Surface.ROTATION_270, 180);
  }

  private final FlutterView.SurfaceTextureEntry textureEntry;
  private CameraDevice cameraDevice;
  private CameraCaptureSession cameraCaptureSession;
  private EventChannel.EventSink eventSink;
  private ImageReader imageReader;
  private String cameraName;
  private Size captureSize;
  private Size previewSize;
  private CaptureRequest.Builder captureRequestBuilder;
  private MediaRecorder mediaRecorder;
  private Runnable cameraPermissionContinuation;
  private boolean requestingPermission;
  private PluginRegistry.Registrar registrar;
  private Activity activity;
  private CameraManager cameraManager;
  private HandlerThread mBackgroundThread;
  private Handler mBackgroundHandler;
  private Surface imageReaderSurface;
  private WindowManager windowManager;
  private Detector currentDetector = TextDetector.instance;

  private Detector.OperationFinishedCallback liveDetectorFinishedCallback = new Detector.OperationFinishedCallback() {
    @Override
    public void success(Detector detector, Object data) {
      shouldThrottle.set(false);
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
      shouldThrottle.set(false);
      e.sendError(eventSink);
    }
  };

  public Camera(PluginRegistry.Registrar registrar, final String cameraName, @NonNull final String resolutionPreset, @NonNull final MethodChannel.Result result) {

    this.activity = registrar.activity();
    this.cameraManager = (CameraManager) activity.getSystemService(Context.CAMERA_SERVICE);
    this.registrar = registrar;
    this.cameraName = cameraName;
    textureEntry = registrar.view().createSurfaceTexture();

    registerEventChannel();

    try {
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

      CameraCharacteristics cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraName);
      StreamConfigurationMap streamConfigurationMap =
        cameraCharacteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);

      computeBestCaptureSize(streamConfigurationMap);
      computeBestPreviewAndRecordingSize(streamConfigurationMap, minPreviewSize, captureSize);

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
            open(result);
          }
        };
      requestingPermission = false;
      if (hasCameraPermission()/* && hasAudioPermission()*/) {
        cameraPermissionContinuation.run();
      } else {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
          requestingPermission = true;
          registrar
            .activity()
            .requestPermissions(
              new String[]{Manifest.permission.CAMERA},
              CAMERA_REQUEST_ID);
        }
      }
    } catch (CameraAccessException e) {
      result.error("CameraAccess", e.getMessage(), null);
    } catch (IllegalArgumentException e) {
      result.error("IllegalArgumentException", e.getMessage(), null);
    }
  }

  public void continueRequestingPermissions() {
    cameraPermissionContinuation.run();
  }

  public boolean getRequestingPermission() {
    return requestingPermission;
  }

  public void setRequestingPermission(boolean isRequesting) {
    requestingPermission = isRequesting;
  }

  private void registerEventChannel() {
    new EventChannel(
      registrar.messenger(), "plugins.flutter.io/firebase_ml_vision/liveViewEvents" + textureEntry.id())
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

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private void computeBestPreviewAndRecordingSize(
    StreamConfigurationMap streamConfigurationMap, Size minPreviewSize, Size captureSize) {
    Size[] sizes = streamConfigurationMap.getOutputSizes(SurfaceTexture.class);
    float captureSizeRatio = (float) captureSize.getWidth() / captureSize.getHeight();
    List<Size> goodEnough = new ArrayList<>();
    for (Size s : sizes) {
      if ((float) s.getWidth() / s.getHeight() == captureSizeRatio
        && minPreviewSize.getWidth() < s.getWidth()
        && minPreviewSize.getHeight() < s.getHeight()) {
        goodEnough.add(s);
      }
    }

    Collections.sort(goodEnough, new CompareSizesByArea());

    if (goodEnough.isEmpty()) {
      previewSize = sizes[0];
    } else {
      previewSize = goodEnough.get(0);

      // Video capture size should not be greater than 1080 because MediaRecorder cannot handle higher resolutions.
      for (int i = goodEnough.size() - 1; i >= 0; i--) {
        if (goodEnough.get(i).getHeight() <= 1080) {
          break;
        }
      }
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  private void computeBestCaptureSize(StreamConfigurationMap streamConfigurationMap) {
    // For still image captures, we use the largest available size.
    captureSize =
      Collections.max(
        Arrays.asList(streamConfigurationMap.getOutputSizes(ImageFormat.JPEG)),
        new CompareSizesByArea());
  }

  /**
   * Starts a background thread and its {@link Handler}.
   */
  private void startBackgroundThread() {
    mBackgroundThread = new HandlerThread("CameraBackground");
    mBackgroundThread.start();
    mBackgroundHandler = new Handler(mBackgroundThread.getLooper());
  }

  /**
   * Stops the background thread and its {@link Handler}.
   */
  private void stopBackgroundThread() {
    if (mBackgroundThread != null) {
      mBackgroundThread.quitSafely();
      try {
        mBackgroundThread.join();
        mBackgroundThread = null;
        mBackgroundHandler = null;
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  }

  private static ByteBuffer YUV_420_888toNV21(Image image) {
    byte[] nv21;
    ByteBuffer yBuffer = image.getPlanes()[0].getBuffer();
    ByteBuffer uBuffer = image.getPlanes()[1].getBuffer();
    ByteBuffer vBuffer = image.getPlanes()[2].getBuffer();

    int ySize = yBuffer.remaining();
    int uSize = uBuffer.remaining();
    int vSize = vBuffer.remaining();

    ByteBuffer output = ByteBuffer.allocate(ySize + uSize + vSize)
      .put(yBuffer)
      .put(vBuffer)
      .put(uBuffer);
    return output;

  }

  private int getRotation() {
    if (windowManager == null) {
      windowManager = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
    }
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
        Log.e("ML", "Bad rotation value: $rotation");
    }

    try {
      int angle;
      int displayAngle; // TODO? setDisplayOrientation?
      CameraCharacteristics cameraCharacteristics = cameraManager.getCameraCharacteristics(cameraName);
      Integer orientation = cameraCharacteristics.get(CameraCharacteristics.SENSOR_ORIENTATION);
      // back-facing
      angle = (orientation - degrees + 360) % 360;
      displayAngle = angle;
      int translatedAngle = angle / 90;
      Log.d("ML", "Translated angle: " + translatedAngle);
      return translatedAngle; // this corresponds to the rotation constants
    } catch (CameraAccessException e) {
      return 0;
    }
  }

  private AtomicBoolean shouldThrottle = new AtomicBoolean(false);

  private void processImage(Image image) {
    if (eventSink == null) return;
    if (shouldThrottle.get()) {
      return;
    }
    shouldThrottle.set(true);
    ByteBuffer imageBuffer = YUV_420_888toNV21(image);
    FirebaseVisionImageMetadata metadata = new FirebaseVisionImageMetadata.Builder()
      .setFormat(FirebaseVisionImageMetadata.IMAGE_FORMAT_NV21)
      .setWidth(image.getWidth())
      .setHeight(image.getHeight())
      .setRotation(getRotation())
      .build();
    FirebaseVisionImage firebaseVisionImage = FirebaseVisionImage.fromByteBuffer(imageBuffer, metadata);

    currentDetector.handleDetection(firebaseVisionImage, liveDetectorFinishedCallback);

//    FirebaseVisionBarcodeDetector visionBarcodeDetector = FirebaseVision.getInstance().getVisionBarcodeDetector();
//    visionBarcodeDetector.detectInImage(firebaseVisionImage).addOnSuccessListener(new OnSuccessListener<List<FirebaseVisionBarcode>>() {
//      @Override
//      public void onSuccess(List<FirebaseVisionBarcode> firebaseVisionBarcodes) {
//        shouldThrottle.set(false);
//        sendRecognizedBarcodes(firebaseVisionBarcodes);
//      }
//    }).addOnFailureListener(new OnFailureListener() {
//      @Override
//      public void onFailure(@NonNull Exception e) {
//        shouldThrottle.set(false);
//        sendErrorEvent(e.getLocalizedMessage());
//      }
//    });
  }

  private ImageReader.OnImageAvailableListener imageAvailable = new ImageReader.OnImageAvailableListener() {
    @Override
    public void onImageAvailable(ImageReader reader) {
      Image image = reader.acquireLatestImage();
      if (image != null) {
//        Log.d("ML", "image was not null");
        processImage(image);
        image.close();
      }
    }
  };

  public void open(@Nullable final MethodChannel.Result result) {
    if (!hasCameraPermission()) {
      if (result != null) result.error("cameraPermission", "Camera permission not granted", null);
    } else {
      try {
        startBackgroundThread();
        imageReader =
          ImageReader.newInstance(
            previewSize.getWidth(), previewSize.getHeight(), ImageFormat.YUV_420_888, 4);
        imageReaderSurface = imageReader.getSurface();
        imageReader.setOnImageAvailableListener(imageAvailable, mBackgroundHandler);
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

  private void startPreview() throws CameraAccessException {

    SurfaceTexture surfaceTexture = textureEntry.surfaceTexture();
    surfaceTexture.setDefaultBufferSize(previewSize.getWidth(), previewSize.getHeight());
    captureRequestBuilder = cameraDevice.createCaptureRequest(CameraDevice.TEMPLATE_PREVIEW);

    List<Surface> surfaces = new ArrayList<>();

    Surface previewSurface = new Surface(surfaceTexture);
    surfaces.add(previewSurface);
    captureRequestBuilder.addTarget(previewSurface);

    surfaces.add(imageReaderSurface);
    captureRequestBuilder.addTarget(imageReaderSurface);

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

//  private void sendRecognizedBarcodes(List<FirebaseVisionBarcode> barcodes) {
//    if (eventSink != null) {
//      List<Map<String, Object>> outputMap = new ArrayList<>();
//      for (FirebaseVisionBarcode barcode : barcodes) {
//        Map<String, Object> barcodeData = new HashMap<>();
//        Rect boundingBox = barcode.getBoundingBox();
//        if (boundingBox != null) {
//          barcodeData.putAll(DetectedItemUtils.rectToFlutterMap(boundingBox));
//        }
//        barcodeData.put(BARCODE_VALUE_TYPE, barcode.getValueType());
//        barcodeData.put(BARCODE_DISPLAY_VALUE, barcode.getDisplayValue());
//        barcodeData.put(BARCODE_RAW_VALUE, barcode.getRawValue());
//        outputMap.add(barcodeData);
//      }
//      Map<String, Object> event = new HashMap<>();
//      event.put("eventType", "recognized");
//      event.put("recognitionType", "barcode");
//      event.put("barcodeData", outputMap);
//      eventSink.success(event);
//    }
//  }

  private void sendErrorEvent(String errorDescription) {
    if (eventSink != null) {
      Map<String, String> event = new HashMap<>();
      event.put("eventType", "error");
      event.put("errorDescription", errorDescription);
      eventSink.success(event);
    }
  }

  public void close() {
    if (cameraCaptureSession != null) {
      cameraCaptureSession.close();
    }
    if (cameraDevice != null) {
      cameraDevice.close();
      cameraDevice = null;
    }
    if (imageReader != null) {
      imageReader.close();
      imageReader = null;
    }
    if (mediaRecorder != null) {
      mediaRecorder.reset();
      mediaRecorder.release();
      mediaRecorder = null;
    }
    stopBackgroundThread();
  }

  public void dispose() {
    close();
    textureEntry.release();
  }

  private static class CompareSizesByArea implements Comparator<Size> {
    @Override
    public int compare(Size lhs, Size rhs) {
      // We cast here to ensure the multiplications won't overflow.
      return Long.signum(
        (long) lhs.getWidth() * lhs.getHeight() - (long) rhs.getWidth() * rhs.getHeight());
    }
  }
}
