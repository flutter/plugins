// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_driver/driver_extension.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../lib/main.dart' as app;

Future<String> _handler(String message) async {
  final GoogleMapController controller = await app.controller.future;

  if (message == 'startRecordingActions') {
    await controller.startRecordingActions();
    return null;
  }

  if (message == 'getRecordedActions') {
    final List<String> recordedActions = await controller.getRecordedActions();
    return recordedActions.join(',');
  }

  if (message == 'clearRecordedActions') {
    await controller.clearRecordedActions();
    return null;
  }

  if (message == 'stopRecordingActions') {
    await controller.stopRecordingActions();
    return null;
  }

  return null;
}

void main() {
  enableFlutterDriverExtension(handler: _handler);
  app.main();
}
