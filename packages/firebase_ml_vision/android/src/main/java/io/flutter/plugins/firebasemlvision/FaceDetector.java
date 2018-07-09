package io.flutter.plugins.firebasemlvision;

import android.support.annotation.Nullable;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

class FaceDetector implements Detector {
  @Override
  public void handleDetection(
      FirebaseVisionImage image,
      @Nullable Map<String, Object> options,
      final MethodChannel.Result result) {}
}
