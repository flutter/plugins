// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.maps.android.clustering.ClusterItem;

public class ClusterItemController implements ClusterItem {

  private final LatLng position;
  private final String title;
  private final String snippet;
  private final String googleMapsClusterItemId;
  private boolean consumeTapEvents;
  private final BitmapDescriptor bitmapDescriptor;

  public ClusterItemController(
      double lat,
      double lng,
      String clusterItemId,
      boolean consumeTapEvents,
      BitmapDescriptor bitmapDescriptor) {
    this.position = new LatLng(lat, lng);
    this.title = "";
    this.snippet = "";
    this.googleMapsClusterItemId = clusterItemId;
    this.consumeTapEvents = consumeTapEvents;
    this.bitmapDescriptor = bitmapDescriptor;
  }

  public ClusterItemController(
      double lat,
      double lng,
      String title,
      String snippet,
      String clusterItemId,
      boolean consumeTapEvents,
      BitmapDescriptor bitmapDescriptor) {
    this.position = new LatLng(lat, lng);
    this.title = title;
    this.snippet = snippet;
    this.googleMapsClusterItemId = clusterItemId;
    this.consumeTapEvents = consumeTapEvents;
    this.bitmapDescriptor = bitmapDescriptor;
  }

  @Override
  public LatLng getPosition() {
    return position;
  }

  @Override
  public String getTitle() {
    return title;
  }

  @Override
  public String getSnippet() {
    return snippet;
  }

  public String getGoogleMapsClusterItemId() {
    return googleMapsClusterItemId;
  }

  public boolean consumeTapEvents() {
    return consumeTapEvents;
  }

  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
  }

  public BitmapDescriptor getIcon() {
    return this.bitmapDescriptor;
  }
}
