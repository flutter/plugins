// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLngBounds;

/** Receiver of GoogleMap configuration options. */
interface GoogleMapOptionsSink {
  void setCameraPosition(CameraPosition position);

  void setLatLngBoundsForCameraTarget(LatLngBounds bounds);

  void setCompassEnabled(boolean compassEnabled);

  void setMapType(int mapType);

  void setTrackCameraPosition(boolean reportCameraMoveEvents);

  void setRotateGesturesEnabled(boolean rotateGesturesEnabled);

  void setScrollGesturesEnabled(boolean scrollGesturesEnabled);

  void setTiltGesturesEnabled(boolean tiltGesturesEnabled);

  void setMinMaxZoomPreference(Float min, Float max);

  void setZoomGesturesEnabled(boolean zoomGesturesEnabled);
}
