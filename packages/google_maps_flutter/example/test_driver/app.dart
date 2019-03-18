// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_driver/driver_extension.dart';
import 'package:google_maps_flutter_example/main.dart' as app;

import 'device_model.dart';

void main() {
  enableFlutterDriverExtension(handler: modelName);
  app.main();
}
