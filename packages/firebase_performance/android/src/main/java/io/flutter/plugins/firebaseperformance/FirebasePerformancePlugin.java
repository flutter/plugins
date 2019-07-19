// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.firebaseperformance;

import android.util.SparseArray;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** FirebasePerformancePlugin */
public class FirebasePerformancePlugin implements MethodChannel.MethodCallHandler {
  private static final String CHANNEL_NAME = "plugins.flutter.io/firebase_performance";

  private static final SparseArray<MethodChannel.MethodCallHandler> handlers = new SparseArray<>();

  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), CHANNEL_NAME);
    channel.setMethodCallHandler(new FirebasePerformancePlugin());
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    if (call.method.equals("FirebasePerformance#instance")) {
      handlers.clear();
      FlutterFirebasePerformance.getInstance(call, result);
    } else {
      final MethodChannel.MethodCallHandler handler = getHandler(call);

      if (handler != null) {
        handler.onMethodCall(call, result);
      } else {
        result.notImplemented();
      }
    }
  }

  static void addHandler(final int handle, final MethodChannel.MethodCallHandler handler) {
    if (handlers.get(handle) != null) {
      final String message = String.format("Object for handle already exists: %s", handle);
      throw new IllegalArgumentException(message);
    }

    handlers.put(handle, handler);
  }

  static void removeHandler(final int handle) {
    handlers.remove(handle);
  }

  private static MethodChannel.MethodCallHandler getHandler(final MethodCall call) {
    final Integer handle = call.argument("handle");

    if (handle == null) return null;
    return handlers.get(handle);
  }
}
