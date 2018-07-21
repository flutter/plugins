package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import java.util.Map;

public class LabelDetector extends Detector {

  @Override
  void processImage(
      FirebaseVisionImage image,
      Map<String, Object> options,
      OperationFinishedCallback finishedCallback) {}
}
