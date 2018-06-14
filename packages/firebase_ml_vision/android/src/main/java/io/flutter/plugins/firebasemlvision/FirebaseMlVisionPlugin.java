package io.flutter.plugins.firebasemlvision;

import android.graphics.Point;
import android.graphics.Rect;
import android.net.Uri;
import android.support.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.ml.vision.FirebaseVision;
import com.google.firebase.ml.vision.common.FirebaseVisionImage;
import com.google.firebase.ml.vision.text.FirebaseVisionText;
import com.google.firebase.ml.vision.text.FirebaseVisionTextDetector;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

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
    Uri file = Uri.parse((String) call.arguments);

    FirebaseVisionImage image;
    try {
      image = FirebaseVisionImage.fromFilePath(registrar.context(), file);
    } catch (IOException exception) {
      result.error("TextDetector#detectInImage", exception.getLocalizedMessage(), null);
      return;
    }

    FirebaseVisionTextDetector detector = FirebaseVision.getInstance().getVisionTextDetector();
    detector.detectInImage(image).addOnSuccessListener(new OnSuccessListener<FirebaseVisionText>() {
      @Override
      public void onSuccess(FirebaseVisionText firebaseVisionText) {
        List<Map<String, Object>> blocks = new ArrayList<>();
        for (FirebaseVisionText.Block block : firebaseVisionText.getBlocks()) {
          Map<String, Object> blockData = new HashMap<>();

          blockData.put("left", block.getBoundingBox().left);
          blockData.put("top", block.getBoundingBox().top);
          blockData.put("width", block.getBoundingBox().width());
          blockData.put("height", block.getBoundingBox().height());
          blockData.put("text", block.getText());

          List<int[]> blockPoints = new ArrayList<>();
          for (Point point : block.getCornerPoints()) {
            blockPoints.add(new int[]{point.x, point.y});
          }
          blockData.put("points", blockPoints);

          List<Map<String, Object>> lines = new ArrayList<>();
          for (FirebaseVisionText.Line line : block.getLines()) {

            List<Map<String, Object>> elements = new ArrayList<>();
            for (FirebaseVisionText.Element element : line.getElements()) {

            }
          }
        }
      }
    }).addOnFailureListener(new OnFailureListener() {
      @Override
      public void onFailure(@NonNull Exception e) {
        result.error("TextDetector#detectInImage", e.getLocalizedMessage(), null);
      }
    });
  }
}
