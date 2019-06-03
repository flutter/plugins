package io.flutter.plugins.firebase_mlkit_language;

import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.naturallanguage.FirebaseNaturalLanguage;
import com.google.firebase.ml.naturallanguage.languageid.FirebaseLanguageIdentification;
import com.google.firebase.ml.naturallanguage.languageid.FirebaseLanguageIdentificationOptions;
import com.google.firebase.ml.naturallanguage.languageid.IdentifiedLanguage;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class LanguageIdentifier implements LanguageAgent {

  static final LanguageIdentifier instance = new LanguageIdentifier();

  private LanguageIdentifier() {}

  private FirebaseLanguageIdentification identifier;
  private Map<String, Object> lastOptions;

  @Override
  public void handleEvent(
      String text, Map<String, Object> options, final MethodChannel.Result result) {

    if (identifier != null && !options.equals(lastOptions)) {
      identifier.close();
      identifier = null;
      lastOptions = null;
    }

    if (identifier == null) {
      lastOptions = options;
      identifier =
          FirebaseNaturalLanguage.getInstance()
              .getLanguageIdentification(parseOptions(lastOptions));
    }

    identifier
        .identifyPossibleLanguages(text)
        .addOnSuccessListener(
            new OnSuccessListener<List<IdentifiedLanguage>>() {
              @Override
              public void onSuccess(List<IdentifiedLanguage> identifiedLanguages) {
                List<Map<String, Object>> labels = new ArrayList<>(identifiedLanguages.size());
                for (IdentifiedLanguage identifiedLanguage : identifiedLanguages) {
                  Map<String, Object> labelData = new HashMap<>();
                  String language = identifiedLanguage.getLanguageCode();
                  float confidence = identifiedLanguage.getConfidence();
                  labelData.put("confidence", (double) confidence);
                  labelData.put("languageCode", language);
                  labels.add(labelData);
                }
                result.success(labels);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("languageIdentifierError", e.getLocalizedMessage(), null);
              }
            });
  }

  private FirebaseLanguageIdentificationOptions parseOptions(Map<String, Object> optionsData) {
    float conf = (float) (double) optionsData.get("confidenceThreshold");
    return new FirebaseLanguageIdentificationOptions.Builder().setConfidenceThreshold(conf).build();
  }
}
