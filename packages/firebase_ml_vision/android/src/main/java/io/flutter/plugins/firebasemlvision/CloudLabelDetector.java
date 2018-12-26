package io.flutter.plugins.firebasemlvision;

import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.cloud.FirebaseVisionCloudDetectorOptions;
import com.google.firebase.ml.vision.cloud.label.FirebaseVisionCloudLabel;
import com.google.firebase.ml.vision.cloud.label.FirebaseVisionCloudLabelDetector;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class CloudLabelDetector implements Detector {
  static final CloudLabelDetector instance = new CloudLabelDetector();

  private CloudLabelDetector() {}

  private FirebaseVisionCloudLabelDetector detector;
  private Map<String, Object> lastOptions;

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {

    // Use instantiated detector if the options are the same. Otherwise, close and instantiate new
    // options.

    if (detector == null) {
      lastOptions = options;
      detector =
          FirebaseVision.getInstance().getVisionCloudLabelDetector(parseOptions(lastOptions));
    } else if (!options.equals(lastOptions)) {
      try {
        detector.close();
      } catch (IOException e) {
        result.error("cloudLabelDetectorIOError", e.getLocalizedMessage(), null);
        return;
      }

      lastOptions = options;
      detector =
          FirebaseVision.getInstance().getVisionCloudLabelDetector(parseOptions(lastOptions));
    }

    detector
        .detectInImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionCloudLabel>>() {
              @Override
              public void onSuccess(List<FirebaseVisionCloudLabel> firebaseVisionCloudLabels) {
                List<Map<String, Object>> labels =
                    new ArrayList<>(firebaseVisionCloudLabels.size());
                for (FirebaseVisionCloudLabel label : firebaseVisionCloudLabels) {
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

  private FirebaseVisionCloudDetectorOptions parseOptions(Map<String, Object> optionsData) {
    final int maxResults = (int) optionsData.get("maxResults");
    final String modelTypeStr = (String) optionsData.get("modelType");

    final int modelType;
    switch (modelTypeStr) {
      case "stable":
        modelType = FirebaseVisionCloudDetectorOptions.STABLE_MODEL;
        break;
      case "latest":
        modelType = FirebaseVisionCloudDetectorOptions.LATEST_MODEL;
        break;
      default:
        throw new IllegalArgumentException(String.format("No type for model: %s", modelTypeStr));
    }

    return new FirebaseVisionCloudDetectorOptions.Builder()
        .setMaxResults(maxResults)
        .setModelType(modelType)
        .build();
  }
}
