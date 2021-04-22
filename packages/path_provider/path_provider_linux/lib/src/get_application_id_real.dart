// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart';

// GApplication* g_application_get_default();
typedef g_application_get_default_c = IntPtr Function();
typedef g_application_get_default_dart = int Function();

// const gchar* g_application_get_application_id(GApplication* application);
typedef g_application_get_application_id_c = Pointer<Utf8> Function(IntPtr);
typedef g_application_get_application_id_dart = Pointer<Utf8> Function(int);

/// Gets the application ID for this app.
String? getApplicationId() {
  DynamicLibrary gio;
  try {
    gio = DynamicLibrary.open('libgio-2.0.so');
  } on ArgumentError {
    return null;
  }
  var g_application_get_default = gio.lookupFunction<
      g_application_get_default_c,
      g_application_get_default_dart>('g_application_get_default');
  var app = g_application_get_default();
  if (app == 0) return null;

  var g_application_get_application_id = gio.lookupFunction<
          g_application_get_application_id_c,
          g_application_get_application_id_dart>(
      'g_application_get_application_id');
  var app_id = g_application_get_application_id(app);
  if (app_id == null) return null;

  return app_id.toDartString();
}
