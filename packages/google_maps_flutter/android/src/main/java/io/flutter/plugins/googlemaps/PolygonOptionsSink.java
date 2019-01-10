package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import java.util.List;

/** Receiver of Polygon configuration options. */
public interface PolygonOptionsSink {
  void setPoints(List<LatLng> points);

  void setHoles(List<? extends List<LatLng>> holes);

  void setPattern(List<PatternItem> pattern);

  void setStrokeWidth(float strokeWidth);

  void setStrokeColor(int strokeColor);

  void setStrokeJointType(int strokeJointType);

  void setFillColor(int fillColor);

  void setZIndex(float zIndex);

  void setVisible(boolean visible);

  void setGeodesic(boolean geodesic);

  void setClickable(boolean clickable);
}
