package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

import java.util.Map;

interface Detector {
  void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result);
}

interface Setup {
  void setup(
      String modelName, final MethodChannel.Result result);
}
