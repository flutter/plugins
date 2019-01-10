package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.Polygon;
import com.google.android.gms.maps.model.PolygonOptions;
import java.util.List;

public class PolygonBuilder implements PolygonOptionsSink {
  private final GoogleMapController mapController;
  private final PolygonOptions polygonOptions;

  public PolygonBuilder(GoogleMapController mapController) {
    this.mapController = mapController;
    this.polygonOptions = new PolygonOptions();
  }

  String build() {
    final Polygon polygon = mapController.addPolygon(polygonOptions);
    return polygon.getId();
  }

  @Override
  public void setPoints(List<LatLng> points) {
    polygonOptions.addAll(points);
  }

  @Override
  public void setHoles(List<? extends List<LatLng>> holes) {
    for (List<LatLng> hole : holes) {
      polygonOptions.addHole(hole);
    }
  }

  @Override
  public void setPattern(List<PatternItem> pattern) {
    polygonOptions.strokePattern(pattern);
  }

  @Override
  public void setStrokeWidth(float strokeWidth) {
    polygonOptions.strokeWidth(strokeWidth);
  }

  @Override
  public void setStrokeColor(int strokeColor) {
    polygonOptions.strokeColor(strokeColor);
  }

  @Override
  public void setStrokeJointType(int strokeJointType) {
    polygonOptions.strokeJointType(strokeJointType);
  }

  @Override
  public void setFillColor(int fillColor) {
    polygonOptions.fillColor(fillColor);
  }

  @Override
  public void setZIndex(float zIndex) {
    polygonOptions.zIndex(zIndex);
  }

  @Override
  public void setVisible(boolean visible) {
    polygonOptions.visible(visible);
  }

  @Override
  public void setGeodesic(boolean geodesic) {
    polygonOptions.geodesic(geodesic);
  }

  @Override
  public void setClickable(boolean clickable) {
    polygonOptions.clickable(clickable);
  }
}
