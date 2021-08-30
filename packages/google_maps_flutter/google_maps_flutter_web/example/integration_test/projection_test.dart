// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// These tests render an app with a small map widget, and use its map controller
// to compute values of the default projection.

// (Tests methods that can't be mocked in `google_maps_controller_test.dart`)

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps/google_maps.dart' as gmaps;
import 'package:google_maps_flutter/google_maps_flutter.dart' show GoogleMap, GoogleMapController;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' hide GoogleMapController;
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// This value is used when comparing long~num, like
// LatLng values.
const _acceptableDelta = 0.0000000001;

/// Test Google Map Controller
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('initializes', () {
    final LatLng center = LatLng(43.3078, -5.6958);
    final Size size = Size(320, 240);

    late Completer<GoogleMapController> controllerCompleter;
    late void Function(GoogleMapController) onMapCreated;

    setUp(() {
      controllerCompleter = Completer<GoogleMapController>();
      onMapCreated = (GoogleMapController mapController) {
        controllerCompleter.complete(mapController);
      };
    });

    testWidgets('target of map is in center of widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        CenteredMap(
          initialCamera: CameraPosition(
            target: center,
            zoom: 14,
          ),
          size: size,
          onMapCreated: onMapCreated,
        ),
        Duration(milliseconds: 500),
      );

      final GoogleMapController controller = await controllerCompleter.future;

      // This is needed to kick-off the rendering of the Map flutter widget
      await tester.pumpAndSettle(Duration(milliseconds: 500));

      // Find the element of the map, and attach a Resize observer to it...
      

      // This is needed to let the JS map do its thing
      await Future.delayed(Duration(milliseconds: 5000));

      final ScreenCoordinate coords = await controller.getScreenCoordinate(center);

      print(coords);

      // final ScreenCoordinate coords = (await tester.runAsync(() {
      //   print('About to wait...');
      //   return Future.delayed(Duration(seconds: 10), () {
      //     print('10 seconds have passed...');
      //     return controller.getScreenCoordinate(center);
      //   });
      // }, additionalTime: Duration(seconds: 10)))!;

      expect(coords.x, size.width / 2);
      expect(coords.y, size.height / 2);
    });
  });
}

/// Renders a Map widget centered on the screen.
/// This depends in `package:google_maps_flutter` to work.
class CenteredMap extends StatelessWidget {

  const CenteredMap({
    required this.initialCamera,
    required this.size,
    required this.onMapCreated,
    Key? key
  }) : super(key: key);

  /// A function that receives the [GoogleMapController] of the Map widget once initialized.
  final void Function(GoogleMapController)? onMapCreated;
  /// The size of the rendered map widget.
  final Size size;
  /// The initial camera position (center + zoom level) of the Map widget.
  final CameraPosition initialCamera;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox.fromSize(
            size: size,
            child: GoogleMap(
              initialCameraPosition: initialCamera,
              onMapCreated: onMapCreated,
            ),
          ),
        ),
      ),
    );
  }
}
