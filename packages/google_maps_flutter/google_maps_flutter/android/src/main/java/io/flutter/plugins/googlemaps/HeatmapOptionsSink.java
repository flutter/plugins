package io.flutter.plugins.googlemaps;

import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

/** Receiver of Heatmap configuration options. */
interface HeatmapOptionsSink {
  void setWeightedData(List<WeightedLatLng> weightedData);

  void setGradient(Gradient gradient);

  void setMaxIntensity(double maxIntensity);

  void setOpacity(double opacity);

  void setRadius(int radius);
}
