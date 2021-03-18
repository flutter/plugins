// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.PolylineOptions;
import java.util.List;

class PolylineBuilder implements PolylineOptionsSink {
  private final PolylineOptions polylineOptions;
  private boolean consumeTapEvents;
  private final float density;

  PolylineBuilder(float density) {
    this.polylineOptions = new PolylineOptions();
    this.density = density;
  }

  PolylineOptions build() {
    return polylineOptions;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
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
  public void setJointType(int jointType) {
    polylineOptions.jointType(jointType);
  }

  @Override
  public void setPattern(List<PatternItem> pattern) {
    polylineOptions.pattern(pattern);
  }

  @Override
  public void setPoints(List<LatLng> points) {
    polylineOptions.addAll(points);
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
    polylineOptions.clickable(consumeTapEvents);
  }

  @Override
  public void setGeodesic(boolean geodisc) {
    polylineOptions.geodesic(geodisc);
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
    polylineOptions.width(width * density);
  }

  @Override
  public void setZIndex(float zIndex) {
    polylineOptions.zIndex(zIndex);
  }
}
