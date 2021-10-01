// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.GroundOverlay;
import com.google.android.gms.maps.model.GroundOverlayOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class GroundOverlaysController {

  private final Map<String, GroundOverlayController> groundOverlayIdToController;
  private final MethodChannel methodChannel;
  private GoogleMap googleMap;

  GroundOverlaysController(MethodChannel methodChannel) {
    this.groundOverlayIdToController = new HashMap<>();
    this.methodChannel = methodChannel;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addGroundOverlays(List<Map<String, ?>> groundOverlaysToAdd) {
    if (groundOverlaysToAdd == null) {
      return;
    }
    for (Map<String, ?> groundOverlayToAdd : groundOverlaysToAdd) {
      addGroundOverlay(groundOverlayToAdd);
    }
  }

  void changeGroundOverlays(List<Map<String, ?>> groundOverlaysToChange) {
    if (groundOverlaysToChange == null) {
      return;
    }
    for (Map<String, ?> groundOverlayToChange : groundOverlaysToChange) {
      changeGroundOverlay(groundOverlayToChange);
    }
  }

  void removeGroundOverlays(List<String> groundOverlayIdsToRemove) {
    if (groundOverlayIdsToRemove == null) {
      return;
    }
    for (String groundOverlayId : groundOverlayIdsToRemove) {
      if (groundOverlayId == null) {
        continue;
      }
      removeGroundOverlay(groundOverlayId);
    }
  }

  Map<String, Object> getGroundOverlayInfo(String groundOverlayId) {
    if (groundOverlayId == null) {
      return null;
    }
    GroundOverlayController groundOverlayController = groundOverlayIdToController
        .get(groundOverlayId);
    if (groundOverlayController == null) {
      return null;
    }
    return groundOverlayController.getGroundOverlayInfo();
  }

  private void addGroundOverlay(Map<String, ?> groundOverlayOptions) {
    if (groundOverlayOptions == null) {
      return;
    }
    GroundOverlayBuilder groundOverlayOptionsBuilder = new GroundOverlayBuilder();
    String groundOverlayId =
        Convert.interpretGroundOverlayOptions(groundOverlayOptions, groundOverlayOptionsBuilder);

    GroundOverlayOptions options = groundOverlayOptionsBuilder.build();
    GroundOverlay groundOverlay = googleMap.addGroundOverlay(options);
    GroundOverlayController groundOverlayController = new GroundOverlayController(groundOverlay);
    groundOverlayIdToController.put(groundOverlayId, groundOverlayController);
  }

  private void changeGroundOverlay(Map<String, ?> groundOverlayOptions) {
    if (groundOverlayOptions == null) {
      return;
    }
    String groundOverlayId = getGroundOverlayId(groundOverlayOptions);
    GroundOverlayController groundOverlayController = groundOverlayIdToController
        .get(groundOverlayId);
    if (groundOverlayController != null) {
      Convert.interpretGroundOverlayOptions(groundOverlayOptions, groundOverlayController);
    }
  }

  private void removeGroundOverlay(String groundOverlayId) {
    GroundOverlayController groundOverlayController = groundOverlayIdToController
        .get(groundOverlayId);
    if (groundOverlayController != null) {
      groundOverlayController.remove();
      groundOverlayIdToController.remove(groundOverlayId);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getGroundOverlayId(Map<String, ?> groundOverlay) {
    return (String) groundOverlay.get("groundOverlayId");
  }
}
