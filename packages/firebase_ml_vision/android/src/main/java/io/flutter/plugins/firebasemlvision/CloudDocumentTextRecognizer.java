package io.flutter.plugins.firebasemlvision;

import android.graphics.Rect;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.document.FirebaseVisionCloudDocumentRecognizerOptions;
import com.google.firebase.ml.vision.document.FirebaseVisionDocumentText;
import com.google.firebase.ml.vision.document.FirebaseVisionDocumentTextRecognizer;
import com.google.firebase.ml.vision.text.RecognizedLanguage;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
                Map<String, Object> visionDocumentData = new HashMap<>();
                visionDocumentData.put("text", firebaseVisionDocumentText.getText());

                List<Map<String, Object>> allBlockData = new ArrayList<>();
                for (FirebaseVisionDocumentText.Block block :
                    firebaseVisionDocumentText.getBlocks()) {
                  Map<String, Object> blockData = new HashMap<>();
                  addData(
                      blockData,
                      block.getBoundingBox(),
                      block.getRecognizedBreak(),
                      block.getConfidence(),
                      block.getRecognizedLanguages(),
                      block.getText());

                  List<Map<String, Object>> allParagraphData = new ArrayList<>();
                  for (FirebaseVisionDocumentText.Paragraph paragraph : block.getParagraphs()) {
                    Map<String, Object> paragraphData = new HashMap<>();
                    addData(
                        paragraphData,
                        paragraph.getBoundingBox(),
                        paragraph.getRecognizedBreak(),
                        paragraph.getConfidence(),
                        paragraph.getRecognizedLanguages(),
                        paragraph.getText());

                    List<Map<String, Object>> allWordData = new ArrayList<>();
                    for (FirebaseVisionDocumentText.Word word : paragraph.getWords()) {
                      Map<String, Object> wordData = new HashMap<>();
                      addData(
                          wordData,
                          word.getBoundingBox(),
                          word.getRecognizedBreak(),
                          word.getConfidence(),
                          word.getRecognizedLanguages(),
                          word.getText());

                      List<Map<String, Object>> allSymbolData = new ArrayList<>();
                      for (FirebaseVisionDocumentText.Symbol symbol : word.getSymbols()) {
                        Map<String, Object> symbolData = new HashMap<>();
                        addData(
                            symbolData,
                            symbol.getBoundingBox(),
                            symbol.getRecognizedBreak(),
                            symbol.getConfidence(),
                            symbol.getRecognizedLanguages(),
                            symbol.getText());

                        allSymbolData.add(symbolData);
                      }

                      wordData.put("symbols", allSymbolData);
                      allWordData.add(wordData);
                    }

                    paragraphData.put("words", allWordData);
                    allParagraphData.add(paragraphData);
                  }

                  blockData.put("paragraphs", allParagraphData);
                  allBlockData.add(blockData);
                }

                visionDocumentData.put("blocks", allBlockData);
                result.success(visionDocumentData);
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

  private void addData(
      Map<String, Object> addTo,
      Rect boundingBox,
      FirebaseVisionDocumentText.RecognizedBreak recognizedBreak,
      Float confidence,
      List<RecognizedLanguage> languages,
      String text) {

    if (boundingBox != null) {
      addTo.put("left", boundingBox.left);
      addTo.put("top", boundingBox.top);
      addTo.put("width", boundingBox.width());
      addTo.put("height", boundingBox.height());
    }

    Map<String, Object> breakData = new HashMap<>();
    breakData.put("isPrefix", recognizedBreak.getIsPrefix());

    String detectedBreakType;
    int breakType = recognizedBreak.getDetectedBreakType();
    switch (breakType) {
      case FirebaseVisionDocumentText.RecognizedBreak.UNKNOWN:
        detectedBreakType = "unknown";
        break;
      case FirebaseVisionDocumentText.RecognizedBreak.SPACE:
        detectedBreakType = "space";
        break;
      case FirebaseVisionDocumentText.RecognizedBreak.SURE_SPACE:
        detectedBreakType = "sureSpace";
        break;
      case FirebaseVisionDocumentText.RecognizedBreak.EOL_SURE_SPACE:
        detectedBreakType = "eolSureSpace";
        break;
      case FirebaseVisionDocumentText.RecognizedBreak.HYPHEN:
        detectedBreakType = "hyphen";
        break;
      case FirebaseVisionDocumentText.RecognizedBreak.LINE_BREAK:
        detectedBreakType = "lineBreak";
        break;
      default:
        /// TODO(bmparr): Throw platform exception instead to avoid crashing app.
        throw new IllegalArgumentException(
            String.format("No support for recognized break type: %s", breakType));
    }
    breakData.put("detectedBreakType", detectedBreakType);
    addTo.put("recognizedBreak", breakData);

    addTo.put("confidence", confidence == null ? null : (double) confidence);

    List<Map<String, Object>> allLanguageData = new ArrayList<>();
    for (RecognizedLanguage language : languages) {
      Map<String, Object> languageData = new HashMap<>();
      languageData.put("languageCode", language.getLanguageCode());
      allLanguageData.add(languageData);
    }
    addTo.put("recognizedLanguages", allLanguageData);

    addTo.put("text", text);
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
