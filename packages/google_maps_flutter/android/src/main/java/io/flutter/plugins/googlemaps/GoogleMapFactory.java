// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
import androidx.lifecycle.Lifecycle;
import com.google.android.gms.maps.model.CameraPosition;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class GoogleMapFactory extends PlatformViewFactory {

  private final Lifecycle mLifecycle;
  private final BinaryMessenger binaryMessenger;

  GoogleMapFactory(Lifecycle lifecycle, BinaryMessenger binaryMessenger) {
    super(StandardMessageCodec.INSTANCE);
    mLifecycle = lifecycle;
    this.binaryMessenger = binaryMessenger;
  }

  @SuppressWarnings("unchecked")
  @Override
  public PlatformView create(Context context, int id, Object args) {
    Map<String, Object> params = (Map<String, Object>) args;
    final GoogleMapBuilder builder = new GoogleMapBuilder();

    Convert.interpretGoogleMapOptions(params.get("options"), builder);
    if (params.containsKey("initialCameraPosition")) {
      CameraPosition position = Convert.toCameraPosition(params.get("initialCameraPosition"));
      builder.setInitialCameraPosition(position);
    }
    if (params.containsKey("markersToAdd")) {
      builder.setInitialMarkers(params.get("markersToAdd"));
    }
    if (params.containsKey("polygonsToAdd")) {
      builder.setInitialPolygons(params.get("polygonsToAdd"));
    }
    if (params.containsKey("polylinesToAdd")) {
      builder.setInitialPolylines(params.get("polylinesToAdd"));
    }
    if (params.containsKey("circlesToAdd")) {
      builder.setInitialCircles(params.get("circlesToAdd"));
    }
    return builder.build(id, context, mLifecycle, binaryMessenger);
  }
}
