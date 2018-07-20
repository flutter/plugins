package io.flutter.plugins.firebasemlvision;

import android.support.annotation.Nullable;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;

import java.util.concurrent.atomic.AtomicBoolean;

public abstract class Detector {

  public interface OperationFinishedCallback {
    void success(Detector detector, Object data);

    void error(DetectorException e);
  }

  private final AtomicBoolean shouldThrottle = new AtomicBoolean(false);

  public abstract void close(@Nullable OperationFinishedCallback callback);

  public void handleDetection(
    FirebaseVisionImage image,
    Map<String, Object> options,
    final OperationFinishedCallback finishedCallback) {
    if (shouldThrottle.get()) {
      return;
    }
    processImage(image, new OperationFinishedCallback() {
      @Override
      public void success(Detector detector, Object data) {
        shouldThrottle.set(false);
        finishedCallback.success(detector, data);
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
    FirebaseVisionImage image, OperationFinishedCallback finishedCallback);
}
