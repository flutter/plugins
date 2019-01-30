package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.Circle;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import java.util.List;

/** Controller of a single Circle on the map. */
class CircleController implements CircleOptionsSink {
  private final Circle circle;
  private final OnCircleTappedListener onTappedListener;

  CircleController(Circle circle, OnCircleTappedListener onTappedListener) {
    this.circle = circle;
    this.onTappedListener = onTappedListener;
  }

  void onTap() {
    if (onTappedListener != null) {
      onTappedListener.onCircleTapped(circle);
    }
  }

  void remove() {
    circle.remove();
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    circle.setClickable(consumeTapEvents);
  }

  @Override
  public void setCenter(LatLng center) {
    circle.setCenter(center);
  }

  @Override
  public void setRadius(int radius) {
    circle.setRadius(radius);
  }

  @Override
  public void setStrokeColor(int strokeColor) {
    circle.setStrokeColor(strokeColor);
  }

  @Override
  public void setStrokeWidth(int strokeWidth) {
    circle.setStrokeWidth(strokeWidth);
  }

  @Override
  public void setFillColor(int fillColor) {
    circle.setFillColor(fillColor);
  }

  @Override
  public void setPattern(List<PatternItem> pattern) {
    circle.setStrokePattern(pattern);
  }

  @Override
  public void setVisible(boolean visible) {
    circle.setVisible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    circle.setZIndex(zIndex);
  }
}
