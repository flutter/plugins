// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:e2e/e2e.dart';

import 'google_map_inspector.dart';

const LatLng _kInitialMapCenter = LatLng(0, 0);
const double _kInitialZoomLevel = 5;
const CameraPosition _kInitialCameraPosition =
    CameraPosition(target: _kInitialMapCenter, zoom: _kInitialZoomLevel);

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

  testWidgets('testCompassToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();
    await tester.pumpWidget(Directionality(
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

    await tester.pumpWidget(Directionality(
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

  testWidgets('testMapToolbarToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        mapToolbarEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool mapToolbarEnabled = await inspector.isMapToolbarEnabled();
    expect(mapToolbarEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        mapToolbarEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    mapToolbarEnabled = await inspector.isMapToolbarEnabled();
    expect(mapToolbarEnabled, Platform.isAndroid);
  });

  testWidgets('updateMinMaxZoomLevels', (WidgetTester tester) async {
    // The behaviors of setting min max zoom level on iOS and Android are different.
    // On iOS, when we get the min or max zoom level after setting the preference, the
    // min and max will be exactly the same as the value we set; on Android however,
    // the values we get do not equal to the value we set.
    //
    // Also, when we call zoomTo to set the zoom, on Android, it usually
    // honors the preferences that we set and the zoom cannot pass beyond the boundary.
    // On iOS, on the other hand, zoomTo seems to override the preferences.
    //
    // Thus we test iOS and Android a little differently here.
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();
    GoogleMapController controller;

    const MinMaxZoomPreference initialZoomLevel = MinMaxZoomPreference(4, 8);
    const MinMaxZoomPreference finalZoomLevel = MinMaxZoomPreference(6, 10);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        minMaxZoomPreference: initialZoomLevel,
        onMapCreated: (GoogleMapController c) async {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(c.channel);
          controller = c;
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;

    if (Platform.isIOS) {
      MinMaxZoomPreference zoomLevel = await inspector.getMinMaxZoomLevels();
      expect(zoomLevel, equals(initialZoomLevel));
    } else if (Platform.isAndroid) {
      await controller.moveCamera(CameraUpdate.zoomTo(15));
      await tester.pumpAndSettle();
      double zoomLevel = await inspector.getZoomLevel();
      expect(zoomLevel, equals(initialZoomLevel.maxZoom));

      await controller.moveCamera(CameraUpdate.zoomTo(1));
      await tester.pumpAndSettle();
      zoomLevel = await inspector.getZoomLevel();
      expect(zoomLevel, equals(initialZoomLevel.minZoom));
    }

    await tester.pumpWidget(Directionality(
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

    if (Platform.isIOS) {
      MinMaxZoomPreference zoomLevel = await inspector.getMinMaxZoomLevels();
      expect(zoomLevel, equals(finalZoomLevel));
    } else {
      await controller.moveCamera(CameraUpdate.zoomTo(15));
      await tester.pumpAndSettle();
      double zoomLevel = await inspector.getZoomLevel();
      expect(zoomLevel, equals(finalZoomLevel.maxZoom));

      await controller.moveCamera(CameraUpdate.zoomTo(1));
      await tester.pumpAndSettle();
      zoomLevel = await inspector.getZoomLevel();
      expect(zoomLevel, equals(finalZoomLevel.minZoom));
    }
  });

  testWidgets('testZoomGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
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

    await tester.pumpWidget(Directionality(
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

  testWidgets('testRotateGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
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

    await tester.pumpWidget(Directionality(
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

  testWidgets('testTiltGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
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

    await tester.pumpWidget(Directionality(
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

  testWidgets('testScrollGesturesEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
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

    await tester.pumpWidget(Directionality(
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

  testWidgets('testGetVisibleRegion', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final LatLngBounds zeroLatLngBounds = LatLngBounds(
        southwest: const LatLng(0, 0), northeast: const LatLng(0, 0));

    final Completer<GoogleMapController> mapControllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          mapControllerCompleter.complete(controller);
        },
      ),
    ));
    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    await tester.pumpAndSettle(const Duration(seconds: 3));
    final GoogleMapController mapController =
        await mapControllerCompleter.future;

    final LatLngBounds firstVisibleRegion =
        await mapController.getVisibleRegion();

    expect(firstVisibleRegion, isNotNull);
    expect(firstVisibleRegion.southwest, isNotNull);
    expect(firstVisibleRegion.northeast, isNotNull);
    expect(firstVisibleRegion, isNot(zeroLatLngBounds));
    expect(firstVisibleRegion.contains(_kInitialMapCenter), isTrue);

    // Making a new `LatLngBounds` about (10, 10) distance south west to the `firstVisibleRegion`.
    // The size of the `LatLngBounds` is 10 by 10.
    final LatLng southWest = LatLng(firstVisibleRegion.southwest.latitude - 20,
        firstVisibleRegion.southwest.longitude - 20);
    final LatLng northEast = LatLng(firstVisibleRegion.southwest.latitude - 10,
        firstVisibleRegion.southwest.longitude - 10);
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
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final LatLngBounds secondVisibleRegion =
        await mapController.getVisibleRegion();

    expect(secondVisibleRegion, isNotNull);
    expect(secondVisibleRegion.southwest, isNotNull);
    expect(secondVisibleRegion.northeast, isNotNull);
    expect(secondVisibleRegion, isNot(zeroLatLngBounds));

    expect(firstVisibleRegion, isNot(secondVisibleRegion));
    expect(secondVisibleRegion.contains(newCenter), isTrue);
  });

  testWidgets('testTraffic', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        trafficEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool isTrafficEnabled = await inspector.isTrafficEnabled();
    expect(isTrafficEnabled, true);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        trafficEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          fail("OnMapCreated should get called only once.");
        },
      ),
    ));

    isTrafficEnabled = await inspector.isTrafficEnabled();
    expect(isTrafficEnabled, false);
  });

  testWidgets('testBuildings', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        buildingsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    final bool isBuildingsEnabled = await inspector.isBuildingsEnabled();
    expect(isBuildingsEnabled, true);
  });

  // Location button tests are skipped in Android because we don't have location permission to test.
  testWidgets('testMyLocationButtonToggle', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
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

    await tester.pumpWidget(Directionality(
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
  }, skip: Platform.isAndroid);

  testWidgets('testMyLocationButton initial value false',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
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
  }, skip: Platform.isAndroid);

  testWidgets('testMyLocationButton initial value true',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
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
  }, skip: Platform.isAndroid);

  testWidgets('testSetMapStyle valid Json String', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
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

  testWidgets('testSetMapStyle invalid Json String',
      (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
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
      expect(e.cause, isNotNull);
    }
  });

  testWidgets('testSetMapStyle null string', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
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

  testWidgets('testGetLatLng', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
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

    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    final LatLng topLeft =
        await controller.getLatLng(const ScreenCoordinate(x: 0, y: 0));
    final LatLng northWest = LatLng(
      visibleRegion.northeast.latitude,
      visibleRegion.southwest.longitude,
    );

    expect(topLeft, northWest);
  });

  testWidgets('testGetZoomLevel', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
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

    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    await tester.pumpAndSettle(const Duration(seconds: 3));

    double zoom = await controller.getZoomLevel();
    expect(zoom, _kInitialZoomLevel);

    await controller.moveCamera(CameraUpdate.zoomTo(7));
    await tester.pumpAndSettle();
    zoom = await controller.getZoomLevel();
    expect(zoom, equals(7));
  });

  testWidgets('testScreenCoordinate', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
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

    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final LatLngBounds visibleRegion = await controller.getVisibleRegion();
    final LatLng northWest = LatLng(
      visibleRegion.northeast.latitude,
      visibleRegion.southwest.longitude,
    );
    final ScreenCoordinate topLeft =
        await controller.getScreenCoordinate(northWest);
    expect(topLeft, const ScreenCoordinate(x: 0, y: 0));
  });

  testWidgets('testResizeWidget', (WidgetTester tester) async {
    final Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();
    final GoogleMap map = GoogleMap(
      initialCameraPosition: _kInitialCameraPosition,
      onMapCreated: (GoogleMapController controller) async {
        controllerCompleter.complete(controller);
      },
    );
    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: MaterialApp(
            home: Scaffold(
                body: SizedBox(height: 100, width: 100, child: map)))));
    final GoogleMapController controller = await controllerCompleter.future;

    await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: MaterialApp(
            home: Scaffold(
                body: SizedBox(height: 400, width: 400, child: map)))));

    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Simple call to make sure that the app hasn't crashed.
    final LatLngBounds bounds1 = await controller.getVisibleRegion();
    final LatLngBounds bounds2 = await controller.getVisibleRegion();
    expect(bounds1, bounds2);
  });

  testWidgets('testToggleInfoWindow', (WidgetTester tester) async {
    final Marker marker = Marker(
        markerId: MarkerId("marker"),
        infoWindow: InfoWindow(title: "InfoWindow"));
    final Set<Marker> markers = <Marker>{marker};

    Completer<GoogleMapController> controllerCompleter =
        Completer<GoogleMapController>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
        markers: markers,
        onMapCreated: (GoogleMapController googleMapController) {
          controllerCompleter.complete(googleMapController);
        },
      ),
    ));

    GoogleMapController controller = await controllerCompleter.future;

    bool iwVisibleStatus =
        await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, false);

    await controller.showMarkerInfoWindow(marker.markerId);
    iwVisibleStatus = await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, true);

    await controller.hideMarkerInfoWindow(marker.markerId);
    iwVisibleStatus = await controller.isMarkerInfoWindowShown(marker.markerId);
    expect(iwVisibleStatus, false);
  });

  testWidgets("fromAssetImage", (WidgetTester tester) async {
    double pixelRatio = 2;
    final ImageConfiguration imageConfiguration =
        ImageConfiguration(devicePixelRatio: pixelRatio);
    final BitmapDescriptor mip = await BitmapDescriptor.fromAssetImage(
        imageConfiguration, 'red_square.png');
    final BitmapDescriptor scaled = await BitmapDescriptor.fromAssetImage(
        imageConfiguration, 'red_square.png',
        mipmaps: false);
    // ignore: invalid_use_of_visible_for_testing_member
    expect(mip.toJson()[2], 1);
    // ignore: invalid_use_of_visible_for_testing_member
    expect(scaled.toJson()[2], 2);
  });
}
