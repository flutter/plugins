// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'google_map_inspector.dart';
import 'test_widgets.dart';

const LatLng _kInitialMapCenter = LatLng(0, 0);
const CameraPosition _kInitialCameraPosition =
    CameraPosition(target: _kInitialMapCenter);

void main() {
  final Completer<String> allTestsCompleter = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => allTestsCompleter.future);

  tearDownAll(() => allTestsCompleter.complete(null));

  test('testCompassToggle', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool compassEnabled = await inspector.isCompassEnabled();
    expect(compassEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    compassEnabled = await inspector.isCompassEnabled();
    expect(compassEnabled, true);
  });

  test('updateMinMaxZoomLevels', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    const MinMaxZoomPreference initialZoomLevel = MinMaxZoomPreference(2, 4);
    const MinMaxZoomPreference finalZoomLevel = MinMaxZoomPreference(3, 8);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        minMaxZoomPreference: initialZoomLevel,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    MinMaxZoomPreference zoomLevel = await inspector.getMinMaxZoomLevels();
    expect(zoomLevel, equals(initialZoomLevel));

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        minMaxZoomPreference: finalZoomLevel,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    zoomLevel = await inspector.getMinMaxZoomLevels();
    expect(zoomLevel, equals(finalZoomLevel));
  });

  test('testZoomGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        zoomGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool zoomGesturesEnabled = await inspector.isZoomGesturesEnabled();
    expect(zoomGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        zoomGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    zoomGesturesEnabled = await inspector.isZoomGesturesEnabled();
    expect(zoomGesturesEnabled, true);
  });

  test('testRotateGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        rotateGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool rotateGesturesEnabled = await inspector.isRotateGesturesEnabled();
    expect(rotateGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        rotateGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    rotateGesturesEnabled = await inspector.isRotateGesturesEnabled();
    expect(rotateGesturesEnabled, true);
  });

  test('testTiltGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        tiltGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool tiltGesturesEnabled = await inspector.isTiltGesturesEnabled();
    expect(tiltGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        tiltGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    tiltGesturesEnabled = await inspector.isTiltGesturesEnabled();
    expect(tiltGesturesEnabled, true);
  });

  test('testScrollGesturesEnabled', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        scrollGesturesEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool scrollGesturesEnabled = await inspector.isScrollGesturesEnabled();
    expect(scrollGesturesEnabled, false);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        scrollGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    scrollGesturesEnabled = await inspector.isScrollGesturesEnabled();
    expect(scrollGesturesEnabled, true);
  });

  test('testGetVisibleRegion', () async {
    final Key key = GlobalKey();
    final LatLngBounds zeroLatLngBounds = LatLngBounds(
        southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));

    final Completer<GoogleMapController> mapControllerCompleter =
        Completer<GoogleMapController>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          mapControllerCompleter.complete(controller);
        },
      ),
    ));
    final GoogleMapController mapController =
        await mapControllerCompleter.future;

    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    await Future<dynamic>.delayed(const Duration(seconds: 3));

    final LatLngBounds firstVisibleRegion =
        await mapController.getVisibleRegion();

    expect(firstVisibleRegion, isNotNull);
    expect(firstVisibleRegion.southwest, isNotNull);
    expect(firstVisibleRegion.northeast, isNotNull);
    expect(firstVisibleRegion, isNot(zeroLatLngBounds));
    expect(firstVisibleRegion.contains(_kInitialMapCenter), isTrue);

    const LatLng southWest = LatLng(60, 75);
    const LatLng northEast = LatLng(65, 80);
    final LatLng newCenter = LatLng(
      (northEast.latitude + southWest.latitude) / 2,
      (northEast.longitude + southWest.longitude) / 2,
    );

    expect(firstVisibleRegion.contains(northEast), isFalse);
    expect(firstVisibleRegion.contains(southWest), isFalse);

    final LatLngBounds latLngBounds =
        LatLngBounds(southwest: southWest, northeast: northEast);

    // TODO(iskakaushik): non-zero padding is needed for some device configurations
    // https://github.com/flutter/flutter/issues/30575
    final double padding = 0;
    await mapController
        .moveCamera(CameraUpdate.newLatLngBounds(latLngBounds, padding));

    final LatLngBounds secondVisibleRegion =
        await mapController.getVisibleRegion();

    expect(secondVisibleRegion, isNotNull);
    expect(secondVisibleRegion.southwest, isNotNull);
    expect(secondVisibleRegion.northeast, isNotNull);
    expect(secondVisibleRegion, isNot(zeroLatLngBounds));

    expect(firstVisibleRegion, isNot(secondVisibleRegion));
    expect(secondVisibleRegion.contains(newCenter), isTrue);
  });

  test('testMyLocationButtonToggle', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool myLocationButtonEnabled = await inspector.isMyLocationButtonEnabled();
    expect(myLocationButtonEnabled, true);

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    myLocationButtonEnabled = await inspector.isMyLocationButtonEnabled();
    expect(myLocationButtonEnabled, false);
  });

  test('testMyLocationButton initial value false', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    final bool myLocationButtonEnabled =
        await inspector.isMyLocationButtonEnabled();
    expect(myLocationButtonEnabled, false);
  });

  test('testMyLocationButton initial value true', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: true,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    final bool myLocationButtonEnabled =
        await inspector.isMyLocationButtonEnabled();
    expect(myLocationButtonEnabled, true);
  });

  test('testSetMapStyle valid Json String', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final GoogleMapController controller = await controllerCompleter.future;
    final String mapStyle =
        '[{"elementType":"geometry","stylers":[{"color":"#242f3e"}]}]';
    await controller.setMapStyle(mapStyle);
  });

  test('testSetMapStyle invalid Json String', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final GoogleMapController controller = await controllerCompleter.future;

    try {
      await controller.setMapStyle('invalid_value');
      fail('expected MapStyleException');
    } on MapStyleException catch (e) {
      expect(e.cause,
          'The data couldn’t be read because it isn’t in the correct format.');
    }
  });

  test('testSetMapStyle null string', () async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          controllerCompleter.complete(controller);
        },
      ),
    ));

    final GoogleMapController controller = await controllerCompleter.future;
    await controller.setMapStyle(null);
  });
}
