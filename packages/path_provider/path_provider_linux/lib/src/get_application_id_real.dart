// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart';

// GApplication* g_application_get_default();
typedef _GApplicationGetDefaultC = IntPtr Function();
typedef _GApplicationGetDefaultDart = int Function();

// const gchar* g_application_get_application_id(GApplication* application);
typedef _GApplicationGetApplicationIdC = Pointer<Utf8> Function(IntPtr);
typedef _GApplicationGetApplicationIdDart = Pointer<Utf8> Function(int);

/// Gets the application ID for this app.
String? getApplicationId() {
  DynamicLibrary gio;
  try {
    gio = DynamicLibrary.open('libgio-2.0.so');
  } on ArgumentError {
    return null;
  }
  final _GApplicationGetDefaultDart gApplicationGetDefault =
      gio.lookupFunction<_GApplicationGetDefaultC, _GApplicationGetDefaultDart>(
          'g_application_get_default');
  final int app = gApplicationGetDefault();
  if (app == 0) {
    return null;
  }

  final _GApplicationGetApplicationIdDart gApplicationGetApplicationId =
      gio.lookupFunction<_GApplicationGetApplicationIdC,
              _GApplicationGetApplicationIdDart>(
          'g_application_get_application_id');
  final Pointer<Utf8> appId = gApplicationGetApplicationId(app);
  if (appId == null) {
    return null;
  }

  return appId.toDartString();
}
