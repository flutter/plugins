// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.ClusterItem;

class MarkerBuilder implements MarkerOptionsSink, ClusterItem {
  private float alpha = 1.0f;
  private float anchorU;
  private float anchorV;
  private boolean draggable;
  private boolean flat;
  private boolean consumeTapEvents;
  private BitmapDescriptor bitmapDescriptor;
  private float infoWindowAnchorU = 0.5f;
  private float infoWindowAnchorV;
  private String infoWindowTitle;
  private String infoWindowSnippet;
  private LatLng position = new LatLng(0.0f, 0.0f);
  private float rotation;
  private boolean visible;
  private float zIndex;
  private String clusterManagerId;
  private String markerId;

  MarkerBuilder(String markerId, String clusterManagerId) {
    this.markerId = markerId;
    this.clusterManagerId = clusterManagerId;
  }

  MarkerOptions build() {
    MarkerOptions markerOptions = new MarkerOptions();
    return build(markerOptions);
  }

  /** Update existing markerOptions with builder values */
  MarkerOptions build(MarkerOptions markerOptions) {
    return markerOptions
        .position(position)
        .alpha(alpha)
        .anchor(anchorU, anchorV)
        .draggable(draggable)
        .flat(flat)
        .icon(bitmapDescriptor)
        .infoWindowAnchor(infoWindowAnchorU, infoWindowAnchorV)
        .title(infoWindowTitle)
        .snippet(infoWindowSnippet)
        .rotation(rotation)
        .visible(visible)
        .zIndex(zIndex);
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }

  String clusterManagerId() {
    return clusterManagerId;
  }

  String markerId() {
    return markerId;
  }

  @Override
  public void setAlpha(float alpha) {
    this.alpha = alpha;
  }

  @Override
  public void setAnchor(float u, float v) {
    anchorU = u;
    anchorV = v;
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    this.consumeTapEvents = consumeTapEvents;
  }

  @Override
  public void setDraggable(boolean draggable) {
    this.draggable = draggable;
  }

  @Override
  public void setFlat(boolean flat) {
    this.flat = flat;
  }

  @Override
  public void setIcon(BitmapDescriptor bitmapDescriptor) {
    this.bitmapDescriptor = bitmapDescriptor;
  }

  @Override
  public void setInfoWindowAnchor(float u, float v) {
    infoWindowAnchorU = u;
    infoWindowAnchorV = v;
  }

  @Override
  public void setInfoWindowText(String title, String snippet) {
    infoWindowTitle = title;
    infoWindowSnippet = snippet;
  }

  @Override
  public void setPosition(LatLng position) {
    this.position = position;
  }

  @Override
  public void setRotation(float rotation) {
    this.rotation = rotation;
  }

  @Override
  public void setVisible(boolean visible) {
    this.visible = visible;
  }

  @Override
  public void setZIndex(float zIndex) {
    this.zIndex = zIndex;
  }

  @Override
  public LatLng getPosition() {
    return position;
  }

  @Override
  public String getTitle() {
    return infoWindowTitle;
  }

  @Override
  public String getSnippet() {
    return infoWindowSnippet;
  }
}
