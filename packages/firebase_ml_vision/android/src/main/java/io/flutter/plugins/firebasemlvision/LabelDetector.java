package io.flutter.plugins.firebasemlvision;

import android.support.annotation.NonNull;
import android.util.Size;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.label.FirebaseVisionLabel;
import com.google.firebase.ml.vision.label.FirebaseVisionLabelDetector;
import com.google.firebase.ml.vision.label.FirebaseVisionLabelDetectorOptions;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class LabelDetector extends Detector {
  public static final LabelDetector instance = new LabelDetector();

  private LabelDetector() {}

  private FirebaseVisionLabelDetectorOptions parseOptions(Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionLabelDetectorOptions.Builder().setConfidenceThreshold(conf).build();
  }

  @Override
  void processImage(
    FirebaseVisionImage image,
    final Size imageSize,
    Map<String, Object> options,
    final OperationFinishedCallback finishedCallback) {
    FirebaseVisionLabelDetector detector =
        FirebaseVision.getInstance().getVisionLabelDetector(parseOptions(options));
    detector
        .detectInImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionLabel>>() {
              @Override
              public void onSuccess(List<FirebaseVisionLabel> firebaseVisionLabels) {
                List<Map<String, Object>> labels = new ArrayList<>(firebaseVisionLabels.size());
                for (FirebaseVisionLabel label : firebaseVisionLabels) {
                  Map<String, Object> labelData = new HashMap<>();
                  labelData.put("confidence", (double) label.getConfidence());
                  labelData.put("entityId", label.getEntityId());
                  labelData.put("label", label.getLabel());

                  labels.add(labelData);
                }

                finishedCallback.success(LabelDetector.this, labels, imageSize);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                finishedCallback.error(
                    new DetectorException("labelDetectorError", e.getLocalizedMessage(), null));
              }
            });
  }
}
