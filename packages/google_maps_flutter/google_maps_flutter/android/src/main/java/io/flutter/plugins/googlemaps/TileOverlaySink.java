// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import com.google.android.gms.maps.model.TileProvider;

/** Receiver of TileOverlayOptions configuration. */
interface TileOverlaySink {
  void setFadeIn(boolean fadeIn);

  void setTransparency(float transparency);

  void setZIndex(float zIndex);

  void setVisible(boolean visible);

  void setTileProvider(TileProvider tileProvider);
}
