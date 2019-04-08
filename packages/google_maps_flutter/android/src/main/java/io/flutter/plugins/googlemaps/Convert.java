// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Point;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import io.flutter.view.FlutterMain;
import java.util.Arrays;
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
      case "fromBytes":
        return getBitmapFromBytes(data);
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
    }
  }

  private static BitmapDescriptor getBitmapFromBytes(List<?> data) {
    if (data.size() == 2) {
      try {
        Bitmap bitmap = toBitmap(data.get(1));
        return BitmapDescriptorFactory.fromBitmap(bitmap);
      } catch (Exception e) {
        throw new IllegalArgumentException("Unable to interpret bytes as a valid image.", e);
      }
    } else {
      throw new IllegalArgumentException(
          "fromBytes should have exactly one argument, the bytes. Got: " + data.size());
    }
  }

  private static boolean toBoolean(Object o) {
    return (Boolean) o;
  }

  static CameraPosition toCameraPosition(Object o) {
    final Map<?, ?> data = toMap(o);
    final CameraPosition.Builder builder = CameraPosition.builder();
    builder.bearing(toFloat(data.get("bearing")));
    builder.target(toLatLng(data.get("target")));
    builder.tilt(toFloat(data.get("tilt")));
    builder.zoom(toFloat(data.get("zoom")));
    return builder.build();
  }

  static CameraUpdate toCameraUpdate(Object o, float density) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "newCameraPosition":
        return CameraUpdateFactory.newCameraPosition(toCameraPosition(data.get(1)));
      case "newLatLng":
        return CameraUpdateFactory.newLatLng(toLatLng(data.get(1)));
      case "newLatLngBounds":
        return CameraUpdateFactory.newLatLngBounds(
            toLatLngBounds(data.get(1)), toPixels(data.get(2), density));
      case "newLatLngZoom":
        return CameraUpdateFactory.newLatLngZoom(toLatLng(data.get(1)), toFloat(data.get(2)));
      case "scrollBy":
        return CameraUpdateFactory.scrollBy( //
            toFractionalPixels(data.get(1), density), //
            toFractionalPixels(data.get(2), density));
      case "zoomBy":
        if (data.size() == 2) {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)));
        } else {
          return CameraUpdateFactory.zoomBy(toFloat(data.get(1)), toPoint(data.get(2), density));
        }
      case "zoomIn":
        return CameraUpdateFactory.zoomIn();
      case "zoomOut":
        return CameraUpdateFactory.zoomOut();
      case "zoomTo":
        return CameraUpdateFactory.zoomTo(toFloat(data.get(1)));
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
    }
  }

  private static double toDouble(Object o) {
    return ((Number) o).doubleValue();
  }

  private static float toFloat(Object o) {
    return ((Number) o).floatValue();
  }

  private static Float toFloatWrapper(Object o) {
    return (o == null) ? null : toFloat(o);
  }

  private static int toInt(Object o) {
    return ((Number) o).intValue();
  }

  static Object toJson(CameraPosition position) {
    if (position == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>();
    data.put("bearing", position.bearing);
    data.put("target", toJson(position.target));
    data.put("tilt", position.tilt);
    data.put("zoom", position.zoom);
    return data;
  }

  static Object toJson(String markerId) {
    if (markerId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("markerId", markerId);
    return data;
  }

  static Object toJson(LatLng latLng) {
    return Arrays.asList(latLng.latitude, latLng.longitude);
  }

  public static Object toJson(LatLngBounds latLngBounds) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("southwest", toJson(latLngBounds.southwest));
    arguments.put("northeast", toJson(latLngBounds.northeast));
    return arguments;
  }

  private static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  private static LatLngBounds toLatLngBounds(Object o) {
    if (o == null) {
      return null;
    }
    final List<?> data = toList(o);
    return new LatLngBounds(toLatLng(data.get(0)), toLatLng(data.get(1)));
  }

  private static List<?> toList(Object o) {
    return (List<?>) o;
  }

  private static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  private static float toFractionalPixels(Object o, float density) {
    return toFloat(o) * density;
  }

  private static int toPixels(Object o, float density) {
    return (int) toFractionalPixels(o, density);
  }

  private static Bitmap toBitmap(Object o) {
    byte[] bmpData = (byte[]) o;
    Bitmap bitmap = BitmapFactory.decodeByteArray(bmpData, 0, bmpData.length);
    if (bitmap == null) {
      throw new IllegalArgumentException("Unable to decode bytes as a valid bitmap.");
    } else {
      return bitmap;
    }
  }

  private static Point toPoint(Object o, float density) {
    final List<?> data = toList(o);
    return new Point(toPixels(data.get(0), density), toPixels(data.get(1), density));
  }

  private static String toString(Object o) {
    return (String) o;
  }

  static void interpretGoogleMapOptions(Object o, GoogleMapOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object cameraTargetBounds = data.get("cameraTargetBounds");
    if (cameraTargetBounds != null) {
      final List<?> targetData = toList(cameraTargetBounds);
      sink.setCameraTargetBounds(toLatLngBounds(targetData.get(0)));
    }
    final Object compassEnabled = data.get("compassEnabled");
    if (compassEnabled != null) {
      sink.setCompassEnabled(toBoolean(compassEnabled));
    }
    final Object mapType = data.get("mapType");
    if (mapType != null) {
      sink.setMapType(toInt(mapType));
    }
    final Object minMaxZoomPreference = data.get("minMaxZoomPreference");
    if (minMaxZoomPreference != null) {
      final List<?> zoomPreferenceData = toList(minMaxZoomPreference);
      sink.setMinMaxZoomPreference( //
          toFloatWrapper(zoomPreferenceData.get(0)), //
          toFloatWrapper(zoomPreferenceData.get(1)));
    }
    final Object rotateGesturesEnabled = data.get("rotateGesturesEnabled");
    if (rotateGesturesEnabled != null) {
      sink.setRotateGesturesEnabled(toBoolean(rotateGesturesEnabled));
    }
    final Object scrollGesturesEnabled = data.get("scrollGesturesEnabled");
    if (scrollGesturesEnabled != null) {
      sink.setScrollGesturesEnabled(toBoolean(scrollGesturesEnabled));
    }
    final Object tiltGesturesEnabled = data.get("tiltGesturesEnabled");
    if (tiltGesturesEnabled != null) {
      sink.setTiltGesturesEnabled(toBoolean(tiltGesturesEnabled));
    }
    final Object trackCameraPosition = data.get("trackCameraPosition");
    if (trackCameraPosition != null) {
      sink.setTrackCameraPosition(toBoolean(trackCameraPosition));
    }
    final Object zoomGesturesEnabled = data.get("zoomGesturesEnabled");
    if (zoomGesturesEnabled != null) {
      sink.setZoomGesturesEnabled(toBoolean(zoomGesturesEnabled));
    }
    final Object myLocationEnabled = data.get("myLocationEnabled");
    if (myLocationEnabled != null) {
      sink.setMyLocationEnabled(toBoolean(myLocationEnabled));
    }
  }

  /** Returns the dartMarkerId of the interpreted marker. */
  static String interpretMarkerOptions(Object o, MarkerOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object alpha = data.get("alpha");
    if (alpha != null) {
      sink.setAlpha(toFloat(alpha));
    }
    final Object anchor = data.get("anchor");
    if (anchor != null) {
      final List<?> anchorData = toList(anchor);
      sink.setAnchor(toFloat(anchorData.get(0)), toFloat(anchorData.get(1)));
    }
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object draggable = data.get("draggable");
    if (draggable != null) {
      sink.setDraggable(toBoolean(draggable));
    }
    final Object flat = data.get("flat");
    if (flat != null) {
      sink.setFlat(toBoolean(flat));
    }
    final Object icon = data.get("icon");
    if (icon != null) {
      sink.setIcon(toBitmapDescriptor(icon));
    }

    final Object infoWindow = data.get("infoWindow");
    if (infoWindow != null) {
      interpretInfoWindowOptions(sink, (Map<String, Object>) infoWindow);
    }
    final Object position = data.get("position");
    if (position != null) {
      sink.setPosition(toLatLng(position));
    }
    final Object rotation = data.get("rotation");
    if (rotation != null) {
      sink.setRotation(toFloat(rotation));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final String markerId = (String) data.get("markerId");
    if (markerId == null) {
      throw new IllegalArgumentException("markerId was null");
    } else {
      return markerId;
    }
  }

  private static void interpretInfoWindowOptions(
      MarkerOptionsSink sink, Map<String, Object> infoWindow) {
    String title = (String) infoWindow.get("title");
    String snippet = (String) infoWindow.get("snippet");
    // snippet is nullable.
    if (title != null) {
      sink.setInfoWindowText(title, snippet);
    }
    Object infoWindowAnchor = infoWindow.get("anchor");
    if (infoWindowAnchor != null) {
      final List<?> anchorData = toList(infoWindowAnchor);
      sink.setInfoWindowAnchor(toFloat(anchorData.get(0)), toFloat(anchorData.get(1)));
    }
  }
}
