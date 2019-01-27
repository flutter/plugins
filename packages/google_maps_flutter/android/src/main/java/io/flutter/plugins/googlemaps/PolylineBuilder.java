/*
Copyright 2018 The Chromium Authors. All rights reserved.
Use of this source code is governed by a BSD-style license that can be
found in the LICENSE file.
*/

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;
import java.util.List;

class PolylineBuilder implements PolylineOptionsSink {
  private final GoogleMapController mapController;
  private final PolylineOptions polylineOptions;
  private boolean consumesTapEvents;

  PolylineBuilder(GoogleMapController mapController) {
    this.mapController = mapController;
    this.polylineOptions = new PolylineOptions();
  }

  String build() {
    final Polyline polyline = mapController.addPolyline(polylineOptions, consumesTapEvents);
    return polyline.getId();
  }

  @Override
  public void setConsumeTapEvents(boolean consumesTapEvents) {
    this.consumesTapEvents = consumesTapEvents;
  }

  @Override
  public void setPoints(List<LatLng> points) {
    polylineOptions.addAll(points);
  }

  @Override
  public void setClickable(boolean clickable) {
    polylineOptions.clickable(clickable);
  }

  @Override
  public void setColor(int color) {
    polylineOptions.color(color);
  }

  @Override
  public void setEndCap(Cap endCap) {
    polylineOptions.endCap(endCap);
  }

  @Override
  public void setGeodesic(boolean geodesic) {
    polylineOptions.geodesic(geodesic);
  }

  @Override
  public void setJointType(int jointType) {
    polylineOptions.jointType(jointType);
  }

  @Override
  public void setPattern(List<PatternItem> pattern) {
    polylineOptions.pattern(pattern);
  }

  @Override
  public void setStartCap(Cap startCap) {
    polylineOptions.startCap(startCap);
  }

  @Override
  public void setVisible(boolean visible) {
    polylineOptions.visible(visible);
  }

  @Override
  public void setWidth(float width) {
    polylineOptions.width(width);
  }

  public void setZIndex(float zIndex) {
    polylineOptions.zIndex(zIndex);
  }
}
