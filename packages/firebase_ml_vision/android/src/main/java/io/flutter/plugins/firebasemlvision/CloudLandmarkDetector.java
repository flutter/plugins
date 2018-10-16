package io.flutter.plugins.firebasemlvision;

import android.graphics.Rect;
import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.cloud.FirebaseVisionCloudDetectorOptions;
import com.google.firebase.ml.vision.cloud.landmark.FirebaseVisionCloudLandmark;
import com.google.firebase.ml.vision.cloud.landmark.FirebaseVisionCloudLandmarkDetector;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionLatLng;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class CloudLandmarkDetector implements Detector {
  public static final CloudLandmarkDetector instance = new CloudLandmarkDetector();

  private CloudLandmarkDetector() {}

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {
    FirebaseVisionCloudDetectorOptions detectorOptions = FirebaseMlVisionPlugin.parseCloudDetectorOptions(options);
    FirebaseVisionCloudLandmarkDetector detector = FirebaseVision.getInstance().getVisionCloudLandmarkDetector(detectorOptions);

    detector
        .detectInImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionCloudLandmark>>() {
              @Override
              public void onSuccess(List<FirebaseVisionCloudLandmark> firebaseVisionCloudLandmarks) {
                List<Map<String, Object>> landmarks =
                    new ArrayList<>(firebaseVisionCloudLandmarks.size());

                for (FirebaseVisionCloudLandmark landmark : firebaseVisionCloudLandmarks) {
                  Map<String, Object> landmarkData = new HashMap<>();
                  landmarkData.put("confidence", (double) landmark.getConfidence());
                  landmarkData.put("entityId", landmark.getEntityId());
                  landmarkData.put("landmark", landmark.getLandmark());

                  Rect boundingBox = landmark.getBoundingBox();
                  if (boundingBox != null) {
                    landmarkData.put("left", boundingBox.left);
                    landmarkData.put("top", boundingBox.top);
                    landmarkData.put("width", boundingBox.width());
                    landmarkData.put("height", boundingBox.height());
                  }

                  List<Map<String, Object>> latLngs = new ArrayList<>(landmark.getLocations().size());
                  for (FirebaseVisionLatLng latLng : landmark.getLocations()) {
                    Map<String, Object> latLngData = new HashMap<>(2);
                    latLngData.put("latitude", latLng.getLatitude());
                    latLngData.put("longitude", latLng.getLongitude());

                    latLngs.add(latLngData);
                  }

                  landmarkData.put("locations", latLngs);

                  landmarks.add(landmarkData);
                }

                result.success(landmarks);
              }
            }
        )
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception e) {
                result.error("cloudLandmarkDetectorError", e.getLocalizedMessage(), null);
              }
            }
        );
  }
}
