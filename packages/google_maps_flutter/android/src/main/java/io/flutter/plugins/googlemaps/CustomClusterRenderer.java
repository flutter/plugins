// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.clustering.ClusterManager;
import com.google.maps.android.clustering.view.DefaultClusterRenderer;

public class CustomClusterRenderer extends DefaultClusterRenderer<ClusterItemController> {

  private final Context context;

  public CustomClusterRenderer(
      Context context, GoogleMap map, ClusterManager<ClusterItemController> clusterManager) {
    super(context, map, clusterManager);
    this.context = context;
  }

  @Override
  protected void onBeforeClusterItemRendered(
      ClusterItemController item, MarkerOptions markerOptions) {
    markerOptions.icon(item.getIcon()).snippet(item.getTitle());
  }
}
