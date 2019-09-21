package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.TileProvider;

/** Receiver of TileOverlayOptions configuration. */
public interface TileOverlaySink {
  void setFadeIn(boolean fadeIn);

  void setTransparency(float transparency);

  void setZIndex(float zIndex);

  void setVisible(boolean visible);

  void setTileProvider(TileProvider tileProvider);
}
