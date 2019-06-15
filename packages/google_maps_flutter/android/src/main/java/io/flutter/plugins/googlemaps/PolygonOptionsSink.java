package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import java.util.List;

/** Receiver of Polygon configuration options. */
interface PolygonOptionsSink {

  void setConsumeTapEvents(boolean consumetapEvents);

  void setFillColor(int color);

  void setStrokeColor(int color);

  void setGeodesic(boolean geodesic);

  void setPoints(List<LatLng> points);

  void setVisible(boolean visible);

  void setStrokeWidth(float width);

  void setZIndex(float zIndex);
}
