// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebasemlvision;

import androidx.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.common.FirebaseVisionPoint;
import com.google.firebase.ml.vision.face.FirebaseVisionFace;
import com.google.firebase.ml.vision.face.FirebaseVisionFaceContour;
import com.google.firebase.ml.vision.face.FirebaseVisionFaceDetector;
import com.google.firebase.ml.vision.face.FirebaseVisionFaceDetectorOptions;
import com.google.firebase.ml.vision.face.FirebaseVisionFaceLandmark;
import io.flutter.plugin.common.MethodChannel;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class FaceDetector implements Detector {
  private final FirebaseVisionFaceDetector detector;

  FaceDetector(FirebaseVision vision, Map<String, Object> options) {
    detector = vision.getVisionFaceDetector(parseOptions(options));
  }

  @Override
  public void handleDetection(final FirebaseVisionImage image, final MethodChannel.Result result) {
    detector
        .detectInImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<List<FirebaseVisionFace>>() {
              @Override
              public void onSuccess(List<FirebaseVisionFace> firebaseVisionFaces) {
                List<Map<String, Object>> faces = new ArrayList<>(firebaseVisionFaces.size());
                for (FirebaseVisionFace face : firebaseVisionFaces) {
                  Map<String, Object> faceData = new HashMap<>();

                  faceData.put("left", (double) face.getBoundingBox().left);
                  faceData.put("top", (double) face.getBoundingBox().top);
                  faceData.put("width", (double) face.getBoundingBox().width());
                  faceData.put("height", (double) face.getBoundingBox().height());

                  faceData.put("headEulerAngleY", face.getHeadEulerAngleY());
                  faceData.put("headEulerAngleZ", face.getHeadEulerAngleZ());

                  if (face.getSmilingProbability() != FirebaseVisionFace.UNCOMPUTED_PROBABILITY) {
                    faceData.put("smilingProbability", face.getSmilingProbability());
                  }

                  if (face.getLeftEyeOpenProbability()
                      != FirebaseVisionFace.UNCOMPUTED_PROBABILITY) {
                    faceData.put("leftEyeOpenProbability", face.getLeftEyeOpenProbability());
                  }

                  if (face.getRightEyeOpenProbability()
                      != FirebaseVisionFace.UNCOMPUTED_PROBABILITY) {
                    faceData.put("rightEyeOpenProbability", face.getRightEyeOpenProbability());
                  }

                  if (face.getTrackingId() != FirebaseVisionFace.INVALID_ID) {
                    faceData.put("trackingId", face.getTrackingId());
                  }

                  faceData.put("landmarks", getLandmarkData(face));

                  faceData.put("contours", getContourData(face));

                  faces.add(faceData);
                }

                result.success(faces);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                result.error("faceDetectorError", exception.getLocalizedMessage(), null);
              }
            });
  }

  private Map<String, double[]> getLandmarkData(FirebaseVisionFace face) {
    Map<String, double[]> landmarks = new HashMap<>();

    landmarks.put("bottomMouth", landmarkPosition(face, FirebaseVisionFaceLandmark.MOUTH_BOTTOM));
    landmarks.put("leftCheek", landmarkPosition(face, FirebaseVisionFaceLandmark.LEFT_CHEEK));
    landmarks.put("leftEar", landmarkPosition(face, FirebaseVisionFaceLandmark.LEFT_EAR));
    landmarks.put("leftEye", landmarkPosition(face, FirebaseVisionFaceLandmark.LEFT_EYE));
    landmarks.put("leftMouth", landmarkPosition(face, FirebaseVisionFaceLandmark.MOUTH_LEFT));
    landmarks.put("noseBase", landmarkPosition(face, FirebaseVisionFaceLandmark.NOSE_BASE));
    landmarks.put("rightCheek", landmarkPosition(face, FirebaseVisionFaceLandmark.RIGHT_CHEEK));
    landmarks.put("rightEar", landmarkPosition(face, FirebaseVisionFaceLandmark.RIGHT_EAR));
    landmarks.put("rightEye", landmarkPosition(face, FirebaseVisionFaceLandmark.RIGHT_EYE));
    landmarks.put("rightMouth", landmarkPosition(face, FirebaseVisionFaceLandmark.MOUTH_RIGHT));

    return landmarks;
  }

  private Map<String, List<double[]>> getContourData(FirebaseVisionFace face) {
    Map<String, List<double[]>> contours = new HashMap<>();

    contours.put("allPoints", contourPosition(face, FirebaseVisionFaceContour.ALL_POINTS));
    contours.put("face", contourPosition(face, FirebaseVisionFaceContour.FACE));
    contours.put("leftEye", contourPosition(face, FirebaseVisionFaceContour.LEFT_EYE));
    contours.put(
        "leftEyebrowBottom", contourPosition(face, FirebaseVisionFaceContour.LEFT_EYEBROW_BOTTOM));
    contours.put(
        "leftEyebrowTop", contourPosition(face, FirebaseVisionFaceContour.LEFT_EYEBROW_TOP));
    contours.put(
        "lowerLipBottom", contourPosition(face, FirebaseVisionFaceContour.LOWER_LIP_BOTTOM));
    contours.put("lowerLipTop", contourPosition(face, FirebaseVisionFaceContour.LOWER_LIP_TOP));
    contours.put("noseBottom", contourPosition(face, FirebaseVisionFaceContour.NOSE_BOTTOM));
    contours.put("noseBridge", contourPosition(face, FirebaseVisionFaceContour.NOSE_BRIDGE));
    contours.put("rightEye", contourPosition(face, FirebaseVisionFaceContour.RIGHT_EYE));
    contours.put(
        "rightEyebrowBottom",
        contourPosition(face, FirebaseVisionFaceContour.RIGHT_EYEBROW_BOTTOM));
    contours.put(
        "rightEyebrowTop", contourPosition(face, FirebaseVisionFaceContour.RIGHT_EYEBROW_TOP));
    contours.put(
        "upperLipBottom", contourPosition(face, FirebaseVisionFaceContour.UPPER_LIP_BOTTOM));
    contours.put("upperLipTop", contourPosition(face, FirebaseVisionFaceContour.UPPER_LIP_TOP));

    return contours;
  }

  private double[] landmarkPosition(FirebaseVisionFace face, int landmarkInt) {
    FirebaseVisionFaceLandmark landmark = face.getLandmark(landmarkInt);
    if (landmark != null) {
      return new double[] {landmark.getPosition().getX(), landmark.getPosition().getY()};
    }

    return null;
  }

  private List<double[]> contourPosition(FirebaseVisionFace face, int contourInt) {
    FirebaseVisionFaceContour contour = face.getContour(contourInt);
    if (contour != null) {
      List<FirebaseVisionPoint> contourPoints = contour.getPoints();
      List<double[]> result = new ArrayList<double[]>();

      for (int i = 0; i < contourPoints.size(); i++) {
        result.add(new double[] {contourPoints.get(i).getX(), contourPoints.get(i).getY()});
      }

      return result;
    }

    return null;
  }

  private FirebaseVisionFaceDetectorOptions parseOptions(Map<String, Object> options) {
    int classification =
        (boolean) options.get("enableClassification")
            ? FirebaseVisionFaceDetectorOptions.ALL_CLASSIFICATIONS
            : FirebaseVisionFaceDetectorOptions.NO_CLASSIFICATIONS;

    int landmark =
        (boolean) options.get("enableLandmarks")
            ? FirebaseVisionFaceDetectorOptions.ALL_LANDMARKS
            : FirebaseVisionFaceDetectorOptions.NO_LANDMARKS;

    int contours =
        (boolean) options.get("enableContours")
            ? FirebaseVisionFaceDetectorOptions.ALL_CONTOURS
            : FirebaseVisionFaceDetectorOptions.NO_CONTOURS;

    int mode;
    switch ((String) options.get("mode")) {
      case "accurate":
        mode = FirebaseVisionFaceDetectorOptions.ACCURATE;
        break;
      case "fast":
        mode = FirebaseVisionFaceDetectorOptions.FAST;
        break;
      default:
        throw new IllegalArgumentException("Not a mode:" + options.get("mode"));
    }

    FirebaseVisionFaceDetectorOptions.Builder builder =
        new FirebaseVisionFaceDetectorOptions.Builder()
            .setClassificationMode(classification)
            .setLandmarkMode(landmark)
            .setContourMode(contours)
            .setMinFaceSize((float) ((double) options.get("minFaceSize")))
            .setPerformanceMode(mode);

    if ((boolean) options.get("enableTracking")) {
      builder.enableTracking();
    }

    return builder.build();
  }

  @Override
  public void close() throws IOException {
    detector.close();
  }
}
