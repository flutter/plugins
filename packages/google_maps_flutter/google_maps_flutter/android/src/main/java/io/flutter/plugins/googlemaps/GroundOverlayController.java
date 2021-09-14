package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.GroundOverlayOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import java.util.HashMap;
import java.util.Map;

public class GroundOverlayController implements GroundOverlaySink {
  private final GroundOverlay groundOverlay;

  public GroundOverlayController(GroundOverlay groundOverlay) {
    this.groundOverlay = groundOverlay;
  }

  public void remove() {
    groundOverlay.remove();
  }

  @Override
  public void setAnchor(float u, float v) {
    // You can not change anchor after creation
  }

  @Override
  public void setBearing(float bearing) {
    groundOverlay.setBearing(bearing);
  }

  @Override
  public void setClickable(boolean isClickable) {
    groundOverlay.setClickable(isClickable);
  }

  @Override
  public void setImage(BitmapDescriptor image) {
    groundOverlay.setImage(image);
  }

  @Override
  public void setPosition(LatLng location, float width) {
    groundOverlay.setPosition(location);
  }

  @Override
  public void setPosition(LatLng location, float width, float height) {
    groundOverlay.setPosition(location);
  }

  @Override
  public void setPositionFromBounds(LatLngBounds bounds) {
    groundOverlay.setPositionFromBounds(bounds);
  }

  @Override
  public void setTransparency(float transparency) {
    groundOverlay.setTransparency(transparency);
  }

  @Override
  public void setVisible(boolean isVisible) {
    groundOverlay.setVisible(isVisible);
  }

  @Override
  public void setZIndex(float zIndex) {
    groundOverlay.setZIndex(zIndex);
  }
}
