package io.flutter.plugins.firebasemlvision;

import android.support.annotation.Nullable;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;

import io.flutter.plugin.common.MethodChannel;

public class LabelDetector extends Detector {

  @Override
  void processImage(FirebaseVisionImage image, OperationFinishedCallback finishedCallback) {

  }

  @Override
  public void close(@Nullable OperationFinishedCallback callback) {}
}
