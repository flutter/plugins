// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart';

// GApplication* g_application_get_default();
typedef _gApplicationGetDefaultC = IntPtr Function();
typedef _gApplicationGetDefaultDart = int Function();

// const gchar* g_application_get_application_id(GApplication* application);
typedef _gApplicationGetApplicationIdC = Pointer<Utf8> Function(IntPtr);
typedef _gApplicationGetApplicationIdDart = Pointer<Utf8> Function(int);

/// Gets the application ID for this app.
String? getApplicationId() {
  DynamicLibrary gio;
  try {
    gio = DynamicLibrary.open('libgio-2.0.so');
  } on ArgumentError {
    return null;
  }
  final _gApplicationGetDefaultDart gApplicationGetDefault =
      gio.lookupFunction<_gApplicationGetDefaultC, _gApplicationGetDefaultDart>(
          'g_application_get_default');
  final int app = gApplicationGetDefault();
  if (app == 0) {
    return null;
  }

  final _gApplicationGetApplicationIdDart gApplicationGetApplicationId =
      gio.lookupFunction<_gApplicationGetApplicationIdC,
              _gApplicationGetApplicationIdDart>(
          'g_application_get_application_id');
  final Pointer<Utf8> appId = gApplicationGetApplicationId(app);
  if (appId == null) {
    return null;
  }

  return appId.toDartString();
}
