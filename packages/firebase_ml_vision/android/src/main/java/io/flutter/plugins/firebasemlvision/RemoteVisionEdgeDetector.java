package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.common.FirebaseMLException;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.common.modeldownload.FirebaseRemoteModel;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabel;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabeler;
import com.google.firebase.ml.vision.label.FirebaseVisionOnDeviceAutoMLImageLabelerOptions;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class RemoteVisionEdgeDetector implements Detector {
  private FirebaseVisionImageLabeler labeler;

  RemoteVisionEdgeDetector(FirebaseVision vision, final Map<String, Object> options) {
    FirebaseRemoteModel remoteModel =
        FirebaseModelManager.getInstance().getNonBaseRemoteModel((String) options.get("dataset"));
    if (remoteModel == null) {
      FirebaseModelDownloadConditions conditions =
          new FirebaseModelDownloadConditions.Builder().build();
      remoteModel =
          new FirebaseRemoteModel.Builder((String) options.get("dataset"))
              .enableModelUpdates(true)
              .setInitialDownloadConditions(conditions)
              .setUpdatesDownloadConditions(conditions)
              .build();
      FirebaseModelManager.getInstance().registerRemoteModel(remoteModel);
      FirebaseModelManager.getInstance()
          .downloadRemoteModelIfNeeded(remoteModel)
          .addOnSuccessListener(
              new OnSuccessListener<Void>() {
                @Override
                public void onSuccess(Void success) {
                  try {
                    labeler =
                        FirebaseVision.getInstance()
                            .getOnDeviceAutoMLImageLabeler(parseOptions(options));
                  } catch (FirebaseMLException e) {
                    throw new IllegalArgumentException(e.getLocalizedMessage());
                  }
                }
              })
          .addOnFailureListener(
              new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                  throw new IllegalArgumentException(e.getLocalizedMessage());
                }
              });
      try {
        labeler = FirebaseVision.getInstance().getOnDeviceAutoMLImageLabeler(parseOptions(options));
      } catch (FirebaseMLException e) {
        throw new IllegalArgumentException(e.getLocalizedMessage());
      }
    } else {
      FirebaseModelManager.getInstance()
          .downloadRemoteModelIfNeeded(remoteModel)
          .addOnSuccessListener(
              new OnSuccessListener<Void>() {
                @Override
                public void onSuccess(Void success) {
                  try {
                    labeler =
                        FirebaseVision.getInstance()
                            .getOnDeviceAutoMLImageLabeler(parseOptions(options));
                  } catch (FirebaseMLException e) {
                    throw new IllegalArgumentException(e.getLocalizedMessage());
                  }
                }
              })
          .addOnFailureListener(
              new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                  throw new IllegalArgumentException(e.getLocalizedMessage());
                }
              });
    }
  }

  @Override
  public void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result) {
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

  private FirebaseVisionOnDeviceAutoMLImageLabelerOptions parseOptions(
      Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseVisionOnDeviceAutoMLImageLabelerOptions.Builder()
        .setRemoteModelName((String) optionsData.get("dataset"))
        .setConfidenceThreshold(conf)
        .build();
  }

  @Override
  public void close() throws IOException {
    labeler.close();
  }
}
