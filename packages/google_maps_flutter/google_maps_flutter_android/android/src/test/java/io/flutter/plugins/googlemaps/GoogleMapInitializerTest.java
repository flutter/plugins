// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import static org.mockito.Mockito.any;
import static org.mockito.Mockito.doNothing;
import static org.mockito.Mockito.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import android.content.Context;
import android.os.Build;
import androidx.test.core.app.ApplicationProvider;
import com.google.android.gms.maps.MapsInitializer.Renderer;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;
import org.robolectric.annotation.Config;

@RunWith(RobolectricTestRunner.class)
@Config(sdk = Build.VERSION_CODES.P)
public class GoogleMapInitializerTest {
  private GoogleMapInitializer googleMapInitializer;

  @Mock BinaryMessenger mockMessenger;

  @Before
  public void before() {
    MockitoAnnotations.openMocks(this);
    Context context = ApplicationProvider.getApplicationContext();
    googleMapInitializer = spy(new GoogleMapInitializer(context, mockMessenger));
  }

  @Test
  public void initializer_OnMapsSdkInitializedWithLatestRenderer() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(Renderer.LATEST);
    MethodChannel.Result result = mock(MethodChannel.Result.class);
    googleMapInitializer.onMethodCall(
        new MethodCall(
            "initializer#preferRenderer",
            new HashMap<String, Object>() {
              {
                put("value", "latest");
              }
            }),
        result);
    googleMapInitializer.onMapsSdkInitialized(Renderer.LATEST);
    verify(result, times(1)).success("latest");
    verify(result, never()).error(any(), any(), any());
  }

  @Test
  public void initializer_OnMapsSdkInitializedWithLegacyRenderer() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(Renderer.LEGACY);
    MethodChannel.Result result = mock(MethodChannel.Result.class);
    googleMapInitializer.onMethodCall(
        new MethodCall(
            "initializer#preferRenderer",
            new HashMap<String, Object>() {
              {
                put("value", "legacy");
              }
            }),
        result);
    googleMapInitializer.onMapsSdkInitialized(Renderer.LEGACY);
    verify(result, times(1)).success("legacy");
    verify(result, never()).error(any(), any(), any());
  }

  @Test
  public void initializer_onMethodCallWithUnknownRenderer() {
    doNothing().when(googleMapInitializer).initializeWithRendererRequest(Renderer.LEGACY);
    MethodChannel.Result result = mock(MethodChannel.Result.class);
    googleMapInitializer.onMethodCall(
        new MethodCall(
            "initializer#preferRenderer",
            new HashMap<String, Object>() {
              {
                put("value", "wrong_renderer");
              }
            }),
        result);
    verify(result, never()).success(any());
    verify(result, times(1)).error(eq("Invalid renderer type"), any(), any());
  }
}
