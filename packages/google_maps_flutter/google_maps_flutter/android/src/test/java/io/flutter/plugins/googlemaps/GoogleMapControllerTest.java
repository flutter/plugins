// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import android.content.Context;
import android.os.Build;
import androidx.activity.ComponentActivity;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.Robolectric;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class GoogleMapControllerTest {

  private Context context;
  private ComponentActivity activity;
  private GoogleMapController googleMapController;

  @Mock BinaryMessenger mockMessenger;
  @Mock GoogleMap mockGoogleMap;

  @Before
  public void before() {
    MockitoAnnotations.initMocks(this);
    context = ApplicationProvider.getApplicationContext();
    activity = Robolectric.setupActivity(ComponentActivity.class);
    googleMapController =
        new GoogleMapController(0, context, mockMessenger, activity::getLifecycle, null);
    googleMapController.init();
  }

  @Test
  public void DisposeReleaseTheMap() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    assertTrue(googleMapController != null);
    googleMapController.dispose();
    assertNull(googleMapController.getView());
  }

  @Test
  public void OnDestroyReleaseTheMap() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    assertTrue(googleMapController != null);
    googleMapController.onDestroy(activity);
    assertNull(googleMapController.getView());
  }

  @Test
  public void InvalidateMapAfterMethodCalls() throws InterruptedException {
    String[] methodsThatTriggerInvalidation = {
      "markers#update",
      "polygons#update",
      "polylines#update",
      "circles#update",
      "map#setStyle",
      "tileOverlays#update",
      "tileOverlays#clearTileCache"
    };

    for (String methodName : methodsThatTriggerInvalidation) {
      googleMapController =
          new GoogleMapController(0, context, mockMessenger, activity::getLifecycle, null);
      googleMapController.init();

      mockGoogleMap = mock(GoogleMap.class);
      googleMapController.onMapReady(mockGoogleMap);

      MethodChannel.Result result = mock(MethodChannel.Result.class);
      System.out.println(methodName);
      googleMapController.onMethodCall(
          new MethodCall(methodName, new HashMap<String, Object>()), result);

      ArgumentCaptor<GoogleMap.OnMapLoadedCallback> argument =
          ArgumentCaptor.forClass(GoogleMap.OnMapLoadedCallback.class);
      verify(mockGoogleMap).setOnMapLoadedCallback(argument.capture());

      MapView mapView = mock(MapView.class);
      googleMapController.setView(mapView);

      verify(mapView, never()).invalidate();
      argument.getValue().onMapLoaded();
      verify(mapView).invalidate();
    }
  }

  @Test
  public void InvalidateMapOnceAfterMethodCall() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);

    MethodChannel.Result result = mock(MethodChannel.Result.class);
    googleMapController.onMethodCall(
        new MethodCall("markers#update", new HashMap<String, Object>()), result);
    googleMapController.onMethodCall(
        new MethodCall("polygons#update", new HashMap<String, Object>()), result);

    ArgumentCaptor<GoogleMap.OnMapLoadedCallback> argument =
        ArgumentCaptor.forClass(GoogleMap.OnMapLoadedCallback.class);
    verify(mockGoogleMap).setOnMapLoadedCallback(argument.capture());

    MapView mapView = mock(MapView.class);
    googleMapController.setView(mapView);

    verify(mapView, never()).invalidate();
    argument.getValue().onMapLoaded();
    verify(mapView).invalidate();
  }

  @Test
  public void MethodCalledAfterControllerIsDestroyed() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    MethodChannel.Result result = mock(MethodChannel.Result.class);
    googleMapController.onMethodCall(
        new MethodCall("markers#update", new HashMap<String, Object>()), result);

    ArgumentCaptor<GoogleMap.OnMapLoadedCallback> argument =
        ArgumentCaptor.forClass(GoogleMap.OnMapLoadedCallback.class);
    verify(mockGoogleMap).setOnMapLoadedCallback(argument.capture());

    MapView mapView = mock(MapView.class);
    googleMapController.setView(mapView);
    googleMapController.onDestroy(activity);

    argument.getValue().onMapLoaded();
    verify(mapView, never()).invalidate();
  }
}
