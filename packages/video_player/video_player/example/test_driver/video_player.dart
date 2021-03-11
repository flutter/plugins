// Copyright 2019, the Chromium project authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(egarciad): Remove once Flutter driver is migrated to null safety.
// @dart = 2.9

import 'package:flutter_driver/driver_extension.dart';
import 'package:video_player_example/main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}
