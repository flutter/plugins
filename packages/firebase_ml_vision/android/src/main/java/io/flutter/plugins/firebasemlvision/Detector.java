package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import java.io.IOException;
import io.flutter.plugin.common.MethodChannel;

interface Detector {
  void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result);
  void close() throws IOException;
}
