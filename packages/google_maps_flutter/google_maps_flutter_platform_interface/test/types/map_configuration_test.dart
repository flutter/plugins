// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  group('diffs', () {
    // A options instance with every field set, to test diffs against.
    final MapConfiguration diffBase = MapConfiguration(
      compassEnabled: false,
      mapToolbarEnabled: false,
      cameraTargetBounds: CameraTargetBounds(LatLngBounds(
          northeast: const LatLng(30, 20), southwest: const LatLng(10, 40))),
      mapType: MapType.normal,
      minMaxZoomPreference: const MinMaxZoomPreference(1.0, 10.0),
      rotateGesturesEnabled: false,
      scrollGesturesEnabled: false,
      tiltGesturesEnabled: false,
      trackCameraPosition: false,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      liteModeEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      padding: const EdgeInsets.all(5.0),
      indoorViewEnabled: false,
      trafficEnabled: false,
      buildingsEnabled: false,
    );

    test('only include changed fields', () async {
      const MapConfiguration nullOptions = MapConfiguration();

      // Everything should be null since nothing changed.
      expect(diffBase.diffFrom(diffBase), nullOptions);
    });

    test('only apply non-null fields', () async {
      const MapConfiguration smallDiff = MapConfiguration(compassEnabled: true);

      final MapConfiguration updated = diffBase.applyDiff(smallDiff);

      // The diff should be updated.
      expect(updated.compassEnabled, true);
      // Spot check that other fields weren't stomped.
      expect(updated.mapToolbarEnabled, isNot(null));
      expect(updated.cameraTargetBounds, isNot(null));
      expect(updated.mapType, isNot(null));
      expect(updated.zoomControlsEnabled, isNot(null));
      expect(updated.liteModeEnabled, isNot(null));
      expect(updated.padding, isNot(null));
      expect(updated.trafficEnabled, isNot(null));
    });

    test('handle compassEnabled', () async {
      const MapConfiguration diff = MapConfiguration(compassEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.compassEnabled, true);
    });

    test('handle mapToolbarEnabled', () async {
      const MapConfiguration diff = MapConfiguration(mapToolbarEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.mapToolbarEnabled, true);
    });

    test('handle cameraTargetBounds', () async {
      final CameraTargetBounds newBounds = CameraTargetBounds(LatLngBounds(
          northeast: const LatLng(55, 15), southwest: const LatLng(5, 15)));
      final MapConfiguration diff =
          MapConfiguration(cameraTargetBounds: newBounds);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.cameraTargetBounds, newBounds);
    });

    test('handle mapType', () async {
      const MapConfiguration diff =
          MapConfiguration(mapType: MapType.satellite);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.mapType, MapType.satellite);
    });

    test('handle minMaxZoomPreference', () async {
      const MinMaxZoomPreference newZoomPref = MinMaxZoomPreference(3.3, 4.5);
      const MapConfiguration diff =
          MapConfiguration(minMaxZoomPreference: newZoomPref);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.minMaxZoomPreference, newZoomPref);
    });

    test('handle rotateGesturesEnabled', () async {
      const MapConfiguration diff =
          MapConfiguration(rotateGesturesEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.rotateGesturesEnabled, true);
    });

    test('handle scrollGesturesEnabled', () async {
      const MapConfiguration diff =
          MapConfiguration(scrollGesturesEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.scrollGesturesEnabled, true);
    });

    test('handle tiltGesturesEnabled', () async {
      const MapConfiguration diff = MapConfiguration(tiltGesturesEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.tiltGesturesEnabled, true);
    });

    test('handle trackCameraPosition', () async {
      const MapConfiguration diff = MapConfiguration(trackCameraPosition: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.trackCameraPosition, true);
    });

    test('handle zoomControlsEnabled', () async {
      const MapConfiguration diff = MapConfiguration(zoomControlsEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.zoomControlsEnabled, true);
    });

    test('handle zoomGesturesEnabled', () async {
      const MapConfiguration diff = MapConfiguration(zoomGesturesEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.zoomGesturesEnabled, true);
    });

    test('handle liteModeEnabled', () async {
      const MapConfiguration diff = MapConfiguration(liteModeEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.liteModeEnabled, true);
    });

    test('handle myLocationEnabled', () async {
      const MapConfiguration diff = MapConfiguration(myLocationEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.myLocationEnabled, true);
    });

    test('handle myLocationButtonEnabled', () async {
      const MapConfiguration diff =
          MapConfiguration(myLocationButtonEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.myLocationButtonEnabled, true);
    });

    test('handle padding', () async {
      const EdgeInsets newPadding =
          EdgeInsets.symmetric(vertical: 1.0, horizontal: 3.0);
      const MapConfiguration diff = MapConfiguration(padding: newPadding);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.padding, newPadding);
    });

    test('handle indoorViewEnabled', () async {
      const MapConfiguration diff = MapConfiguration(indoorViewEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.indoorViewEnabled, true);
    });

    test('handle trafficEnabled', () async {
      const MapConfiguration diff = MapConfiguration(trafficEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.trafficEnabled, true);
    });

    test('handle buildingsEnabled', () async {
      const MapConfiguration diff = MapConfiguration(buildingsEnabled: true);

      const MapConfiguration empty = MapConfiguration();
      final MapConfiguration updated = diffBase.applyDiff(diff);

      // A diff applied to empty options should be the diff itself.
      expect(empty.applyDiff(diff), diff);
      // A diff applied to non-empty options should update that field.
      expect(updated.buildingsEnabled, true);
    });
  });
}
