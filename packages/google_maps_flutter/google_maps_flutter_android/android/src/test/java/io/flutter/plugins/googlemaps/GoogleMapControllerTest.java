// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

import android.content.Context;
import android.os.Build;
import android.os.Handler;
import androidx.activity.ComponentActivity;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.OnMapsSdkInitializedCallback;
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

  @Test
  public void DestroyMapImmediatelyWithLatestRenderer() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    assertTrue(googleMapController != null);

    MapView mapView = mock(MapView.class);
    MapsInitializerFunction initializer = mock(MapsInitializerFunction.class);

    googleMapController.setInitializer(initializer);
    googleMapController.setView(mapView);

    googleMapController.onDestroy(activity);
    verify(mapView, never()).onDestroy(); // mapView should not be destroyed before renderer check

    ArgumentCaptor<OnMapsSdkInitializedCallback> argument =
        ArgumentCaptor.forClass(OnMapsSdkInitializedCallback.class);
    verify(initializer)
        .initialize(
            any(Context.class),
            isNull(),
            argument.capture()); // verify MapInitializer is called to get active renderer
    argument.getValue().onMapsSdkInitialized(MapsInitializer.Renderer.LATEST);
    verify(mapView).onDestroy(); // mapView should be destroyed immediately
  }

  @Test
  public void DelayMapDestructionWithLegacyRenderer() throws InterruptedException {
    googleMapController.onMapReady(mockGoogleMap);
    assertTrue(googleMapController != null);

    MapView mapView = mock(MapView.class);
    MapsInitializerFunction initializer = mock(MapsInitializerFunction.class);
    Handler handler = mock(Handler.class);

    googleMapController.setInitializer(initializer);
    googleMapController.setView(mapView);
    googleMapController.setHandler(
        handler); // to be able to use postDelayed in a single threaded unit test

    googleMapController.onDestroy(activity);
    verify(mapView, never()).onDestroy(); // mapView should not be destroyed before renderer check

    ArgumentCaptor<OnMapsSdkInitializedCallback> initializedCallback =
        ArgumentCaptor.forClass(OnMapsSdkInitializedCallback.class);
    verify(initializer)
        .initialize(
            any(Context.class),
            isNull(),
            initializedCallback
                .capture()); // verify MapInitializer is called to get active renderer

    initializedCallback.getValue().onMapsSdkInitialized(MapsInitializer.Renderer.LEGACY);
    verify(handler, never())
        .post(any(Runnable.class)); // handler should not immediately destroy mapView

    ArgumentCaptor<Runnable> runnable = ArgumentCaptor.forClass(Runnable.class);
    verify(handler)
        .postDelayed(
            runnable.capture(),
            anyLong()); // verify handler is called to destroy mapView after delay
    runnable.getValue().run();

    verify(mapView).onDestroy(); // mapView should be destroyed once the delayed callback is called
  }
}
