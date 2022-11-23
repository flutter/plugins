// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.maps.android.collections.MarkerManager;
import java.lang.ref.WeakReference;

/** Controller of a single Marker on the map. */
class MarkerController implements MarkerOptionsSink {

  private final WeakReference<Marker> weakMarker;
  private final String googleMapsMarkerId;
  private boolean consumeTapEvents;

  MarkerController(Marker marker, boolean consumeTapEvents) {
    this.weakMarker = new WeakReference<>(marker);
    this.consumeTapEvents = consumeTapEvents;
    this.googleMapsMarkerId = marker.getId();
  }

  void removeFromCollection(MarkerManager.Collection markerCollection) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    markerCollection.remove(marker);
  }

  @Override
  public void setAlpha(float alpha) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setAlpha(alpha);
  }

  @Override
  public void setAnchor(float u, float v) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setAnchor(u, v);
  }

  @Override
  public void setConsumeTapEvents(boolean consumeTapEvents) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    this.consumeTapEvents = consumeTapEvents;
  }

  @Override
  public void setDraggable(boolean draggable) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setDraggable(draggable);
  }

  @Override
  public void setFlat(boolean flat) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setFlat(flat);
  }

  @Override
  public void setIcon(BitmapDescriptor bitmapDescriptor) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setIcon(bitmapDescriptor);
  }

  @Override
  public void setInfoWindowAnchor(float u, float v) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setInfoWindowAnchor(u, v);
  }

  @Override
  public void setInfoWindowText(String title, String snippet) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setTitle(title);
    marker.setSnippet(snippet);
  }

  @Override
  public void setPosition(LatLng position) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setPosition(position);
  }

  @Override
  public void setRotation(float rotation) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setRotation(rotation);
  }

  @Override
  public void setVisible(boolean visible) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setVisible(visible);
  }

  @Override
  public void setZIndex(float zIndex) {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.setZIndex(zIndex);
  }

  String getGoogleMapsMarkerId() {
    return googleMapsMarkerId;
  }

  boolean consumeTapEvents() {
    return consumeTapEvents;
  }

  public void showInfoWindow() {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.showInfoWindow();
  }

  public void hideInfoWindow() {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return;
    }
    marker.hideInfoWindow();
  }

  public boolean isInfoWindowShown() {
    Marker marker = weakMarker.get();
    if (marker == null) {
      return false;
    }
    return marker.isInfoWindowShown();
  }
}
