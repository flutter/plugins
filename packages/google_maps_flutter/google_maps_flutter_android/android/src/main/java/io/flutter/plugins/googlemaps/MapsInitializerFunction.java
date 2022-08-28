// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapsSdkInitializedCallback;

@FunctionalInterface
public interface MapsInitializerFunction {
  int initialize(
      @NonNull Context context,
      @Nullable MapsInitializer.Renderer preferredRenderer,
      @Nullable OnMapsSdkInitializedCallback callback);
}
