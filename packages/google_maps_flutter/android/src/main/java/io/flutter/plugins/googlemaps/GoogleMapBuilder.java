// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLngBounds;
import io.flutter.plugin.common.PluginRegistry;
import java.util.concurrent.atomic.AtomicInteger;

class GoogleMapBuilder implements GoogleMapOptionsSink {
  private final GoogleMapOptions options = new GoogleMapOptions();
  private boolean trackCameraPosition = false;
  private boolean myLocationEnabled = false;

  GoogleMapController build(
      int id, Context context, AtomicInteger state, PluginRegistry.Registrar registrar) {
    final GoogleMapController controller =
        new GoogleMapController(id, context, state, registrar, options);
    controller.init();
    controller.setMyLocationEnabled(myLocationEnabled);
    controller.setTrackCameraPosition(trackCameraPosition);
    return controller;
  }

  @Override
  public void setCameraPosition(CameraPosition position) {
    options.camera(position);
  }

  @Override
  public void setCompassEnabled(boolean compassEnabled) {
    options.compassEnabled(compassEnabled);
  }

  @Override
  public void setCameraTargetBounds(LatLngBounds bounds) {
    options.latLngBoundsForCameraTarget(bounds);
  }

  @Override
  public void setMapType(int mapType) {
    options.mapType(mapType);
  }

  @Override
  public void setMinMaxZoomPreference(Float min, Float max) {
    if (min != null) {
      options.minZoomPreference(min);
    }
    if (max != null) {
      options.maxZoomPreference(max);
    }
  }

  @Override
  public void setTrackCameraPosition(boolean trackCameraPosition) {
    this.trackCameraPosition = trackCameraPosition;
  }

  @Override
  public void setRotateGesturesEnabled(boolean rotateGesturesEnabled) {
    options.rotateGesturesEnabled(rotateGesturesEnabled);
  }

  @Override
  public void setScrollGesturesEnabled(boolean scrollGesturesEnabled) {
    options.scrollGesturesEnabled(scrollGesturesEnabled);
  }

  @Override
  public void setTiltGesturesEnabled(boolean tiltGesturesEnabled) {
    options.tiltGesturesEnabled(tiltGesturesEnabled);
  }

  @Override
  public void setZoomGesturesEnabled(boolean zoomGesturesEnabled) {
    options.zoomGesturesEnabled(zoomGesturesEnabled);
  }

  @Override
  public void setMyLocationEnabled(boolean myLocationEnabled) {
    this.myLocationEnabled = myLocationEnabled;
  }
}
