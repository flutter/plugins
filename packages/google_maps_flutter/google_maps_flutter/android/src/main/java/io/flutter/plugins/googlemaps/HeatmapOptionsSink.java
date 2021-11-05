// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.maps.android.heatmaps.Gradient;
import com.google.maps.android.heatmaps.WeightedLatLng;
import java.util.List;

/** Receiver of Heatmap configuration options. */
interface HeatmapOptionsSink {

  void setPoints(List<WeightedLatLng> points);

  void setGradient(Gradient gradient);

  void setOpacity(double opacity);

  void setRadius(int radius);

  void setFadeIn(boolean fadeIn);

  void setTransparency(float transparency);

  void setVisible(boolean visible);

  void setZIndex(float zIndex);
}
