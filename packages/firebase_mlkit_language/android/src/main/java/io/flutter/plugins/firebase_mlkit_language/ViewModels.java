package io.flutter.plugins.firebase_mlkit_language;

import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.FirebaseApp;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateModelManager;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateRemoteModel;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

class ViewModels implements ViewModelAgent {

  static final ViewModels instance = new ViewModels();

  private ViewModels() {}

  @Override
  public void handleEvent(final MethodChannel.Result result) {
    FirebaseTranslateModelManager.getInstance()
        .getAvailableModels(FirebaseApp.getInstance())
        .addOnSuccessListener(
            new OnSuccessListener<Set<FirebaseTranslateRemoteModel>>() {
              @Override
              public void onSuccess(Set<FirebaseTranslateRemoteModel> models) {
                List<Map<String, Object>> translateModels = new ArrayList<>(models.size());
                for (FirebaseTranslateRemoteModel model : models) {
                  Map<String, Object> langData = new HashMap<>();
                  langData.put("languageCode", model.getLanguageCode());
                  translateModels.add(langData);
                }
                result.success(translateModels);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("viewError", e.getLocalizedMessage(), null);
              }
            });
  }
}
