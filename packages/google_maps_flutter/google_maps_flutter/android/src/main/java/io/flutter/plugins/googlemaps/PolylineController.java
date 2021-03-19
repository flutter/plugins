// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.Polyline;
import java.util.List;

/** Controller of a single Polyline on the map. */
class PolylineController implements PolylineOptionsSink {
  private final Polyline polyline;
  private final String googleMapsPolylineId;
  private boolean consumeTapEvents;
  private final float density;

  PolylineController(Polyline polyline, boolean consumeTapEvents, float density) {
    this.polyline = polyline;
    this.consumeTapEvents = consumeTapEvents;
    this.density = density;
    this.googleMapsPolylineId = polyline.getId();
  }

  void remove() {
    polyline.remove();
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
    polyline.setClickable(consumeTapEvents);
  }

  @Override
  public void setColor(int color) {
    polyline.setColor(color);
  }

  @Override
  public void setEndCap(Cap endCap) {
    polyline.setEndCap(endCap);
  }

  @Override
  public void setGeodesic(boolean geodesic) {
    polyline.setGeodesic(geodesic);
  }

  @Override
  public void setJointType(int jointType) {
    polyline.setJointType(jointType);
  }

  @Override
  public void setPattern(List<PatternItem> pattern) {
    polyline.setPattern(pattern);
  }

  @Override
  public void setPoints(List<LatLng> points) {
    polyline.setPoints(points);
  }

  @Override
  public void setStartCap(Cap startCap) {
    polyline.setStartCap(startCap);
  }

  @Override
  public void setVisible(boolean visible) {
    polyline.setVisible(visible);
  }

  @Override
  public void setWidth(float width) {
    polyline.setWidth(width * density);
  }

  @Override
  public void setZIndex(float zIndex) {
    polyline.setZIndex(zIndex);
  }

  String getGoogleMapsPolylineId() {
    return googleMapsPolylineId;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }
}
