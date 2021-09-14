package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.GroundOverlayOptions;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

public class GroundOverlayBuilder implements GroundOverlaySink {
  private final GroundOverlayOptions groundOverlayOptions;

  public GroundOverlayBuilder() {
    this.groundOverlayOptions = new GroundOverlayOptions();
  }

  public GroundOverlayOptions build() {
    return groundOverlayOptions;
  }

  @Override
  public void setAnchor(float u, float v) {
    groundOverlayOptions.anchor(u, v);
  }

  @Override
  public void setBearing(float bearing) {
    groundOverlayOptions.bearing(bearing);
  }

  @Override
  public void setClickable(boolean isClickable) {
    groundOverlayOptions.clickable(isClickable);
  }

  @Override
  public void setImage(BitmapDescriptor image) {
    groundOverlayOptions.image(image);
  }

  @Override
  public void setPosition(LatLng location, float width) {
    groundOverlayOptions.position(location, width);
  }

  @Override
  public void setPosition(LatLng location, float width, float height) {
    groundOverlayOptions.position(location, width, height);
  }

  @Override
  public void setPositionFromBounds(LatLngBounds bounds) {
    groundOverlayOptions.positionFromBounds(bounds);
  }

  @Override
  public void setTransparency(float transparency) {
    groundOverlayOptions.transparency(transparency);
  }

  @Override
  public void setVisible(boolean isVisible) {
    groundOverlayOptions.visible(isVisible);
  }

  @Override
  public void setZIndex(float zIndex) {
    groundOverlayOptions.zIndex(zIndex);
  }
}
