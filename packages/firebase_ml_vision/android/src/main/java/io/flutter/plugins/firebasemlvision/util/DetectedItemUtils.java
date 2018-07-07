package io.flutter.plugins.firebasemlvision.util;

import android.graphics.Rect;

import java.util.HashMap;
import java.util.Map;
import static io.flutter.plugins.firebasemlvision.constants.VisionBaseConstants.*;

public class DetectedItemUtils {

  public static Map<String, Object> rectToFlutterMap(Rect boundingBox) {
    Map<String, Object> out = new HashMap<>();
    out.put(LEFT, boundingBox.left);
    out.put(TOP, boundingBox.top);
    out.put(WIDTH, boundingBox.width());
    out.put(HEIGHT, boundingBox.height());
    return out;
  }

}
