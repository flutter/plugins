package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;

class LabelDetector implements Detector {
  @Override
  public void handleDetection(FirebaseVisionImage image, MethodChannel.Result result) {}

  @Override
  public void close(MethodChannel.Result result) {}
}
