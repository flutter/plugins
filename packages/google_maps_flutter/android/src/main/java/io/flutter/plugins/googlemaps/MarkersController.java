package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

class MarkersController {

  private final Map<MarkerId, MarkerController> markerIdToController;
  private final Map<String, MarkerId> googleMapsMarkerIdToDartMarkerId;
  private final MethodChannel methodChannel;
  private GoogleMap googleMap;

  MarkersController(MethodChannel methodChannel) {
    this.markerIdToController = new HashMap<>();
    this.googleMapsMarkerIdToDartMarkerId = new HashMap<>();
    this.methodChannel = methodChannel;
  }

  void setGoogleMap(GoogleMap googleMap) {
    this.googleMap = googleMap;
  }

  void addMarkers(List<Object> markersToAdd) {
    if (markersToAdd != null) {
      for (Object markerToAdd : markersToAdd) {
        addMarker(markerToAdd);
      }
    }
  }

  void changeMarkers(List<Object> markersToChange) {
    if (markersToChange != null) {
      for (Object markerToChange : markersToChange) {
        changeMarker(markerToChange);
      }
    }
  }

  void removeMarkers(List<Object> markerIdsToRemove) {
    if (markerIdsToRemove == null) {
      return;
    }
    for (Object rawMarkerId : markerIdsToRemove) {
      if (rawMarkerId != null) {
        MarkerId markerId = new MarkerId((String) rawMarkerId);
        final MarkerController markerController = markerIdToController.remove(markerId);
        if (markerController != null) {
          markerController.remove();
          googleMapsMarkerIdToDartMarkerId.remove(markerController.getGoogleMapsMarkerId());
        }
      }
    }
  }

  boolean onMarkerTap(String googleMarkerId) {
    MarkerId markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return false;
    }
    methodChannel.invokeMethod("marker#onTap", Convert.toJson(markerId));
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      return markerController.consumeTapEvents();
    }
    return false;
  }

  void onInfoWindowTap(String googleMarkerId) {
    MarkerId markerId = googleMapsMarkerIdToDartMarkerId.get(googleMarkerId);
    if (markerId == null) {
      return;
    }
    methodChannel.invokeMethod("infoWindow#onTap", Convert.toJson(markerId));
  }

  private void addMarker(Object marker) {
    if (marker == null) {
      return;
    }
    MarkerBuilder markerBuilder = new MarkerBuilder();
    MarkerId markerId = Convert.interpretMarkerOptions(marker, markerBuilder);
    MarkerOptions options = markerBuilder.build();
    addMarker(markerId, options, markerBuilder.consumeTapEvents());
  }

  private void addMarker(MarkerId markerId, MarkerOptions markerOptions, boolean consumeTapEvents) {
    final Marker marker = googleMap.addMarker(markerOptions);
    MarkerController controller = new MarkerController(marker, consumeTapEvents);
    markerIdToController.put(markerId, controller);
    googleMapsMarkerIdToDartMarkerId.put(marker.getId(), markerId);
  }

  private void changeMarker(Object marker) {
    if (marker == null) {
      return;
    }
    MarkerId markerId = getMarkerId(marker);
    MarkerController markerController = markerIdToController.get(markerId);
    if (markerController != null) {
      Convert.interpretMarkerOptions(marker, markerController);
    }
  }

  @SuppressWarnings("unchecked")
  private static MarkerId getMarkerId(Object marker) {
    Map<String, Object> markerMap = (Map<String, Object>) marker;
    String markerId = (String) markerMap.get("markerId");
    return new MarkerId(markerId);
  }
}
