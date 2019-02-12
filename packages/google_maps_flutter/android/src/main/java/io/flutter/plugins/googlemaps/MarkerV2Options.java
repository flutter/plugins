package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import java.util.Map;

public class MarkerV2Options {

  private final String markerId;
  private final double alpha;
  private final LatLng position;

  public MarkerV2Options(double alpha, LatLng position, String markerId) {
    this.alpha = alpha;
    this.position = position;
    this.markerId = markerId;
  }

  public String getMarkerId() {
    return markerId;
  }

  public double getAlpha() {
    return alpha;
  }

  public LatLng getPosition() {
    return position;
  }

  public static MarkerV2Options from(Object o) {
    if (o == null) {
      return null;
    }
    if (o instanceof Map) {
      Map m = (Map<String, Object>) o;
      if (!m.containsKey("position") || !m.containsKey("markerId")) {
        return null;
      }
      String key = (String) m.get("markerId");
      LatLng position = Convert.toLatLng(m.get("position"));
      double alpha = 1.0;
      if (m.containsKey("alpha")) {
        alpha = (double) m.get("alpha");
      }
      return new MarkerV2Options(alpha, position, key);
    }

    return null;
  }
}
