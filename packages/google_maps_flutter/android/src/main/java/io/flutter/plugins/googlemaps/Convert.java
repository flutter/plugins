// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

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
    }
    throw new IllegalArgumentException("Cannot interpret " + o + " as CameraUpdate");
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

  static int toInt(Object o) {
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

<<<<<<< HEAD
  private static Object toJson(LatLng latLng) {
=======
  static Object latlngBoundsToJson(LatLngBounds latLngBounds) {
    final Map<String, Object> arguments = new HashMap<>(2);
    arguments.put("southwest", latLngToJson(latLngBounds.southwest));
    arguments.put("northeast", latLngToJson(latLngBounds.northeast));
    return arguments;
  }

  static Object markerIdToJson(String markerId) {
    if (markerId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("markerId", markerId);
    return data;
  }

  static Object polygonIdToJson(String polygonId) {
    if (polygonId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("polygonId", polygonId);
    return data;
  }

  static Object polylineIdToJson(String polylineId) {
    if (polylineId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("polylineId", polylineId);
    return data;
  }

  static Object circleIdToJson(String circleId) {
    if (circleId == null) {
      return null;
    }
    final Map<String, Object> data = new HashMap<>(1);
    data.put("circleId", circleId);
    return data;
  }

  static Object latLngToJson(LatLng latLng) {
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
    return Arrays.asList(latLng.latitude, latLng.longitude);
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

  static long toLong(Object o) {
    return ((Number) o).longValue();
  }

  static Map<?, ?> toMap(Object o) {
    return (Map<?, ?>) o;
  }

  private static float toFractionalPixels(Object o, float density) {
    return toFloat(o) * density;
  }

  static int toPixels(Object o, float density) {
    return (int) toFractionalPixels(o, density);
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
    final Object cameraPosition = data.get("cameraPosition");
    if (cameraPosition != null) {
      sink.setCameraPosition(toCameraPosition(cameraPosition));
    }
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
<<<<<<< HEAD
=======
    final Object myLocationEnabled = data.get("myLocationEnabled");
    if (myLocationEnabled != null) {
      sink.setMyLocationEnabled(toBoolean(myLocationEnabled));
    }
    final Object myLocationButtonEnabled = data.get("myLocationButtonEnabled");
    if (myLocationButtonEnabled != null) {
      sink.setMyLocationButtonEnabled(toBoolean(myLocationButtonEnabled));
    }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
  }

  static void interpretMarkerOptions(Object o, MarkerOptionsSink sink) {
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
    final Object consumesTapEvents = data.get("consumesTapEvents");
    if (consumesTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumesTapEvents));
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
    final Object infoWindowAnchor = data.get("infoWindowAnchor");
    if (infoWindowAnchor != null) {
      final List<?> anchorData = toList(infoWindowAnchor);
      sink.setInfoWindowAnchor(toFloat(anchorData.get(0)), toFloat(anchorData.get(1)));
    }
    final Object infoWindowText = data.get("infoWindowText");
    if (infoWindowText != null) {
      final List<?> textData = toList(infoWindowText);
      sink.setInfoWindowText(toString(textData.get(0)), toString(textData.get(1)));
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
<<<<<<< HEAD
=======
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

  static String interpretPolygonOptions(Object o, PolygonOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object geodesic = data.get("geodesic");
    if (geodesic != null) {
      sink.setGeodesic(toBoolean(geodesic));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object fillColor = data.get("fillColor");
    if (fillColor != null) {
      sink.setFillColor(toInt(fillColor));
    }
    final Object strokeColor = data.get("strokeColor");
    if (strokeColor != null) {
      sink.setStrokeColor(toInt(strokeColor));
    }
    final Object strokeWidth = data.get("strokeWidth");
    if (strokeWidth != null) {
      sink.setStrokeWidth(toInt(strokeWidth));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final Object points = data.get("points");
    if (points != null) {
      sink.setPoints(toPoints(points));
    }
    final String polygonId = (String) data.get("polygonId");
    if (polygonId == null) {
      throw new IllegalArgumentException("polygonId was null");
    } else {
      return polygonId;
    }
  }

  static String interpretPolylineOptions(Object o, PolylineOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object color = data.get("color");
    if (color != null) {
      sink.setColor(toInt(color));
    }
    final Object endCap = data.get("endCap");
    if (endCap != null) {
      sink.setEndCap(toCap(endCap));
    }
    final Object geodesic = data.get("geodesic");
    if (geodesic != null) {
      sink.setGeodesic(toBoolean(geodesic));
    }
    final Object jointType = data.get("jointType");
    if (jointType != null) {
      sink.setJointType(toInt(jointType));
    }
    final Object startCap = data.get("startCap");
    if (startCap != null) {
      sink.setStartCap(toCap(startCap));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object width = data.get("width");
    if (width != null) {
      sink.setWidth(toInt(width));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final Object points = data.get("points");
    if (points != null) {
      sink.setPoints(toPoints(points));
    }
    final Object pattern = data.get("pattern");
    if (pattern != null) {
      sink.setPattern(toPattern(pattern));
    }
    final String polylineId = (String) data.get("polylineId");
    if (polylineId == null) {
      throw new IllegalArgumentException("polylineId was null");
    } else {
      return polylineId;
    }
  }

  static String interpretCircleOptions(Object o, CircleOptionsSink sink) {
    final Map<?, ?> data = toMap(o);
    final Object consumeTapEvents = data.get("consumeTapEvents");
    if (consumeTapEvents != null) {
      sink.setConsumeTapEvents(toBoolean(consumeTapEvents));
    }
    final Object fillColor = data.get("fillColor");
    if (fillColor != null) {
      sink.setFillColor(toInt(fillColor));
    }
    final Object strokeColor = data.get("strokeColor");
    if (strokeColor != null) {
      sink.setStrokeColor(toInt(strokeColor));
    }
    final Object visible = data.get("visible");
    if (visible != null) {
      sink.setVisible(toBoolean(visible));
    }
    final Object strokeWidth = data.get("strokeWidth");
    if (strokeWidth != null) {
      sink.setStrokeWidth(toInt(strokeWidth));
    }
    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
    final Object center = data.get("center");
    if (center != null) {
      sink.setCenter(toLatLng(center));
    }
    final Object radius = data.get("radius");
    if (radius != null) {
      sink.setRadius(toDouble(radius));
    }
    final String circleId = (String) data.get("circleId");
    if (circleId == null) {
      throw new IllegalArgumentException("circleId was null");
    } else {
      return circleId;
    }
  }

  private static List<LatLng> toPoints(Object o) {
    final List<?> data = toList(o);
    final List<LatLng> points = new ArrayList<>(data.size());

    for (Object ob : data) {
      final List<?> point = toList(ob);
      points.add(new LatLng(toFloat(point.get(0)), toFloat(point.get(1))));
    }
    return points;
  }

  private static List<PatternItem> toPattern(Object o) {
    final List<?> data = toList(o);

    if (data.isEmpty()) {
      return null;
    }

    final List<PatternItem> pattern = new ArrayList<>(data.size());

    for (Object ob : data) {
      final List<?> patternItem = toList(ob);
      switch (toString(patternItem.get(0))) {
        case "dot":
          pattern.add(new Dot());
          break;
        case "dash":
          pattern.add(new Dash(toFloat(patternItem.get(1))));
          break;
        case "gap":
          pattern.add(new Gap(toFloat(patternItem.get(1))));
          break;
        default:
          throw new IllegalArgumentException("Cannot interpret " + pattern + " as PatternItem");
      }
    }

    return pattern;
  }

  private static Cap toCap(Object o) {
    final List<?> data = toList(o);
    switch (toString(data.get(0))) {
      case "buttCap":
        return new ButtCap();
      case "roundCap":
        return new RoundCap();
      case "squareCap":
        return new SquareCap();
      case "customCap":
        if (data.size() == 2) {
          return new CustomCap(toBitmapDescriptor(data.get(1)));
        } else {
          return new CustomCap(toBitmapDescriptor(data.get(1)), toFloat(data.get(2)));
        }
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as Cap");
    }
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
  }
}
