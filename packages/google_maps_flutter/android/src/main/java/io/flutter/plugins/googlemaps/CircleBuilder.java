package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.Circle;
import com.google.android.gms.maps.model.CircleOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import java.util.List;

class CircleBuilder implements CircleOptionsSink {
  private final GoogleMapController mapController;
  private final CircleOptions circleOptions;

  CircleBuilder(GoogleMapController mapController) {
    this.mapController = mapController;
    this.circleOptions = new CircleOptions();
  }

  String build() {
    final Circle circle = mapController.addCircle(circleOptions);
    return circle.getId();
  }

  @Override
  public void setPattern(List<PatternItem> pattern) {
    circleOptions.strokePattern(pattern);
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    circleOptions.clickable(consumeTapEvents);
  }

  @Override
  public void setCenter(LatLng center) {
    circleOptions.center(center);
  }

  @Override
  public void setRadius(int radius) {
    circleOptions.radius(radius);
  }

  @Override
  public void setStrokeColor(int strokeColor) {
    circleOptions.strokeColor(strokeColor);
  }

  @Override
  public void setStrokeWidth(int strokeWidth) {
    circleOptions.strokeWidth(strokeWidth);
  }

  @Override
  public void setFillColor(int fillColor) {
    circleOptions.fillColor(fillColor);
  }

  @Override
  public void setVisible(boolean visible) {
    circleOptions.visible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    circleOptions.zIndex(zIndex);
  }
}
