// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.graphics.Point;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.ButtCap;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.Cap;
import com.google.android.gms.maps.model.Dash;
import com.google.android.gms.maps.model.Dot;
import com.google.android.gms.maps.model.Gap;
import com.google.android.gms.maps.model.JointType;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.PatternItem;
import com.google.android.gms.maps.model.RoundCap;
import com.google.android.gms.maps.model.SquareCap;
import io.flutter.view.FlutterMain;
import java.util.ArrayList;
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
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as BitmapDescriptor");
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

  private static Object toJson(LatLng latLng) {
    return Arrays.asList(latLng.latitude, latLng.longitude);
  }

  private static LatLng toLatLng(Object o) {
    final List<?> data = toList(o);
    return new LatLng(toDouble(data.get(0)), toDouble(data.get(1)));
  }

  private static Cap toCap(Object o) {

    switch (toString(o)) {
      case "Cap.RoundCap":
        return new RoundCap();
      case "Cap.SquareCap":
        return new SquareCap();
      case "Cap.ButtCap":
        return new ButtCap();
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as Cap");
    }
  }

  private static int toJointType(Object o) {

    switch (toString(o)) {
      case "JointType.Bevel":
        return JointType.BEVEL;
      case "JointType.Default":
        return JointType.DEFAULT;
      case "JointType.Route":
        return JointType.ROUND;
      default:
        throw new IllegalArgumentException("Cannot interpret " + o + " as JointType");
    }
  }

  private static List<PatternItem> toPatternItemList(Object o) {

    List<?> list = (List<?>) o;
    List<PatternItem> items = new ArrayList<>();
    for (int x = 0; x < list.size(); x++) {
      final Map<?, ?> data = toMap(list.get(x));
      int length = toInt(data.get("length"));
      String pattern = toString(data.get("pattern"));

      switch (pattern) {
        case "PatternItem.Dash":
          items.add(new Dash(length));
          break;
        case "PatternItem.Gap":
          items.add(new Gap(length));
          break;
        case "PatternItem.Dot":
          items.add(new Dot());
          break;
        default:
          throw new IllegalArgumentException("Cannot interpret " + pattern + " as PatternItem");
      }
    }
    if (items.size() == 0) {
      return null;
    }
    return items;
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
  }

  static void interpretPolylineOptions(Object o, PolylineOptionsSink sink) {
    final Map<?, ?> data = toMap(o);

    final Object points = data.get("points");
    if (points != null) {
      final List<?> pointData = toList(points);
      final List<LatLng> latLngList = new ArrayList<LatLng>();
      for (int i = 0; i < pointData.size(); i++) {
        latLngList.add(toLatLng(pointData.get(i)));
      }
      sink.setPoints(latLngList);
    }

    final Object clickable = data.get("clickable");
    if (clickable != null) {
      sink.setClickable(toBoolean(clickable));
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
      sink.setJointType(toJointType(jointType));
    }

    final Object pattern = data.get("pattern");
    if (pattern != null) {
      sink.setPattern(toPatternItemList(pattern));
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
      sink.setWidth(toFloat(width));
    }

    final Object zIndex = data.get("zIndex");
    if (zIndex != null) {
      sink.setZIndex(toFloat(zIndex));
    }
  }
}
