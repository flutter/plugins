// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../wifi_info_flutter_platform_interface.dart';

/// Convert a String to a LocationAuthorizationStatus value.
LocationAuthorizationStatus parseLocationAuthorizationStatus(String result) {
  return LocationAuthorizationStatus.values.firstWhere(
    (LocationAuthorizationStatus status) => result == describeEnum(status),
    orElse: () => LocationAuthorizationStatus.unknown,
  );
}
