// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:instrumentation_adapter/instrumentation_adapter.dart';
import '../test_driver/package_info.dart' as test;

void main() {
  InstrumentationAdapterFlutterBinding.ensureInitialized();
  test.main();
}
