// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'google_maps_test_controller.dart';

const CameraPosition _kInitialCameraPosition =
    CameraPosition(target: LatLng(0, 0));

class GoogleMapTest extends StatefulWidget {
  GoogleMapTest(this.mapState, this._controllerCompleter);

  final _GoogleMapTestState mapState;
  final Completer<GoogleMapController> _controllerCompleter;

  @override
  _GoogleMapTestState createState() => mapState;
}

class _GoogleMapTestState extends State<GoogleMapTest> {
  bool _compassEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: _compassEnabled,
        onMapCreated: (GoogleMapController controller) {
          widget._controllerCompleter.complete(controller);
        },
      ),
    );
  }

  void toggleCompass() {
    setState(() {
      _compassEnabled = !_compassEnabled;
    });
  }
}

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);

  tearDownAll(() => allTestsCompleter.complete(null));

  _GoogleMapTestState mapTestState;
  GoogleMapController controller;
  GoogleMapTestController testController;

  setUp(() async {
    mapTestState = _GoogleMapTestState();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();
    runApp(GoogleMapTest(mapTestState, controllerCompleter));
    controller = await controllerCompleter.future;
    testController = GoogleMapTestController(controller.getMethodChannel());
  });

  test('testCompassToggle', () async {
    GoogleMapStateSnapshot mapStateSnapshot;

    mapStateSnapshot = await testController.mapStateSnapshot();
    expect(mapStateSnapshot.compassEnabled, false);

    mapTestState.toggleCompass();

    // This delay exists for platform channel propagation.
    await Future<void>.delayed(Duration(seconds: 1), () {});

    mapStateSnapshot = await testController.mapStateSnapshot();
    expect(mapStateSnapshot.compassEnabled, true);
  });
}
