package io.flutter.plugins.firebase_mlkit_language;

import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.common.modeldownload.FirebaseModelDownloadConditions;
import com.google.firebase.ml.naturallanguage.FirebaseNaturalLanguage;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslateLanguage;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslator;
import com.google.firebase.ml.naturallanguage.translate.FirebaseTranslatorOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.Map;

class LanguageTranslator implements LanguageAgent {

  static final LanguageTranslator instance = new LanguageTranslator();

  private LanguageTranslator() {}

  private FirebaseTranslator translator;
  private Map<String, Object> lastOptions;

  @Override
  public void handleEvent(
      final String text, Map<String, Object> options, final MethodChannel.Result result) {

    if (translator != null && !options.equals(lastOptions)) {
      translator.close();
      translator = null;
      lastOptions = null;
    }

    if (translator == null) {
      lastOptions = options;
      FirebaseTranslatorOptions translatorOptions =
          new FirebaseTranslatorOptions.Builder()
              .setSourceLanguage(
                  FirebaseTranslateLanguage.languageForLanguageCode(
                      (String) options.get("fromLanguage")))
              .setTargetLanguage(
                  FirebaseTranslateLanguage.languageForLanguageCode(
                      (String) options.get("toLanguage")))
              .build();
      translator = FirebaseNaturalLanguage.getInstance().getTranslator(translatorOptions);
    }
    FirebaseModelDownloadConditions conditions =
        new FirebaseModelDownloadConditions.Builder().build();
    translator
        .downloadModelIfNeeded(conditions)
        .addOnSuccessListener(
            new OnSuccessListener<Void>() {
              @Override
              public void onSuccess(Void v) {
                translator
                    .translate(text)
                    .addOnSuccessListener(
                        new OnSuccessListener<String>() {
                          @Override
                          public void onSuccess(@NonNull String translatedText) {
                            result.success(translatedText);
                          }
                        })
                    .addOnFailureListener(
                        new OnFailureListener() {
                          @Override
                          public void onFailure(@NonNull Exception e) {
                            result.error("languageTranslatorError", e.getLocalizedMessage(), null);
                          }
                        });
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("languageTranslatorError", e.getLocalizedMessage(), null);
              }
            });
  }
}
