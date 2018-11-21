package io.flutter.plugins.firebasemlvision;

import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.label.FirebaseVisionLabel;
import com.google.firebase.ml.vision.label.FirebaseVisionLabelDetector;
import com.google.firebase.ml.vision.label.FirebaseVisionLabelDetectorOptions;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class LabelDetector implements Detector {
  static final LabelDetector instance = new LabelDetector();

  private LabelDetector() {}

  private FirebaseVisionLabelDetector detector;
  private Map<String, Object> lastOptions;

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {

    // Use instantiated detector if the options are the same. Otherwise, close and instantiate new
    // options.

    if (detector == null) {
      lastOptions = options;
      detector = FirebaseVision.getInstance().getVisionLabelDetector(parseOptions(lastOptions));
    } else if (!options.equals(lastOptions)) {
      try {
        detector.close();
      } catch (IOException e) {
        result.error("labelDetectorIOError", e.getLocalizedMessage(), null);
        return;
      }

      lastOptions = options;
      detector = FirebaseVision.getInstance().getVisionLabelDetector(parseOptions(lastOptions));
    }

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

                result.success(labels);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("labelDetectorError", e.getLocalizedMessage(), null);
              }
            });
  }

  private FirebaseVisionLabelDetectorOptions parseOptions(Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionLabelDetectorOptions.Builder().setConfidenceThreshold(conf).build();
  }
}
