package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.UiSettings;
import java.util.ArrayList;
import java.util.List;

// This will be serialized across the platform boundary,
// needs to be kept in sync with the dart side.
class GoogleMapStateSnapshot {

  private final boolean compassEnabled;
  private final Float minZoomPreference;
  private final Float maxZoomPreference;

  static GoogleMapStateSnapshot from(GoogleMap googleMap) {
    UiSettings uiSettings = googleMap.getUiSettings();
    return new GoogleMapStateSnapshot(
        uiSettings.isCompassEnabled(), googleMap.getMinZoomLevel(), googleMap.getMaxZoomLevel());
  }

  private GoogleMapStateSnapshot(
      boolean compassEnabled, Float minZoomPreference, Float maxZoomPreference) {
    this.compassEnabled = compassEnabled;
    this.minZoomPreference = minZoomPreference;
    this.maxZoomPreference = maxZoomPreference;
  }

  List<Object> asList() {
    List<Object> container = new ArrayList<>();
    container.add(compassEnabled);
    container.add(minZoomPreference);
    container.add(maxZoomPreference);
    return container;
  }
}
