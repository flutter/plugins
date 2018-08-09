package io.flutter.plugins.firebasemlvision;

import android.util.Size;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public abstract class Detector {

  public interface OperationFinishedCallback {
    void success(Detector detector, Object data, Size size);

    void error(DetectorException e);
  }

  private final AtomicBoolean shouldThrottle = new AtomicBoolean(false);

  public void handleDetection(
    final FirebaseVisionImage image,
    final Size imageSize,
    Map<String, Object> options,
    final OperationFinishedCallback finishedCallback) {
    if (shouldThrottle.get()) {
      return;
    }
    processImage(
        image,
        imageSize,
        options,
        new OperationFinishedCallback() {
          @Override
          public void success(Detector detector, Object data, Size size) {
            shouldThrottle.set(false);
            finishedCallback.success(detector, data, size);
          }

          @Override
          public void error(DetectorException e) {
            shouldThrottle.set(false);
            finishedCallback.error(e);
          }
        });

    // Begin throttling until this frame of input has been processed, either in onSuccess or
    // onFailure.
    shouldThrottle.set(true);
  }

  abstract void processImage(
      FirebaseVisionImage image,
      Size imageSize,
      Map<String, Object> options,
      OperationFinishedCallback finishedCallback);
}
