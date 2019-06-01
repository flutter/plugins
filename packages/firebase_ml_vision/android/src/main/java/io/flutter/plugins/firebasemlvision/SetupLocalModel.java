package io.flutter.plugins.firebasemlvision;

import com.google.firebase.ml.common.modeldownload.FirebaseLocalModel;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import io.flutter.plugin.common.MethodChannel;

class SetupLocalModel implements Setup {
  static final SetupLocalModel instance = new SetupLocalModel();

  private SetupLocalModel() {}

  @Override
  public void setup(String modelName, MethodChannel.Result result) {
    String finalPath = "flutter_assets/assets/" + modelName + "/manifest.json";
    FirebaseLocalModel localModel = FirebaseModelManager.getInstance().getLocalModel(modelName);
    if (localModel == null) {
      localModel = new FirebaseLocalModel.Builder(modelName).setAssetFilePath(finalPath).build();
      FirebaseModelManager.getInstance().registerLocalModel(localModel);
      result.success("Model Setup Complete");
    } else {
      result.success("Model Already Setup");
    }
  }
}
