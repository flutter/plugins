package io.flutter.plugins.firebasemlvision;

import android.graphics.Point;
import android.graphics.Rect;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.text.FirebaseVisionText;
import com.google.firebase.ml.vision.text.FirebaseVisionTextDetector;
import io.flutter.plugin.common.MethodChannel;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TextDetector implements Detector {
  public static final TextDetector instance = new TextDetector();
  private static FirebaseVisionTextDetector textDetector;

  private TextDetector() {}

  @Override
  public void handleDetection(
      FirebaseVisionImage image, Map<String, Object> options, final MethodChannel.Result result) {
    if (textDetector == null) textDetector = FirebaseVision.getInstance().getVisionTextDetector();
    textDetector
        .detectInImage(image)
        .addOnSuccessListener(
            new OnSuccessListener<FirebaseVisionText>() {
              @Override
              public void onSuccess(FirebaseVisionText firebaseVisionText) {
                List<Map<String, Object>> blocks = new ArrayList<>();
                for (FirebaseVisionText.Block block : firebaseVisionText.getBlocks()) {
                  Map<String, Object> blockData = new HashMap<>();
                  addTextData(
                      blockData, block.getBoundingBox(), block.getCornerPoints(), block.getText());

                  List<Map<String, Object>> lines = new ArrayList<>();
                  for (FirebaseVisionText.Line line : block.getLines()) {
                    Map<String, Object> lineData = new HashMap<>();
                    addTextData(
                        lineData, line.getBoundingBox(), line.getCornerPoints(), line.getText());

                    List<Map<String, Object>> elements = new ArrayList<>();
                    for (FirebaseVisionText.Element element : line.getElements()) {
                      Map<String, Object> elementData = new HashMap<>();
                      addTextData(
                          elementData,
                          element.getBoundingBox(),
                          element.getCornerPoints(),
                          element.getText());
                      elements.add(elementData);
                    }
                    lineData.put("elements", elements);
                    lines.add(lineData);
                  }
                  blockData.put("lines", lines);
                  blocks.add(blockData);
                }
                result.success(blocks);
              }
            })
        .addOnFailureListener(
            new OnFailureListener() {
              @Override
              public void onFailure(@NonNull Exception exception) {
                result.error("textDetectorError", exception.getLocalizedMessage(), null);
              }
            });
  }

  private void addTextData(
      Map<String, Object> addTo, Rect boundingBox, Point[] cornerPoints, String text) {
    addTo.put("text", text);

    if (boundingBox != null) {
      addTo.put("left", boundingBox.left);
      addTo.put("top", boundingBox.top);
      addTo.put("width", boundingBox.width());
      addTo.put("height", boundingBox.height());
    }

    List<int[]> points = new ArrayList<>();
    if (cornerPoints != null) {
      for (Point point : cornerPoints) {
        points.add(new int[] {point.x, point.y});
      }
    }
    addTo.put("points", points);
  }
}
