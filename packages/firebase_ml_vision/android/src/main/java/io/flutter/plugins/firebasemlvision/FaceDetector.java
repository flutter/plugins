package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;

public class FaceDetector extends Detector {

  @Override
  public void handleDetection(FirebaseVisionImage image, OnDetectionFinishedCallback finishedCallback) {

  }

  @Override
  public void close(MethodChannel.Result result) {
  }
}
