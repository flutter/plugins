// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:integration_test/integration_test.dart';

import 'google_map_inspector.dart';

const LatLng _kInitialMapCenter = LatLng(0, 0);
const double _kInitialZoomLevel = 5;
const CameraPosition _kInitialCameraPosition =
    CameraPosition(target: _kInitialMapCenter, zoom: _kInitialZoomLevel);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? compassEnabled = await inspector.isCompassEnabled();
    expect(compassEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        compassEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? mapToolbarEnabled = await inspector.isMapToolbarEnabled();
    expect(mapToolbarEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        mapToolbarEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
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
    late GoogleMapController controller;

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
              GoogleMapInspector(c.channel!);
          controller = c;
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;

    if (Platform.isIOS) {
      final MinMaxZoomPreference zoomLevel =
          await inspector.getMinMaxZoomLevels();
      expect(zoomLevel, equals(initialZoomLevel));
    } else if (Platform.isAndroid) {
      await controller.moveCamera(CameraUpdate.zoomTo(15));
      await tester.pumpAndSettle();
      double? zoomLevel = await inspector.getZoomLevel();
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
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    if (Platform.isIOS) {
      final MinMaxZoomPreference zoomLevel =
          await inspector.getMinMaxZoomLevels();
      expect(zoomLevel, equals(finalZoomLevel));
    } else {
      await controller.moveCamera(CameraUpdate.zoomTo(15));
      await tester.pumpAndSettle();
      double? zoomLevel = await inspector.getZoomLevel();
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? zoomGesturesEnabled = await inspector.isZoomGesturesEnabled();
    expect(zoomGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        zoomGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    zoomGesturesEnabled = await inspector.isZoomGesturesEnabled();
    expect(zoomGesturesEnabled, true);
  });

  testWidgets('testZoomControlsEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? zoomControlsEnabled = await inspector.isZoomControlsEnabled();
    expect(zoomControlsEnabled, !Platform.isIOS);

    /// Zoom Controls functionality is not available on iOS at the moment.
    if (Platform.isAndroid) {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            fail('OnMapCreated should get called only once.');
          },
        ),
      ));

      zoomControlsEnabled = await inspector.isZoomControlsEnabled();
      expect(zoomControlsEnabled, false);
    }
  });

  testWidgets('testLiteModeEnabled', (WidgetTester tester) async {
    final Key key = GlobalKey();
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        liteModeEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          final GoogleMapInspector inspector =
              // ignore: invalid_use_of_visible_for_testing_member
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? liteModeEnabled = await inspector.isLiteModeEnabled();
    expect(liteModeEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        liteModeEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    liteModeEnabled = await inspector.isLiteModeEnabled();
    expect(liteModeEnabled, true);
  }, skip: !Platform.isAndroid);

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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? rotateGesturesEnabled = await inspector.isRotateGesturesEnabled();
    expect(rotateGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        rotateGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? tiltGesturesEnabled = await inspector.isTiltGesturesEnabled();
    expect(tiltGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        tiltGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? scrollGesturesEnabled = await inspector.isScrollGesturesEnabled();
    expect(scrollGesturesEnabled, false);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        scrollGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
        },
      ),
    ));

    scrollGesturesEnabled = await inspector.isScrollGesturesEnabled();
    expect(scrollGesturesEnabled, true);
  });

  testWidgets('testInitialCenterLocationAtCenter', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));

    final Completer<GoogleMapController> mapControllerCompleter =
        Completer<GoogleMapController>();
    final Key key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          key: key,
          initialCameraPosition: _kInitialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            mapControllerCompleter.complete(controller);
          },
        ),
      ),
    );
    final GoogleMapController mapController =
        await mapControllerCompleter.future;

    await tester.pumpAndSettle();

    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    final ScreenCoordinate coordinate =
        await mapController.getScreenCoordinate(_kInitialCameraPosition.target);
    final Rect rect = tester.getRect(find.byKey(key));
    if (Platform.isIOS) {
      // On iOS, the coordinate value from the GoogleMapSdk doesn't include the devicePixelRatio`.
      // So we don't need to do the conversion like we did below for other platforms.
      expect(coordinate.x, (rect.center.dx - rect.topLeft.dx).round());
      expect(coordinate.y, (rect.center.dy - rect.topLeft.dy).round());
    } else {
      expect(
          coordinate.x,
          ((rect.center.dx - rect.topLeft.dx) *
                  tester.binding.window.devicePixelRatio)
              .round());
      expect(
          coordinate.y,
          ((rect.center.dy - rect.topLeft.dy) *
                  tester.binding.window.devicePixelRatio)
              .round());
    }
    await tester.binding.setSurfaceSize(null);
    AndroidGoogleMapsFlutter.useAndroidViewSurface = false;
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
    await tester.pumpAndSettle();

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
    const double padding = 0;
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? isTrafficEnabled = await inspector.isTrafficEnabled();
    expect(isTrafficEnabled, true);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        trafficEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    final bool? isBuildingsEnabled = await inspector.isBuildingsEnabled();
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    bool? myLocationButtonEnabled = await inspector.isMyLocationButtonEnabled();
    expect(myLocationButtonEnabled, true);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: GoogleMap(
        key: key,
        initialCameraPosition: _kInitialCameraPosition,
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          fail('OnMapCreated should get called only once.');
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    final bool? myLocationButtonEnabled =
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
              GoogleMapInspector(controller.channel!);
          inspectorCompleter.complete(inspector);
        },
      ),
    ));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    final bool? myLocationButtonEnabled =
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
    const String mapStyle =
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

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

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

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

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

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

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

    await tester.pumpAndSettle();
    // TODO(cyanglaz): Remove this after we added `mapRendered` callback, and `mapControllerCompleter.complete(controller)` above should happen
    // in `mapRendered`.
    // https://github.com/flutter/flutter/issues/54758
    await Future<void>.delayed(const Duration(seconds: 1));

    // Simple call to make sure that the app hasn't crashed.
    final LatLngBounds bounds1 = await controller.getVisibleRegion();
    final LatLngBounds bounds2 = await controller.getVisibleRegion();
    expect(bounds1, bounds2);
  });

  testWidgets('testToggleInfoWindow', (WidgetTester tester) async {
    const Marker marker = Marker(
        markerId: MarkerId('marker'),
        infoWindow: InfoWindow(title: 'InfoWindow'));
    final Set<Marker> markers = <Marker>{marker};

    final Completer<GoogleMapController> controllerCompleter =
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

    final GoogleMapController controller = await controllerCompleter.future;

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

  testWidgets('fromAssetImage', (WidgetTester tester) async {
    const double pixelRatio = 2;
    const ImageConfiguration imageConfiguration =
        ImageConfiguration(devicePixelRatio: pixelRatio);
    final BitmapDescriptor mip = await BitmapDescriptor.fromAssetImage(
        imageConfiguration, 'red_square.png');
    final BitmapDescriptor scaled = await BitmapDescriptor.fromAssetImage(
        imageConfiguration, 'red_square.png',
        mipmaps: false);
    expect((mip.toJson() as List<dynamic>)[2], 1);
    expect((scaled.toJson() as List<dynamic>)[2], 2);
  });

  testWidgets('testTakeSnapshot', (WidgetTester tester) async {
    final Completer<GoogleMapInspector> inspectorCompleter =
        Completer<GoogleMapInspector>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: GoogleMap(
          initialCameraPosition: _kInitialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            final GoogleMapInspector inspector =
                // ignore: invalid_use_of_visible_for_testing_member
                GoogleMapInspector(controller.channel!);
            inspectorCompleter.complete(inspector);
          },
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 3));

    final GoogleMapInspector inspector = await inspectorCompleter.future;
    final Uint8List? bytes = await inspector.takeSnapshot();
    expect(bytes?.isNotEmpty, true);
  },
      // TODO(cyanglaz): un-skip the test when we can test this on CI with API key enabled.
      // https://github.com/flutter/flutter/issues/57057
      skip: Platform.isAndroid);

  testWidgets(
    'set tileOverlay correctly',
    (WidgetTester tester) async {
      final Completer<GoogleMapInspector> inspectorCompleter =
          Completer<GoogleMapInspector>();
      final TileOverlay tileOverlay1 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 2,
        visible: true,
        transparency: 0.2,
        fadeIn: true,
      );

      final TileOverlay tileOverlay2 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_2'),
        tileProvider: _DebugTileProvider(),
        zIndex: 1,
        visible: false,
        transparency: 0.3,
        fadeIn: false,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1, tileOverlay2},
            onMapCreated: (GoogleMapController controller) {
              final GoogleMapInspector inspector =
                  // ignore: invalid_use_of_visible_for_testing_member
                  GoogleMapInspector(controller.channel!);
              inspectorCompleter.complete(inspector);
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final GoogleMapInspector inspector = await inspectorCompleter.future;

      final Map<String, dynamic> tileOverlayInfo1 =
          (await inspector.getTileOverlayInfo('tile_overlay_1'))!;
      final Map<String, dynamic> tileOverlayInfo2 =
          (await inspector.getTileOverlayInfo('tile_overlay_2'))!;

      expect(tileOverlayInfo1['visible'], isTrue);
      expect(tileOverlayInfo1['fadeIn'], isTrue);
      expect(tileOverlayInfo1['transparency'],
          moreOrLessEquals(0.2, epsilon: 0.001));
      expect(tileOverlayInfo1['zIndex'], 2);

      expect(tileOverlayInfo2['visible'], isFalse);
      expect(tileOverlayInfo2['fadeIn'], isFalse);
      expect(tileOverlayInfo2['transparency'],
          moreOrLessEquals(0.3, epsilon: 0.001));
      expect(tileOverlayInfo2['zIndex'], 1);
    },
  );

  testWidgets(
    'update tileOverlays correctly',
    (WidgetTester tester) async {
      final Completer<GoogleMapInspector> inspectorCompleter =
          Completer<GoogleMapInspector>();
      final Key key = GlobalKey();
      final TileOverlay tileOverlay1 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 2,
        visible: true,
        transparency: 0.2,
        fadeIn: true,
      );

      final TileOverlay tileOverlay2 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_2'),
        tileProvider: _DebugTileProvider(),
        zIndex: 3,
        visible: true,
        transparency: 0.5,
        fadeIn: true,
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1, tileOverlay2},
            onMapCreated: (GoogleMapController controller) {
              final GoogleMapInspector inspector =
                  // ignore: invalid_use_of_visible_for_testing_member
                  GoogleMapInspector(controller.channel!);
              inspectorCompleter.complete(inspector);
            },
          ),
        ),
      );

      final GoogleMapInspector inspector = await inspectorCompleter.future;

      final TileOverlay tileOverlay1New = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 1,
        visible: false,
        transparency: 0.3,
        fadeIn: false,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1New},
            onMapCreated: (GoogleMapController controller) {
              fail('update: OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      final Map<String, dynamic> tileOverlayInfo1 =
          (await inspector.getTileOverlayInfo('tile_overlay_1'))!;
      final Map<String, dynamic>? tileOverlayInfo2 =
          await inspector.getTileOverlayInfo('tile_overlay_2');

      expect(tileOverlayInfo1['visible'], isFalse);
      expect(tileOverlayInfo1['fadeIn'], isFalse);
      expect(tileOverlayInfo1['transparency'],
          moreOrLessEquals(0.3, epsilon: 0.001));
      expect(tileOverlayInfo1['zIndex'], 1);

      expect(tileOverlayInfo2, isNull);
    },
  );

  testWidgets(
    'remove tileOverlays correctly',
    (WidgetTester tester) async {
      final Completer<GoogleMapInspector> inspectorCompleter =
          Completer<GoogleMapInspector>();
      final Key key = GlobalKey();
      final TileOverlay tileOverlay1 = TileOverlay(
        tileOverlayId: const TileOverlayId('tile_overlay_1'),
        tileProvider: _DebugTileProvider(),
        zIndex: 2,
        visible: true,
        transparency: 0.2,
        fadeIn: true,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            tileOverlays: <TileOverlay>{tileOverlay1},
            onMapCreated: (GoogleMapController controller) {
              final GoogleMapInspector inspector =
                  // ignore: invalid_use_of_visible_for_testing_member
                  GoogleMapInspector(controller.channel!);
              inspectorCompleter.complete(inspector);
            },
          ),
        ),
      );

      final GoogleMapInspector inspector = await inspectorCompleter.future;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GoogleMap(
            key: key,
            initialCameraPosition: _kInitialCameraPosition,
            onMapCreated: (GoogleMapController controller) {
              fail('OnMapCreated should get called only once.');
            },
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      final Map<String, dynamic>? tileOverlayInfo1 =
          await inspector.getTileOverlayInfo('tile_overlay_1');

      expect(tileOverlayInfo1, isNull);
    },
  );
}

class _DebugTileProvider implements TileProvider {
  _DebugTileProvider() {
    boxPaint.isAntiAlias = true;
    boxPaint.color = Colors.blue;
    boxPaint.strokeWidth = 2.0;
    boxPaint.style = PaintingStyle.stroke;
  }

  static const int width = 100;
  static const int height = 100;
  static final Paint boxPaint = Paint();
  static const TextStyle textStyle = TextStyle(
    color: Colors.red,
    fontSize: 20,
  );

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final TextSpan textSpan = TextSpan(
      text: '$x,$y',
      style: textStyle,
    );
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0.0,
      maxWidth: width.toDouble(),
    );
    const Offset offset = Offset(0, 0);
    textPainter.paint(canvas, offset);
    canvas.drawRect(
        Rect.fromLTRB(0, 0, width.toDouble(), width.toDouble()), boxPaint);
    final ui.Picture picture = recorder.endRecording();
    final Uint8List byteData = await picture
        .toImage(width, height)
        .then((ui.Image image) =>
            image.toByteData(format: ui.ImageByteFormat.png))
        .then((ByteData? byteData) => byteData!.buffer.asUint8List());
    return Tile(width, height, byteData);
  }
}
