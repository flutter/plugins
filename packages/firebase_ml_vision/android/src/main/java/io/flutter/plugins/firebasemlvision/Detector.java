package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.vision.common.FirebaseVisionImage;

import io.flutter.plugin.common.MethodChannel;

public abstract class Detector {

  public interface OnDetectionFinishedCallback {
    void dataReady(Detector detector, Object data);

    void detectionError(DetectorException e);
  }

  static FlutterResultWrapper defaultFlutterResultWrapper = new FlutterResultWrapper() {
    @Override
    public Object wrapFlutterResultData(Detector detector, Object data) {
      return data;
    }
  };

  public abstract void close(MethodChannel.Result result);

//  protected abstract void processImage(
//    FirebaseVisionImage image,
//    final FlutterResultWrapper resultWrapper,
//    final OnDetectionFinishedCallback callback);

  public abstract void handleDetection(
    FirebaseVisionImage image,
    OnDetectionFinishedCallback finishedCallback);
}
