// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemobilemaps;

import android.graphics.Point;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.UiSettings;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.MarkerOptions;
import io.flutter.view.FlutterMain;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** Conversions between JSON-like values and GoogleMaps data types. */
class Convert {
  private static BitmapDescriptor toBitmapDescriptor(Object o) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "defaultMarker":
        if (data.size() == 1) {
          return BitmapDescriptorFactory.defaultMarker();
        } else {
          return BitmapDescriptorFactory.defaultMarker(toFloat(data.get(1)));
        }
      case "fromAsset":
        if (data.size() == 2) {
          return BitmapDescriptorFactory.fromAsset(
              FlutterMain.getLookupKeyForAsset(toString(data.get(1))));
        } else {
          return BitmapDescriptorFactory.fromAsset(
              FlutterMain.getLookupKeyForAsset(toString(data.get(1)), toString(data.get(2))));
        }
      case "fromFile":
        return BitmapDescriptorFactory.fromFile(toString(data.get(1)));
      case "fromPath":
        return BitmapDescriptorFactory.fromPath(toString(data.get(1)));
    }
    throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
  }

  private static boolean toBoolean(Object o) {
    return (Boolean) o;
  }

  private static CameraPosition toCameraPosition(Object o) {
    final Map<?, ?> data = toMap(o);
    final CameraPosition.Builder builder = CameraPosition.builder();
    builder.bearing(toFloat(data.get("bearing")));
    builder.target(toLatLng(data.get("target")));
    builder.tilt(toFloat(data.get("tilt")));
    builder.zoom(toFloat(data.get("zoom")));
    return builder.build();
  }

  static CameraUpdate toCameraUpdate(Object o) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "newCameraPosition":
        return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
      case "newLatLng":
        return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
      case "newLatLngBounds":
        return CameraUpdateFactory.newLatLngBounds(toLatLngBounds(data.get(1)), toInt(data.get(2)));
      case "newLatLngZoom":
        return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
      case "scrollBy":
        return CameraUpdateFactory.scrollBy(toFloat(data.get(1)), toFloat(data.get(2)));
      case "zoomBy":
        if (data.size() == 2) {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
        } else {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2)));
        }
      case "zoomIn":
        return CameraUpdateFactory.zoomIn();
      case "zoomOut":
        return CameraUpdateFactory.zoomOut();
      case "zoomTo":
        return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
    }
    throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static float toFloat(Object o) {
    return ((Number) o).floatValue();
  }

  static GoogleMapOptions toGoogleMapOptions(Object o) {
    final Map<?, ?> data = toMap(o);
    final GoogleMapOptions options = new GoogleMapOptions();
    final Object cameraPosition = data.get("cameraPosition");
    if (cameraPosition != null) {
      options.camera(toCameraPosition(cameraPosition));
    }
    final Object cameraTargetBounds = data.get("cameraTargetBounds");
    if (cameraTargetBounds != null) {
      final List<?> targetData = toList(cameraTargetBounds);
      if (targetData.get(0) != null) {
        options.latLngBoundsForCameraTarget(toLatLngBounds(targetData.get(0)));
      }
    }
    final Object compassEnabled = data.get("compassEnabled");
    if (compassEnabled != null) {
      options.compassEnabled(toBoolean(compassEnabled));
    }
    final Object mapType = data.get("mapType");
    if (mapType != null) {
      options.mapType(toInt(mapType));
    }
    final Object rotateGesturesEnabled = data.get("rotateGesturesEnabled");
    if (rotateGesturesEnabled != null) {
      options.rotateGesturesEnabled(toBoolean(rotateGesturesEnabled));
    }
    final Object scrollGesturesEnabled = data.get("scrollGesturesEnabled");
    if (scrollGesturesEnabled != null) {
      options.scrollGesturesEnabled(toBoolean(scrollGesturesEnabled));
    }
    final Object tiltGesturesEnabled = data.get("tiltGesturesEnabled");
    if (tiltGesturesEnabled != null) {
      options.tiltGesturesEnabled(toBoolean(tiltGesturesEnabled));
    }
    final Object zoomBounds = data.get("zoomBounds");
    if (zoomBounds != null) {
      final List<?> zoomData = toList(zoomBounds);
      if (zoomData.get(0) != null) {
        options.minZoomPreference(toFloat(zoomData.get(0)));
      }
      if (zoomData.get(1) != null) {
        options.maxZoomPreference(toFloat(zoomData.get(1)));
      }
    }
    final Object zoomGesturesEnabled = data.get("zoomGesturesEnabled");
    if (zoomGesturesEnabled != null) {
      options.zoomGesturesEnabled(toBoolean(zoomGesturesEnabled));
    }
    return options;
  }

  static int toInt(Object o) {
    return ((Number) o).intValue();
  }

  private static Object toJson(CameraPosition position) {
    final Map<String, Object> data = new HashMap<>();
    data.put("bearing", position.bearing);
    data.put("target", toJson(position.target));
    data.put("tilt", position.tilt);
    data.put("zoom", position.zoom);
    return data;
  }

  private static Object toJson(LatLng latLng) {
    return Arrays.asList(latLng.latitude, latLng.longitude);
  }

  private static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  private static LatLngBounds toLatLngBounds(Object o) {
    final List<?> data = toList(o);
    return new LatLngBounds(toLatLng(data.get(0)), toLatLng(data.get(1)));
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  static long toLong(Object o) {
    return ((Number) o).longValue();
  }

  static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  static MarkerOptions toMarkerOptions(Object o) {
    final Map<?, ?> data = toMap(o);
    final List<?> anchor = toList(data.get("anchor"));
    final List<?> infoWindowAnchor = toList(data.get("infoWindowAnchor"));
    return new MarkerOptions()
        .position(toLatLng(data.get("position")))
        .alpha(toFloat(data.get("alpha")))
        .anchor(toFloat(anchor.get(0)), toFloat(anchor.get(1)))
        .draggable(toBoolean(data.get("draggable")))
        .flat(toBoolean(data.get("flat")))
        .icon(toBitmapDescriptor(data.get("icon")))
        .infoWindowAnchor(toFloat(infoWindowAnchor.get(0)), toFloat(infoWindowAnchor.get(1)))
        .rotation(toFloat(data.get("rotation")))
        .snippet(toString(data.get("snippet")))
        .title(toString(data.get("title")))
        .visible(toBoolean(data.get("visible")))
        .zIndex(toFloat(data.get("zIndex")));
  }

  private static Point toPoint(Object o) {
    final List<?> data = toList(o);
    return new Point(toInt(data.get(0)), toInt(data.get(1)));
  }

  private static String toString(Object o) {
    return (String) o;
  }

  /**
   * Sets GoogleMaps user interface options extracted from the specified JSON-like value on the
   * given GoogleMap instance.
   *
   * @param o the JSON-like value
   * @param googleMap the GoogleMap instance
   */
  static void setMapOptions(Object o, GoogleMap googleMap) {
    final Map<?, ?> options = toMap(o);
    final Object cameraTargetBounds = options.get("cameraTargetBounds");
    final UiSettings uiSettings = googleMap.getUiSettings();
    if (cameraTargetBounds != null) {
      final List<?> targetData = toList(cameraTargetBounds);
      if (targetData.get(0) == null) {
        googleMap.setLatLngBoundsForCameraTarget(null);
      } else {
        googleMap.setLatLngBoundsForCameraTarget(toLatLngBounds(targetData.get(0)));
      }
    }
    final Object compassEnabled = options.get("compassEnabled");
    if (compassEnabled != null) {
      uiSettings.setCompassEnabled(toBoolean(compassEnabled));
    }
    final Object mapType = options.get("mapType");
    if (mapType != null) {
      googleMap.setMapType(toInt(mapType));
    }
    final Object rotateGesturesEnabled = options.get("rotateGesturesEnabled");
    if (rotateGesturesEnabled != null) {
      uiSettings.setRotateGesturesEnabled(toBoolean(rotateGesturesEnabled));
    }
    final Object scrollGesturesEnabled = options.get("scrollGesturesEnabled");
    if (scrollGesturesEnabled != null) {
      uiSettings.setScrollGesturesEnabled(toBoolean(scrollGesturesEnabled));
    }
    final Object tiltGesturesEnabled = options.get("tiltGesturesEnabled");
    if (tiltGesturesEnabled != null) {
      uiSettings.setTiltGesturesEnabled(toBoolean(tiltGesturesEnabled));
    }
    final Object zoomBounds = options.get("zoomBounds");
    if (zoomBounds != null) {
      final List<?> zoomData = toList(zoomBounds);
      googleMap.resetMinMaxZoomPreference();
      if (zoomData.get(0) != null) {
        googleMap.setMinZoomPreference(toFloat(zoomData.get(0)));
      }
      if (zoomData.get(1) != null) {
        googleMap.setMaxZoomPreference(toFloat(zoomData.get(1)));
      }
    }
    final Object zoomGesturesEnabled = options.get("zoomGesturesEnabled");
    if (zoomGesturesEnabled != null) {
      uiSettings.setZoomGesturesEnabled(toBoolean(zoomGesturesEnabled));
    }
    final Object cameraPosition = options.get("cameraPosition");
    if (cameraPosition != null) {
      googleMap.moveCamera(CameraUpdateFactory.newCameraPosition(toCameraPosition(cameraPosition)));
    }
  }

  /**
   * Stores GoogleMaps user interface configuration items extracted from the specified JSON-like
   * value in the provided storage Map for cases where no getters exist in the GoogleMaps APIs.
   *
   * @param o the JSON-like value
   * @param storageMap the storage Map
   */
  static void setMapOptionsWithNoGetters(Object o, Map<String, Object> storageMap) {
    final Map<?, ?> options = toMap(o);
    final Object cameraTargetBounds = options.get("cameraTargetBounds");
    if (cameraTargetBounds != null) {
      storageMap.put("cameraTargetBounds", cameraTargetBounds);
    }
    final Object zoomBounds = options.get("zoomBounds");
    if (zoomBounds != null) {
      storageMap.put("zoomBounds", zoomBounds);
    }
  }

  /**
   * Extract current GoogleMaps user interface configuration items in a JSON-like value, using the
   * specified storage Map for cases where no getters exist in the GoogleMaps APIs.
   *
   * @param googleMap a GoogleMap instance
   * @param storageMap the storage Map
   * @return a JSON-like value
   */
  static Object getMapOptions(GoogleMap googleMap, Map<String, Object> storageMap) {
    final Map<String, Object> json = new HashMap<>(storageMap);
    final UiSettings uiSettings = googleMap.getUiSettings();
    json.put("cameraPosition", toJson(googleMap.getCameraPosition()));
    if (!json.containsKey("cameraTargetBounds")) {
      json.put("cameraTargetBounds", Collections.singletonList(null)); // unbounded
    }
    json.put("compassEnabled", uiSettings.isCompassEnabled());
    json.put("mapType", googleMap.getMapType());
    json.put("rotateGesturesEnabled", uiSettings.isRotateGesturesEnabled());
    json.put("scrollGesturesEnabled", uiSettings.isScrollGesturesEnabled());
    json.put("tiltGesturesEnabled", uiSettings.isTiltGesturesEnabled());
    if (!json.containsKey("zoomBounds")) {
      json.put("zoomBounds", Arrays.asList(null, null)); // unbounded
    }
    json.put("zoomGesturesEnabled", uiSettings.isZoomGesturesEnabled());
    return json;
  }
}
