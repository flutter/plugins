// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.when;

import android.content.Context;
import android.os.Build;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.maps.android.collections.MarkerManager;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodCodec;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class MarkersControllerTest {
  private Context context;

  @Before
  public void setUp() {
    context = ApplicationProvider.getApplicationContext();
  }

  @Test
  public void controller_OnMarkerDragStart() {
    final MethodChannel methodChannel =
        spy(new MethodChannel(mock(BinaryMessenger.class), "no-name", mock(MethodCodec.class)));
    final ClusterManagersController clusterManagersController =
        new ClusterManagersController(methodChannel, context);
    final MarkersController controller =
        new MarkersController(methodChannel, clusterManagersController);
    final GoogleMap googleMap = mock(GoogleMap.class);

    final MarkerManager markerManager = new MarkerManager(googleMap);
    final MarkerManager.Collection markerCollection = markerManager.newCollection();
    controller.setCollection(markerCollection);
    clusterManagersController.init(googleMap, markerManager);

    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);
    final Map<String, String> markerOptions = new HashMap();
    markerOptions.put("markerId", googleMarkerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions);
    controller.addMarkers(markers);
    controller.onMarkerDragStart(googleMarkerId, latLng);

    final List<Double> points = new ArrayList();
    points.add(latLng.latitude);
    points.add(latLng.longitude);

    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", googleMarkerId);
    data.put("position", points);
    Mockito.verify(methodChannel).invokeMethod("marker#onDragStart", data);
  }

  @Test
  public void controller_OnMarkerDragEnd() {
    final MethodChannel methodChannel =
        spy(new MethodChannel(mock(BinaryMessenger.class), "no-name", mock(MethodCodec.class)));
    final ClusterManagersController clusterManagersController =
        new ClusterManagersController(methodChannel, context);
    final MarkersController controller =
        new MarkersController(methodChannel, clusterManagersController);
    final GoogleMap googleMap = mock(GoogleMap.class);

    final MarkerManager markerManager = new MarkerManager(googleMap);
    final MarkerManager.Collection markerCollection = markerManager.newCollection();
    controller.setCollection(markerCollection);
    clusterManagersController.init(googleMap, markerManager);

    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);
    final Map<String, String> markerOptions = new HashMap();
    markerOptions.put("markerId", googleMarkerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions);
    controller.addMarkers(markers);
    controller.onMarkerDragEnd(googleMarkerId, latLng);

    final List<Double> points = new ArrayList();
    points.add(latLng.latitude);
    points.add(latLng.longitude);

    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", googleMarkerId);
    data.put("position", points);
    Mockito.verify(methodChannel).invokeMethod("marker#onDragEnd", data);
  }

  @Test
  public void controller_OnMarkerDrag() {
    final MethodChannel methodChannel =
        spy(new MethodChannel(mock(BinaryMessenger.class), "no-name", mock(MethodCodec.class)));
    final ClusterManagersController clusterManagersController =
        new ClusterManagersController(methodChannel, context);
    final MarkersController controller =
        new MarkersController(methodChannel, clusterManagersController);
    final GoogleMap googleMap = mock(GoogleMap.class);

    final MarkerManager markerManager = new MarkerManager(googleMap);
    final MarkerManager.Collection markerCollection = markerManager.newCollection();
    controller.setCollection(markerCollection);
    clusterManagersController.init(googleMap, markerManager);

    final Marker marker = mock(Marker.class);

    final String googleMarkerId = "abc123";

    when(marker.getId()).thenReturn(googleMarkerId);
    when(googleMap.addMarker(any(MarkerOptions.class))).thenReturn(marker);

    final LatLng latLng = new LatLng(1.1, 2.2);
    final Map<String, String> markerOptions = new HashMap();
    markerOptions.put("markerId", googleMarkerId);

    final List<Object> markers = Arrays.<Object>asList(markerOptions);
    controller.addMarkers(markers);
    controller.onMarkerDrag(googleMarkerId, latLng);

    final List<Double> points = new ArrayList();
    points.add(latLng.latitude);
    points.add(latLng.longitude);

    final Map<String, Object> data = new HashMap<>();
    data.put("markerId", googleMarkerId);
    data.put("position", points);
    Mockito.verify(methodChannel).invokeMethod("marker#onDrag", data);
  }
}
