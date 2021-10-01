package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;

/**
 * Receiver of GroundOverlayOptions configuration.
 */
public interface GroundOverlaySink {

  void setAnchor(float u, float v);

  void setBearing(float bearing);

  void setClickable(boolean isClickable);

  void setImage(BitmapDescriptor image);

  void setPosition(LatLng location, float width);

  void setPosition(LatLng location, float width, float height);

  void setPositionFromBounds(LatLngBounds bounds);

  void setTransparency(float transparency);

  void setVisible(boolean isVisible);

  void setZIndex(float zIndex);
}
