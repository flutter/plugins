package io.flutter.plugins.firebasemlvision;

import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.document.FirebaseVisionCloudDocumentRecognizerOptions;
import com.google.firebase.ml.vision.document.FirebaseVisionDocumentText;
import com.google.firebase.ml.vision.document.FirebaseVisionDocumentTextRecognizer;

import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class CloudDocumentTextRecognizer implements Detector {
  public static final CloudDocumentTextRecognizer instance = new CloudDocumentTextRecognizer();

  private CloudDocumentTextRecognizer() {}

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {
    FirebaseVisionDocumentTextRecognizer recognizer =
        FirebaseVision.getInstance().getCloudDocumentTextRecognizer(parseOptions(options));

    recognizer
        .processImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<FirebaseVisionDocumentText>() {
              @Override
              public void onSuccess(FirebaseVisionDocumentText firebaseVisionDocumentText) {
                
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("cloudDocumentTextRecognizerError", e.getLocalizedMessage(), null);
              }
            });
  }

  private FirebaseVisionCloudDocumentRecognizerOptions parseOptions(Map<String, Object> options) {
    FirebaseVisionCloudDocumentRecognizerOptions.Builder builder =
        new FirebaseVisionCloudDocumentRecognizerOptions.Builder();

    boolean enforceCertFingerprintMatch = (Boolean) options.get("enforceCertFingerprintMatch");
    if (enforceCertFingerprintMatch) builder.enforceCertFingerprintMatch();

    @SuppressWarnings("unchecked")
    List<String> hintedLanguages = (List<String>) options.get("hintedLanguages");
    builder.setLanguageHints(hintedLanguages);

    return builder.build();
  }
}
