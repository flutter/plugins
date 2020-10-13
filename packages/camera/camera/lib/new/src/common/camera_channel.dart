// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

typedef CameraCallback = void Function(dynamic result);

// Non exported class
class CameraChannel {
  static final Map<int, dynamic> callbacks = <int, CameraCallback>{};

  static final MethodChannel channel = const MethodChannel(
    'flutter.plugins.io/camera',
  )..setMethodCallHandler(
      (MethodCall call) async {
        assert(call.method == 'handleCallback');

        final int handle = call.arguments['handle'];
        if (callbacks[handle] != null) callbacks[handle](call.arguments);
      },
    );

  static int nextHandle = 0;

  static void registerCallback(int handle, CameraCallback callback) {
    assert(handle != null);
    assert(CameraCallback != null);

    assert(!callbacks.containsKey(handle));
    callbacks[handle] = callback;
  }

  static void unregisterCallback(int handle) {
    assert(handle != null);
    callbacks.remove(handle);
  }
}
