package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.common.modeldownload.FirebaseRemoteModel;
import io.flutter.plugin.common.MethodChannel;

class SetupRemoteModel implements Setup {
  static final SetupRemoteModel instance = new SetupRemoteModel();

  private SetupRemoteModel() {}

  @Override
  public void setup(String modelName, final MethodChannel.Result result) {
    FirebaseRemoteModel remoteModel =
        FirebaseModelManager.getInstance().getNonBaseRemoteModel(modelName);
    if (remoteModel == null) {
      FirebaseModelDownloadConditions conditions =
          new FirebaseModelDownloadConditions.Builder().build();
      remoteModel =
          new FirebaseRemoteModel.Builder(modelName)
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
                  result.success("Model Setup Complete");
                }
              })
          .addOnFailureListener(
              new OnFailureListener() {
                @Override
                public void onFailure(@NonNull Exception e) {
                  result.error(
                      "visionEdgeLabelDetectorLabelerError", e.getLocalizedMessage(), null);
                  return;
                }
              });
    } else {
      result.success("Model Already Setup");
    }
  }
}
