// Copyright 2019 The HKTaxiApp Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.LatLng;
import java.util.ArrayList;
import java.util.List;

/** Controller of a single Route on the map. */
class RouteController {

  private List<LatLng> route;
  private MarkerController markerController;

  RouteController(MarkerController markerController) {
    this.route = new ArrayList<LatLng>();
    this.markerController = markerController;
  }

  void remove() {
    this.markerController.remove();
  }

  void addPosition(LatLng position) {
    this.route.add(position);
  }

  void clearPosition() {
    this.route.clear();
  }

  List<LatLng> getRoute() {
    return this.route;
  }

  MarkerController getMarkerController() {
    return this.markerController;
  }
}
