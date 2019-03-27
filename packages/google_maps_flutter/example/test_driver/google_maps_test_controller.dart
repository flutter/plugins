// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/services.dart';

class GoogleMapTestController {
  GoogleMapTestController(this._channel);

  final MethodChannel _channel;

  Future<GoogleMapStateSnapshot> mapStateSnapshot() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final List<dynamic> stateSnapshot =
        await _channel.invokeMethod('map#stateSnapshot');
    return GoogleMapStateSnapshot(
      compassEnabled: stateSnapshot[0],
      minZoomPreference: stateSnapshot[1],
      maxZoomPreference: stateSnapshot[2],
    );
  }
}

class GoogleMapStateSnapshot {
  GoogleMapStateSnapshot({
    this.compassEnabled,
    this.minZoomPreference,
    this.maxZoomPreference,
  });

  final bool compassEnabled;
  final double minZoomPreference;
  final double maxZoomPreference;
}
