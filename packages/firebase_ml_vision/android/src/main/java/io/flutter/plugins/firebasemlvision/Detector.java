package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

interface Detector {
  void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result);
}
