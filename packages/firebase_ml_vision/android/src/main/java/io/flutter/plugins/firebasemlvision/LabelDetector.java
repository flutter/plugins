package io.flutter.plugins.firebasemlvision;

import android.support.annotation.Nullable;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

public class LabelDetector extends Detector {

  @Override
  public void close(@Nullable OperationFinishedCallback callback) {

  }

  @Override
  void processImage(FirebaseVisionImage image, Map<String, Object> options, OperationFinishedCallback finishedCallback) {

  }
}