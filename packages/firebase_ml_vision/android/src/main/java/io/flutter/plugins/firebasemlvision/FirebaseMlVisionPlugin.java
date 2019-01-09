package io.flutter.plugins.firebasemlvision;

import android.net.Uri;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionImageMetadata;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.File;
import java.io.IOException;
import java.util.Map;

/** FirebaseMlVisionPlugin */
public class FirebaseMlVisionPlugin implements MethodCallHandler {
  private Registrar registrar;

  private FirebaseMlVisionPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_ml_vision");
    channel.setMethodCallHandler(new FirebaseMlVisionPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    Map<String, Object> options = call.argument("options");

    FirebaseVisionImage image;
    Map<String, Object> imageData = call.arguments();
    try {
      image = dataToVisionImage(imageData);
    } catch (IOException exception) {
      result.error("MLVisionDetectorIOError", exception.getLocalizedMessage(), null);
      return;
    }

    switch (call.method) {
      case "BarcodeDetector#detectInImage":
        BarcodeDetector.instance.handleDetection(image, options, result);
        break;
      case "FaceDetector#detectInImage":
        FaceDetector.instance.handleDetection(image, options, result);
        break;
      case "LabelDetector#detectInImage":
        LabelDetector.instance.handleDetection(image, options, result);
        break;
      case "CloudLabelDetector#detectInImage":
        CloudLabelDetector.instance.handleDetection(image, options, result);
        break;
      case "TextRecognizer#processImage":
        TextRecognizer.instance.handleDetection(image, options, result);
        break;
      default:
        result.notImplemented();
    }
  }

  private FirebaseVisionImage dataToVisionImage(Map<String, Object> imageData) throws IOException {
    String imageType = (String) imageData.get("type");

    switch (imageType) {
      case "file":
        File file = new File((String) imageData.get("path"));
        return FirebaseVisionImage.fromFilePath(registrar.context(), Uri.fromFile(file));
      case "bytes":
        @SuppressWarnings("unchecked")
        Map<String, Object> metadataData = (Map<String, Object>) imageData.get("metadata");

        FirebaseVisionImageMetadata metadata =
            new FirebaseVisionImageMetadata.Builder()
                .setWidth((int) (double) metadataData.get("width"))
                .setHeight((int) (double) metadataData.get("height"))
                .setFormat(FirebaseVisionImageMetadata.IMAGE_FORMAT_NV21)
                .setRotation(getRotation((int) metadataData.get("rotation")))
                .build();

        return FirebaseVisionImage.fromByteArray((byte[]) imageData.get("bytes"), metadata);
      default:
        throw new IllegalArgumentException(String.format("No image type for: %s", imageType));
    }
  }

  private int getRotation(int rotation) {
    switch (rotation) {
      case 0:
        return FirebaseVisionImageMetadata.ROTATION_0;
      case 90:
        return FirebaseVisionImageMetadata.ROTATION_90;
      case 180:
        return FirebaseVisionImageMetadata.ROTATION_180;
      case 270:
        return FirebaseVisionImageMetadata.ROTATION_270;
      default:
        throw new IllegalArgumentException(String.format("No rotation for: %d", rotation));
    }
  }
}
