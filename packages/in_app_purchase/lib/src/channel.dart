// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

/// Method channel for the plugin's platform<-->Dart calls.
const MethodChannel channel =
    MethodChannel('plugins.flutter.io/in_app_purchase');
