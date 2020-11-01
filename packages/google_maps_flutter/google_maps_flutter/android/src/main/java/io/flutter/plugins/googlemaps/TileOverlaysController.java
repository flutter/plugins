package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.TileOverlay;
import com.google.android.gms.maps.model.TileOverlayOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class TileOverlaysController {

  private final Map<String, TileOverlayController> tileOverlayIdToController;
  private final MethodChannel methodChannel;
  private GoogleMap googleMap;

  TileOverlaysController(MethodChannel methodChannel) {
    this.tileOverlayIdToController = new HashMap<>();
    this.methodChannel = methodChannel;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addTileOverlays(List<Object> tileOverlaysToAdd) {
    if (tileOverlaysToAdd == null) {
      return;
    }
    for (Object tileOverlayToAdd : tileOverlaysToAdd) {
      addTileOverlay(tileOverlayToAdd);
    }
  }

  void changeTileOverlays(List<Object> tileOverlaysToChange) {
    if (tileOverlaysToChange == null) {
      return;
    }
    for (Object tileOverlayToChange : tileOverlaysToChange) {
      changeTileOverlay(tileOverlayToChange);
    }
  }

  void removeTileOverlays(List<Object> tileOverlayIdsToRemove) {
    if (tileOverlayIdsToRemove == null) {
      return;
    }
    for (Object rawTileOverlayId : tileOverlayIdsToRemove) {
      if (rawTileOverlayId == null) {
        continue;
      }
      String tileOverlayId = (String) rawTileOverlayId;
      removeTileOverlay(tileOverlayId);
    }
  }

  void clearTileCache(Object rawTileOverlayId) {
    if (rawTileOverlayId == null) {
      return;
    }
    String tileOverlayId = (String) rawTileOverlayId;
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      tileOverlayController.clearTileCache();
    }
  }

  private void addTileOverlay(Object tileOverlayOptions) {
    if (tileOverlayOptions == null) {
      return;
    }
    TileOverlayBuilder tileOverlayOptionsBuilder = new TileOverlayBuilder();
    String tileOverlayId =
        Convert.interpretTileOverlayOptions(tileOverlayOptions, tileOverlayOptionsBuilder);
    TileProviderController tileProviderController =
        new TileProviderController(methodChannel, tileOverlayId);
    tileOverlayOptionsBuilder.setTileProvider(tileProviderController);
    TileOverlayOptions options = tileOverlayOptionsBuilder.build();
    TileOverlay tileOverlay = googleMap.addTileOverlay(options);
    TileOverlayController tileOverlayController = new TileOverlayController(tileOverlay);
    tileOverlayIdToController.put(tileOverlayId, tileOverlayController);
  }

  private void changeTileOverlay(Object tileOverlayOptions) {
    if (tileOverlayOptions == null) {
      return;
    }
    String tileOverlayId = getTileOverlayId(tileOverlayOptions);
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      Convert.interpretTileOverlayOptions(tileOverlayOptions, tileOverlayController);
    }
  }

  private void removeTileOverlay(String tileOverlayId) {
    TileOverlayController tileOverlayController = tileOverlayIdToController.get(tileOverlayId);
    if (tileOverlayController != null) {
      tileOverlayController.remove();
      tileOverlayIdToController.remove(tileOverlayId);
    }
  }

  @SuppressWarnings("unchecked")
  private static String getTileOverlayId(Object tileOverlay) {
    Map<String, Object> tileOverlayMap = (Map<String, Object>) tileOverlay;
    return (String) tileOverlayMap.get("tileOverlayId");
  }
}
