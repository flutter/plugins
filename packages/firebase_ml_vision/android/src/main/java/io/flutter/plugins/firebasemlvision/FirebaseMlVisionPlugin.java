package io.flutter.plugins.firebasemlvision;

import android.app.Activity;
import android.media.Image;
import android.net.Uri;
import android.support.annotation.Nullable;
import android.util.Log;
import android.util.Size;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;

import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugins.camera.PreviewImageDelegate;
import io.flutter.plugins.firebasemlvision.live.CameraPreviewImageProvider;

/** FirebaseMlVisionPlugin */
public class FirebaseMlVisionPlugin implements MethodCallHandler, PreviewImageDelegate {
  public static final int CAMERA_REQUEST_ID = 928291720;
  private final Registrar registrar;
  private final Activity activity;
  @Nullable private EventChannel.EventSink eventSink;
  @Nullable private Detector liveViewDetector;
  @Nullable private Map<String, Object> liveViewOptions;

  private final Detector.OperationFinishedCallback liveDetectorFinishedCallback =
      new Detector.OperationFinishedCallback() {
        @Override
        public void success(Detector detector, Object data, Size imageSize) {
          if (eventSink == null) return;
          Log.d("ML", "detector finished");
          shouldThrottle.set(false);
          Map<String, Object> event = new HashMap<>();
          event.put("eventType", "detection");
          String dataType;
          String dataLabel;
          if (detector instanceof BarcodeDetector) {
            dataType = "barcode";
          } else if (detector instanceof TextDetector) {
            dataType = "text";
          } else if (detector instanceof FaceDetector) {
            dataType = "face";
          } else if (detector instanceof LabelDetector) {
            dataType = "label";
          } else {
            // unsupported detector
            return;
          }
          event.put("detectionType", dataType);
          event.put("data", data);
          Map<String, Object> sizeMap = new HashMap<>();
          sizeMap.put("width", imageSize.getWidth());
          sizeMap.put("height", imageSize.getHeight());
          event.put("imageSize", sizeMap);
          eventSink.success(event);
        }

        @Override
        public void error(DetectorException e) {
          Log.d("ML", "detector error");
          shouldThrottle.set(false);
          if (eventSink != null) {
            e.sendError(eventSink);
          }
        }
      };

  //  @Nullable private LegacyCamera camera;

  private FirebaseMlVisionPlugin(Registrar registrar) {
    this.registrar = registrar;
    this.activity = registrar.activity();
    registerEventChannel();
    if (activity instanceof CameraPreviewImageProvider) {
      ((CameraPreviewImageProvider) activity).setImageDelegate(this);
    }
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_ml_vision");
    channel.setMethodCallHandler(new FirebaseMlVisionPlugin(registrar));
  }

  private void registerEventChannel() {
    new EventChannel(registrar.messenger(), "plugins.flutter.io/firebase_ml_vision/liveViewEvents")
        .setStreamHandler(
            new EventChannel.StreamHandler() {
              @Override
              public void onListen(Object arguments, EventChannel.EventSink eventSink) {
                FirebaseMlVisionPlugin.this.eventSink = eventSink;
              }

              @Override
              public void onCancel(Object arguments) {
                FirebaseMlVisionPlugin.this.eventSink = null;
              }
            });
  }

  @Override
  public void onMethodCall(MethodCall call, final Result result) {
    Map<String, Object> options = call.argument("options");
    FirebaseVisionImage image;
    switch (call.method) {
      case "LiveView#setDetector":
        liveViewOptions = options;
        String detectorType = call.argument("detectorType");
        switch (detectorType) {
          case "text":
            liveViewDetector = TextDetector.instance;
            break;
          case "barcode":
            liveViewDetector = BarcodeDetector.instance;
            break;
          case "face":
            liveViewDetector = FaceDetector.instance;
            break;
          case "label":
            liveViewDetector = LabelDetector.instance;
          default:
            liveViewDetector = TextDetector.instance;
        }
        result.success(null);
        break;
      case "BarcodeDetector#detectInImage":
        try {
          image = filePathToVisionImage((String) call.argument("path"));
          BarcodeDetector.instance.handleDetection(
              image, new Size(0, 0), options, handleDetection(result));
        } catch (IOException e) {
          result.error("barcodeDetectorIOError", e.getLocalizedMessage(), null);
        } catch (Exception e) {
          result.error("barcodeDetectorError", e.getLocalizedMessage(), null);
        }
        break;
      case "FaceDetector#detectInImage":
        try {
          image = filePathToVisionImage((String) call.argument("path"));
          FaceDetector.instance.handleDetection(
              image, new Size(0, 0), options, handleDetection(result));
        } catch (IOException e) {
          result.error("faceDetectorIOError", e.getLocalizedMessage(), null);
        } catch (Exception e) {
          result.error("faceDetectorError", e.getLocalizedMessage(), null);
        }
        break;
      case "LabelDetector#detectInImage":
        try {
          image = filePathToVisionImage((String) call.argument("path"));
          LabelDetector.instance.handleDetection(
              image, new Size(0, 0), options, handleDetection(result));
        } catch (IOException e) {
          result.error("labelDetectorIOError", e.getLocalizedMessage(), null);
        } catch (Exception e) {
          result.error("labelDetectorError", e.getLocalizedMessage(), null);
        }
        break;
      case "TextDetector#detectInImage":
        try {
          image = filePathToVisionImage((String) call.argument("path"));
          TextDetector.instance.handleDetection(
              image, new Size(0, 0), options, handleDetection(result));
        } catch (IOException e) {
          result.error("textDetectorIOError", e.getLocalizedMessage(), null);
        } catch (Exception e) {
          result.error("textDetectorError", e.getLocalizedMessage(), null);
        }
        break;
      default:
        result.notImplemented();
    }
  }

  private final AtomicBoolean shouldThrottle = new AtomicBoolean(false);

  @Override
  public void onImageAvailable(Image image, int rotation) {
    if (eventSink == null) return;
    if (liveViewDetector == null) return;
    if (shouldThrottle.get()) return;
    shouldThrottle.set(true);
    ByteBuffer imageBuffer = YUV_420_888toNV21(image);
    FirebaseVisionImageMetadata metadata =
        new FirebaseVisionImageMetadata.Builder()
            .setFormat(FirebaseVisionImageMetadata.IMAGE_FORMAT_NV21)
            .setWidth(image.getWidth())
            .setHeight(image.getHeight())
            .setRotation(rotation)
            .build();
    FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromByteBuffer(imageBuffer, metadata);

    liveViewDetector.handleDetection(
        firebaseVisionImage,
        new Size(image.getWidth(), image.getHeight()),
        liveViewOptions,
        liveDetectorFinishedCallback);
  }

  private static ByteBuffer YUV_420_888toNV21(Image image) {
    byte[] nv21;
    ByteBuffer yBuffer = image.getPlanes()[0].getBuffer();
    ByteBuffer uBuffer = image.getPlanes()[1].getBuffer();
    ByteBuffer vBuffer = image.getPlanes()[2].getBuffer();

    int ySize = yBuffer.remaining();
    int uSize = uBuffer.remaining();
    int vSize = vBuffer.remaining();

    return ByteBuffer.allocate(ySize + uSize + vSize).put(yBuffer).put(vBuffer).put(uBuffer);
  }

  private Detector.OperationFinishedCallback handleDetection(final Result result) {
    return new Detector.OperationFinishedCallback() {
      @Override
      public void success(
          Detector detector, Object data, Size imageSize /*ignore size for file image detection*/) {
        result.success(data);
      }

      @Override
      public void error(DetectorException e) {
        e.sendError(result);
      }
    };
  }

  private FirebaseVisionImage filePathToVisionImage(String path) throws IOException {
    File file = new File(path);
    return FirebaseVisionImage.fromFilePath(registrar.context(), Uri.fromFile(file));
  }
}
