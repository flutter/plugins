// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package androidx.test.espresso.flutter.internal.protocol.impl;

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.base.Strings.isNullOrEmpty;

import android.util.Log;
import android.view.View;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;

/** Util class for dealing with Dart VM service protocols. */
public final class DartVmServiceUtil {
  private static final String TAG = DartVmServiceUtil.class.getSimpleName();

  /**
   * Converts the Dart VM observatory http server URL to the service protocol WebSocket URL.
   *
   * @param observatoryUrl The Dart VM http server URL that can be converted to a service protocol
   *     URI.
   */
  public static URI getServiceProtocolUri(String observatoryUrl) {
    if (isNullOrEmpty(observatoryUrl)) {
      throw new RuntimeException(
          "Dart VM Observatory is not enabled. "
              + "Please make sure your Flutter app is running under debug mode.");
    }

    try {
      new URL(observatoryUrl);
    } catch (MalformedURLException e) {
      throw new RuntimeException(
          String.format("Dart VM Observatory url %s is malformed.", observatoryUrl), e);
    }

    // Constructs the service protocol URL based on the Observatory http url.
    // For example, http://127.0.0.1:39694/qsnVeidc78Y=/ -> ws://127.0.0.1:39694/qsnVeidc78Y=/ws.
    int schemaIndex = observatoryUrl.indexOf(":");
    String serviceProtocolUri = "ws" + observatoryUrl.substring(schemaIndex);
    if (!observatoryUrl.endsWith("/")) {
      serviceProtocolUri += "/";
    }
    serviceProtocolUri += "ws";

    Log.i(TAG, "Dart VM service protocol runs at uri: " + serviceProtocolUri);
    try {
      return new URI(serviceProtocolUri);
    } catch (URISyntaxException e) {
      // Should never happen.
      throw new RuntimeException("Illegal Dart VM service protocol URI: " + serviceProtocolUri, e);
    }
  }

  /** Gets the Dart isolate ID for the given {@code flutterView}. */
  public static String getDartIsolateId(View flutterView) {
    checkNotNull(flutterView, "The Flutter View instance cannot be null.");
    String uiIsolateId = getDartExecutor(flutterView).getIsolateServiceId();
    Log.d(
        TAG,
        String.format(
            "Dart isolate ID for the Flutter View [id: %d]: %s.",
            flutterView.getId(), uiIsolateId));
    return uiIsolateId;
  }

  /** Gets the Dart executor for the given {@code flutterView}. */
  @SuppressWarnings("deprecation")
  public static DartExecutor getDartExecutor(View flutterView) {
    checkNotNull(flutterView, "The Flutter View instance cannot be null.");
    // Flutter's embedding is in the phase of rewriting/refactoring. Let's be compatible with both
    // the old and the new FlutterView classes.
    if (flutterView instanceof io.flutter.view.FlutterView) {
      return ((io.flutter.view.FlutterView) flutterView).getDartExecutor();
    } else if (flutterView instanceof io.flutter.embedding.android.FlutterView) {
      FlutterEngine flutterEngine =
          ((io.flutter.embedding.android.FlutterView) flutterView).getAttachedFlutterEngine();
      if (flutterEngine == null) {
        throw new FlutterProtocolException(
            String.format(
                "No Flutter engine attached to the Flutter view [id: %d].", flutterView.getId()));
      }
      return flutterEngine.getDartExecutor();
    } else {
      throw new FlutterProtocolException(
          String.format("This is not a Flutter View instance [id: %d].", flutterView.getId()));
    }
  }
}
