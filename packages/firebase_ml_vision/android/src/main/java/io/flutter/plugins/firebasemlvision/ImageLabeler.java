package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.label.FirebaseVisionCloudImageLabelerOptions;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabel;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabeler;
import com.google.firebase.ml.vision.label.FirebaseVisionOnDeviceImageLabelerOptions;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class ImageLabeler implements Detector {
  static final ImageLabeler instance = new ImageLabeler();

  private ImageLabeler() {}

  private FirebaseVisionImageLabeler labeler;
  private Map<String, Object> lastOptions;

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {

    // Use instantiated labeler if the options are the same. Otherwise, close and instantiate new
    // options.

    if (labeler != null && !options.equals(lastOptions)) {
      try {
        labeler.close();
      } catch (IOException e) {
        result.error("labelDetectorIOError", e.getLocalizedMessage(), null);
        return;
      }

      labeler = null;
      lastOptions = null;
    }

    if (labeler == null) {
      lastOptions = options;

      final String modelType = (String) options.get("modelType");
      if (modelType.equals("onDevice")) {
        labeler = FirebaseVision.getInstance().getOnDeviceImageLabeler(parseOptions(lastOptions));
      } else if (modelType.equals("cloud")) {
        labeler = FirebaseVision.getInstance().getCloudImageLabeler(parseCloudOptions(lastOptions));
      }
    }

    labeler
        .processImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionImageLabel>>() {
              @Override
              public void onSuccess(List<FirebaseVisionImageLabel> firebaseVisionLabels) {
                List<Map<String, Object>> labels = new ArrayList<>(firebaseVisionLabels.size());
                for (FirebaseVisionImageLabel label : firebaseVisionLabels) {
                  Map<String, Object> labelData = new HashMap<>();
                  labelData.put("confidence", (double) label.getConfidence());
                  labelData.put("entityId", label.getEntityId());
                  labelData.put("text", label.getText());

                  labels.add(labelData);
                }

                result.success(labels);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("imageLabelerError", e.getLocalizedMessage(), null);
              }
            });
  }

  private FirebaseVisionOnDeviceImageLabelerOptions parseOptions(Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionOnDeviceImageLabelerOptions.Builder()
        .setConfidenceThreshold(conf)
        .build();
  }

  private FirebaseVisionCloudImageLabelerOptions parseCloudOptions(
      Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionCloudImageLabelerOptions.Builder()
        .setConfidenceThreshold(conf)
        .build();
  }
}
