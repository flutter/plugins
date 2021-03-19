// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.CircleOptions;
import com.google.android.gms.maps.model.LatLng;

class CircleBuilder implements CircleOptionsSink {
  private final CircleOptions circleOptions;
  private final float density;
  private boolean consumeTapEvents;

  CircleBuilder(float density) {
    this.circleOptions = new CircleOptions();
    this.density = density;
  }

  CircleOptions build() {
    return circleOptions;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }

  @Override
  public void setFillColor(int color) {
    circleOptions.fillColor(color);
  }

  @Override
  public void setStrokeColor(int color) {
    circleOptions.strokeColor(color);
  }

  @Override
  public void setCenter(LatLng center) {
    circleOptions.center(center);
  }

  @Override
  public void setRadius(double radius) {
    circleOptions.radius(radius);
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
    circleOptions.clickable(consumeTapEvents);
  }

  @Override
  public void setVisible(boolean visible) {
    circleOptions.visible(visible);
  }

  @Override
  public void setStrokeWidth(float strokeWidth) {
    circleOptions.strokeWidth(strokeWidth * density);
  }

  @Override
  public void setZIndex(float zIndex) {
    circleOptions.zIndex(zIndex);
  }
}
