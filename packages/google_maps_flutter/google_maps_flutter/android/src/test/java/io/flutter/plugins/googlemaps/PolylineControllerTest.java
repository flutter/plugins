// Copyright 2018 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;

import com.google.android.gms.internal.maps.zzz;
import com.google.android.gms.maps.model.Polyline;
import org.junit.Test;
import org.mockito.Mockito;

public class PolylineControllerTest {

  @Test
  public void controller_SetsStrokeDensity() {
    final zzz z = mock(zzz.class);
    final Polyline polyline = spy(new Polyline(z));

    final float density = 5;
    final float strokeWidth = 3;
    final PolylineController controller = new PolylineController(polyline, false, density);
    controller.setWidth(strokeWidth);

    Mockito.verify(polyline).setWidth(density * strokeWidth);
  }
}
