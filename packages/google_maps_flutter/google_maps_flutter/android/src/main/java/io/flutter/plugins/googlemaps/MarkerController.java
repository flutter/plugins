// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;

/** Controller of a single Marker on the map. */
class MarkerController implements MarkerOptionsSink {

  private final Marker marker;
  private final String googleMapsMarkerId;
  private boolean consumeTapEvents;

  MarkerController(Marker marker, boolean consumeTapEvents) {
    this.marker = marker;
    this.consumeTapEvents = consumeTapEvents;
    this.googleMapsMarkerId = marker.getId();
  }

  void remove() {
    marker.remove();
  }

  @Override
  public void setAlpha(float alpha) {
    marker.setAlpha(alpha);
  }

  @Override
  public void setAnchor(float u, float v) {
    marker.setAnchor(u, v);
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
  }

  @Override
  public void setDraggable(boolean draggable) {
    marker.setDraggable(draggable);
  }

  @Override
  public void setFlat(boolean flat) {
    marker.setFlat(flat);
  }

  @Override
  public void setIcon(BitmapDescriptor bitmapDescriptor) {
    marker.setIcon(bitmapDescriptor);
  }

  @Override
  public void setInfoWindowAnchor(float u, float v) {
    marker.setInfoWindowAnchor(u, v);
  }

  @Override
  public void setInfoWindowText(String title, String snippet) {
    marker.setTitle(title);
    marker.setSnippet(snippet);
  }

  @Override
  public void setPosition(LatLng position) {
    marker.setPosition(position);
  }

  @Override
  public void setRotation(float rotation) {
    marker.setRotation(rotation);
  }

  @Override
  public void setVisible(boolean visible) {
    marker.setVisible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    marker.setZIndex(zIndex);
  }

  String getGoogleMapsMarkerId() {
    return googleMapsMarkerId;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }

  public void showInfoWindow() {
    marker.showInfoWindow();
  }

  public void hideInfoWindow() {
    marker.hideInfoWindow();
  }

  public boolean isInfoWindowShown() {
    return marker.isInfoWindowShown();
  }
}
