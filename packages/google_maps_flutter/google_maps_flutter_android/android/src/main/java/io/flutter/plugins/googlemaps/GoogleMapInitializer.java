// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.googlemaps;

import android.content.Context;
import androidx.annotation.VisibleForTesting;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.MapsInitializer.Renderer;
import com.google.android.gms.maps.OnMapsSdkInitializedCallback;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/** GoogleMaps initializer used to initialize the Google Maps SDK with preferred settings. */
final class GoogleMapInitializer
    implements OnMapsSdkInitializedCallback, MethodChannel.MethodCallHandler {
  private final MethodChannel methodChannel;
  private final Context context;
  private static MethodChannel.Result initializationResult;
  private boolean rendererInitialized = false;

  GoogleMapInitializer(Context context, BinaryMessenger binaryMessenger) {
    this.context = context;

    methodChannel =
        new MethodChannel(binaryMessenger, "plugins.flutter.dev/google_maps_android_initializer");
    methodChannel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "initializer#preferRenderer":
        {
          String preferredRenderer = (String) call.argument("value");
          initializeWithPreferredRenderer(preferredRenderer, result);
          break;
        }
      default:
        result.notImplemented();
    }
  }

  /**
   * Initializes map renderer to with preferred renderer type. Renderer can be initialized only once
   * per application context.
   *
   * <p>Supported renderer types are "latest", "legacy" and "default".
   */
  private void initializeWithPreferredRenderer(
      String preferredRenderer, MethodChannel.Result result) {
    if (rendererInitialized || initializationResult != null) {
      result.error(
          "Renderer already initialized", "Renderer initialization called multiple times", null);
    } else {
      initializationResult = result;
      switch (preferredRenderer) {
        case "latest":
          initializeWithRendererRequest(Renderer.LATEST);
          break;
        case "legacy":
          initializeWithRendererRequest(Renderer.LEGACY);
          break;
        case "default":
          initializeWithRendererRequest(null);
          break;
        default:
          initializationResult.error(
              "Invalid renderer type",
              "Renderer initialization called with invalid renderer type",
              null);
          initializationResult = null;
      }
    }
  }

  /**
   * Initializes map renderer to with preferred renderer type.
   *
   * <p>This method is visible for testing purposes only and should never be used outside this
   * class.
   */
  @VisibleForTesting
  public void initializeWithRendererRequest(MapsInitializer.Renderer renderer) {
    MapsInitializer.initialize(context, renderer, this);
  }

  /** Is called by Google Maps SDK to determine which version of the renderer was initialized. */
  @Override
  public void onMapsSdkInitialized(MapsInitializer.Renderer renderer) {
    rendererInitialized = true;
    if (initializationResult != null) {
      switch (renderer) {
        case LATEST:
          initializationResult.success("latest");
          break;
        case LEGACY:
          initializationResult.success("legacy");
          break;
        default:
          initializationResult.error(
              "Unknown renderer type", "Initialized with unknown renderer type", null);
      }
      initializationResult = null;
    }
  }
}
