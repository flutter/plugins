// Copyright 2013 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ffi';
import 'package:ffi/ffi.dart';

// GApplication* g_application_get_default();
typedef _g_application_get_default_c = IntPtr Function();
typedef _g_application_get_default_dart = int Function();

// const gchar* g_application_get_application_id(GApplication* application);
typedef _g_application_get_application_id_c = Pointer<Utf8> Function(IntPtr);
typedef _g_application_get_application_id_dart = Pointer<Utf8> Function(int);

/// Gets the application ID for this app.
String? getApplicationId() {
  DynamicLibrary gio;
  try {
    gio = DynamicLibrary.open('libgio-2.0.so');
  } on ArgumentError {
    return null;
  }
  var _g_application_get_default = gio.lookupFunction<
      _g_application_get_default_c,
      _g_application_get_default_dart>('g_application_get_default');
  var app = _g_application_get_default();
  if (app == 0) return null;

  var _g_application_get_application_id = gio.lookupFunction<
          _g_application_get_application_id_c,
          _g_application_get_application_id_dart>(
      'g_application_get_application_id');
  var app_id = _g_application_get_application_id(app);
  if (app_id == null) return null;

  return app_id.toDartString();
}
