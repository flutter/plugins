// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$BitmapDescriptor', () {
    test('toJson / fromJson', () {
      final BitmapDescriptor descriptor =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
      final Object json = descriptor.toJson();

      // Rehydrate a new bitmap descriptor...
      // ignore: deprecated_member_use_from_same_package
      final BitmapDescriptor descriptorFromJson =
          BitmapDescriptor.fromJson(json);

      expect(descriptorFromJson, isNot(descriptor)); // New instance
      expect(identical(descriptorFromJson.toJson(), json), isTrue); // Same JSON
    });

    group('fromJson validation', () {
      group('type validation', () {
        test('correct type', () {
          expect(BitmapDescriptor.fromJson(<dynamic>['defaultMarker']),
              isA<BitmapDescriptor>());
        });
        test('wrong type', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['bogusType']);
          }, throwsAssertionError);
        });
      });
      group('defaultMarker', () {
        test('hue is null', () {
          expect(BitmapDescriptor.fromJson(<dynamic>['defaultMarker']),
              isA<BitmapDescriptor>());
        });
        test('hue is number', () {
          expect(BitmapDescriptor.fromJson(<dynamic>['defaultMarker', 158]),
              isA<BitmapDescriptor>());
        });
        test('hue is not number', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['defaultMarker', 'nope']);
          }, throwsAssertionError);
        });
        test('hue is out of range', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['defaultMarker', -1]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['defaultMarker', 361]);
          }, throwsAssertionError);
        });
      });
      group('fromBytes', () {
        test('with bytes', () {
          expect(
              BitmapDescriptor.fromJson(<dynamic>[
                'fromBytes',
                Uint8List.fromList(<int>[1, 2, 3])
              ]),
              isA<BitmapDescriptor>());
        });
        test('without bytes', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromBytes', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromBytes', <dynamic>[]]);
          }, throwsAssertionError);
        });
      });
      group('fromAsset', () {
        test('name is passed', () {
          expect(
              BitmapDescriptor.fromJson(
                  <dynamic>['fromAsset', 'some/path.png']),
              isA<BitmapDescriptor>());
        });
        test('name cannot be null or empty', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAsset', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAsset', '']);
          }, throwsAssertionError);
        });
        test('package is passed', () {
          expect(
              BitmapDescriptor.fromJson(
                  <dynamic>['fromAsset', 'some/path.png', 'some_package']),
              isA<BitmapDescriptor>());
        });
        test('package cannot be null or empty', () {
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAsset', 'some/path.png', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAsset', 'some/path.png', '']);
          }, throwsAssertionError);
        });
      });
      group('fromAssetImage', () {
        test('name and dpi passed', () {
          expect(
              BitmapDescriptor.fromJson(
                  <dynamic>['fromAssetImage', 'some/path.png', 1.0]),
              isA<BitmapDescriptor>());
        });
        test('name cannot be null or empty', () {
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAssetImage', null, 1.0]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>['fromAssetImage', '', 1.0]);
          }, throwsAssertionError);
        });
        test('dpi must be number', () {
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', 'one']);
          }, throwsAssertionError);
        });
        test('with optional [width, height] List', () {
          expect(
              BitmapDescriptor.fromJson(<dynamic>[
                'fromAssetImage',
                'some/path.png',
                1.0,
                <dynamic>[640, 480]
              ]),
              isA<BitmapDescriptor>());
        });
        test(
            'optional [width, height] List cannot be null or not contain 2 elements',
            () {
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', 1.0, null]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(
                <dynamic>['fromAssetImage', 'some/path.png', 1.0, <dynamic>[]]);
          }, throwsAssertionError);
          expect(() {
            BitmapDescriptor.fromJson(<dynamic>[
              'fromAssetImage',
              'some/path.png',
              1.0,
              <dynamic>[640, 480, 1024]
            ]);
          }, throwsAssertionError);
        });
      });
    });
  });
}
