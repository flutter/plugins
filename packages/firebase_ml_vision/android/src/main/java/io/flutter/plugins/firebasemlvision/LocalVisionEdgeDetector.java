package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.common.FirebaseMLException;
import com.google.firebase.ml.common.modeldownload.FirebaseLocalModel;
import com.google.firebase.ml.common.modeldownload.FirebaseModelManager;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabel;
import com.google.firebase.ml.vision.label.FirebaseVisionImageLabeler;
import com.google.firebase.ml.vision.label.FirebaseVisionOnDeviceAutoMLImageLabelerOptions;

import io.flutter.plugin.common.MethodChannel;

class LocalVisionEdgeDetector implements Detector{
    static final LocalVisionEdgeDetector instance = new LocalVisionEdgeDetector();

    private LocalVisionEdgeDetector() {}

    private FirebaseVisionImageLabeler labeler;
    private Map<String, Object> lastOptions;

    @Override
    public void handleDetection(
            FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {

        // Use instantiated labeler if the options are the same. Otherwise, close and instantiate new
        // options.

        if (labeler != null && !options.equals(lastOptions)) {
            try {
                labeler.close();
            } catch (IOException e) {
                result.error("visionEdgeLabelDetectorIOError", e.getLocalizedMessage(), null);
                return;
            }

            labeler = null;
            lastOptions = null;
        }

        if (labeler == null) {
            lastOptions = options;
            String finalPath = "flutter_assets/assets/"+options.get("dataset")+"/manifest.json";
            FirebaseLocalModel localModel = FirebaseModelManager.getInstance().getLocalModel((String) options.get("dataset"));
            if (localModel == null){
                localModel = new FirebaseLocalModel.Builder((String) options.get("dataset"))
                        .setAssetFilePath(finalPath)
                        .build();
                FirebaseModelManager.getInstance().registerLocalModel(localModel);
                try {
                    labeler = FirebaseVision.getInstance().getOnDeviceAutoMLImageLabeler(parseOptions(options));
                } catch (FirebaseMLException e) {
                    result.error("visionEdgeLabelDetectorLabelerError", e.getLocalizedMessage(), null);
                    return;
                }
            }
        }

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

    private FirebaseVisionOnDeviceAutoMLImageLabelerOptions parseOptions(Map<String, Object> optionsData) {
        float conf = (float) (double) optionsData.get("confidenceThreshold");
        return new FirebaseVisionOnDeviceAutoMLImageLabelerOptions.Builder()
                .setLocalModelName((String) optionsData.get("dataset"))
                .setConfidenceThreshold(conf)
                .build();
    }

}