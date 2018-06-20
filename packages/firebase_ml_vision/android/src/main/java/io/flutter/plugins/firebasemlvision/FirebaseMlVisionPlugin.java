package io.flutter.plugins.firebasemlvision;

import android.graphics.Point;
import android.graphics.Rect;
import android.net.Uri;
import android.support.annotation.NonNull;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.text.FirebaseVisionText;
import com.google.firebase.ml.vision.text.FirebaseVisionTextDetector;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** FirebaseMlVisionPlugin */
public class FirebaseMlVisionPlugin implements MethodCallHandler {
  private Registrar registrar;

  private FirebaseMlVisionPlugin(Registrar registrar) {
    this.registrar = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        new MethodChannel(registrar.messenger(), "plugins.flutter.io/firebase_ml_vision");
    channel.setMethodCallHandler(new FirebaseMlVisionPlugin(registrar));
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("TextDetector#detectInImage")) {
      handleTextDetectionResult(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void handleTextDetectionResult(MethodCall call, final Result result) {
    File file = new File((String) call.arguments);

    FirebaseVisionImage image;
    try {
      image = FirebaseVisionImage.fromFilePath(registrar.context(), Uri.fromFile(file));
    } catch (IOException exception) {
      result.error("textDetectorError", exception.getLocalizedMessage(), null);
      return;
    }

    FirebaseVisionTextDetector detector = FirebaseVision.getInstance().getVisionTextDetector();
    detector
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
              public void onFailure(@NonNull Exception e) {
                result.error("textDetectorError", e.getLocalizedMessage(), null);
              }
            });
  }

  private void addTextData(
      Map<String, Object> addTo, Rect boundingBox, Point[] cornerPoints, String text) {
    addTo.put("text", text);

    addTo.put("left", boundingBox.left);
    addTo.put("top", boundingBox.top);
    addTo.put("width", boundingBox.width());
    addTo.put("height", boundingBox.height());

    List<int[]> points = new ArrayList<>();
    for (Point point : cornerPoints) {
      points.add(new int[] {point.x, point.y});
    }
    addTo.put("points", points);
  }
}
