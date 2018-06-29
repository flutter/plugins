package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;

interface Detector {
  void close(MethodChannel.Result result);

  void handleDetection(FirebaseVisionImage image, final MethodChannel.Result result);
}
