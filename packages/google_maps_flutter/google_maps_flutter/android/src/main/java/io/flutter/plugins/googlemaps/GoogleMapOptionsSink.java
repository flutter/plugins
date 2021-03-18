// Copyright 2018 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLngBounds;
import java.util.List;
import java.util.Map;

/** Receiver of GoogleMap configuration options. */
interface GoogleMapOptionsSink {
  void setCameraTargetBounds(LatLngBounds bounds);

  void setCompassEnabled(boolean compassEnabled);

  void setMapToolbarEnabled(boolean setMapToolbarEnabled);

  void setMapType(int mapType);

  void setMinMaxZoomPreference(Float min, Float max);

  void setPadding(float top, float left, float bottom, float right);

  void setRotateGesturesEnabled(boolean rotateGesturesEnabled);

  void setScrollGesturesEnabled(boolean scrollGesturesEnabled);

  void setTiltGesturesEnabled(boolean tiltGesturesEnabled);

  void setTrackCameraPosition(boolean trackCameraPosition);

  void setZoomGesturesEnabled(boolean zoomGesturesEnabled);

  void setLiteModeEnabled(boolean liteModeEnabled);

  void setMyLocationEnabled(boolean myLocationEnabled);

  void setZoomControlsEnabled(boolean zoomControlsEnabled);

  void setMyLocationButtonEnabled(boolean myLocationButtonEnabled);

  void setIndoorEnabled(boolean indoorEnabled);

  void setTrafficEnabled(boolean trafficEnabled);

  void setBuildingsEnabled(boolean buildingsEnabled);

  void setInitialMarkers(Object initialMarkers);

  void setInitialPolygons(Object initialPolygons);

  void setInitialPolylines(Object initialPolylines);

  void setInitialCircles(Object initialCircles);

  void setInitialTileOverlays(List<Map<String, ?>> initialTileOverlays);
}
