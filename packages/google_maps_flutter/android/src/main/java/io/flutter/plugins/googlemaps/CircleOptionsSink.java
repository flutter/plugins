package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import java.util.List;

/** Receiver of Circle configuration options. */
interface CircleOptionsSink {

  void setConsumeTapEvents(boolean consumetapEvents);

  void setCenter(LatLng center);

  void setRadius(int radius);

  void setStrokeColor(int strokeColor);

  void setStrokeWidth(int strokeWidth);

  void setFillColor(int fillColor);

  void setPattern(List<PatternItem> pattern);

  void setVisible(boolean visible);

  void setZIndex(float zIndex);
}
