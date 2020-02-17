// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Polygon;
import java.util.List;

/** Controller of a single Polygon on the map. */
class PolygonController implements PolygonOptionsSink {
  private final Polygon polygon;
  private final String googleMapsPolygonId;
  private final float density;
  private boolean consumeTapEvents;

  PolygonController(Polygon polygon, boolean consumeTapEvents, float density) {
    this.polygon = polygon;
    this.density = density;
    this.consumeTapEvents = consumeTapEvents;
    this.googleMapsPolygonId = polygon.getId();
  }

  void remove() {
    polygon.remove();
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
    polygon.setClickable(consumeTapEvents);
  }

  @Override
  public void setFillColor(int color) {
    polygon.setFillColor(color);
  }

  @Override
  public void setStrokeColor(int color) {
    polygon.setStrokeColor(color);
  }

  @Override
  public void setGeodesic(boolean geodesic) {
    polygon.setGeodesic(geodesic);
  }

  @Override
  public void setPoints(List<LatLng> points) {
    polygon.setPoints(points);
  }

  public void setHoles(List<List<LatLng>> holes) {
    polygon.setHoles(holes);
  }

  @Override
  public void setVisible(boolean visible) {
    polygon.setVisible(visible);
  }

  @Override
  public void setStrokeWidth(float width) {
    polygon.setStrokeWidth(width * density);
  }

  @Override
  public void setZIndex(float zIndex) {
    polygon.setZIndex(zIndex);
  }

  String getGoogleMapsPolygonId() {
    return googleMapsPolygonId;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }
}
