package io.flutter.plugins.firebase_mlkit_language;

import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateLanguage;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateModelManager;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateRemoteModel;

import io.flutter.plugin.common.MethodChannel;

class DownloadModel implements ModelAgent{

    static final DownloadModel instance = new DownloadModel();

    private DownloadModel(){}

    @Override
    public void handleEvent(String modelName, final MethodChannel.Result result) {
        Integer languageCode = FirebaseTranslateLanguage.languageForLanguageCode(modelName);
        FirebaseModelDownloadConditions conditions = new FirebaseModelDownloadConditions.Builder().build();
        FirebaseTranslateRemoteModel model = new FirebaseTranslateRemoteModel.Builder(languageCode)
                .setDownloadConditions(conditions)
                .build();
        FirebaseTranslateModelManager.getInstance().downloadRemoteModelIfNeeded(model)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void v) {
                        result.success("Downloaded");
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        result.error("downloadError", e.getLocalizedMessage(), null);
                    }
                });
    }
}
