// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore:unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$BitmapDescriptor', () {
    test('toJson / fromJson', () {
      final BitmapDescriptor descriptor =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

      final Object expected = <Object>[
        'defaultMarker',
        BitmapDescriptor.hueCyan
      ];
      expect(descriptor.toJson(), equals(expected)); // Same JSON
    });

    group('createFromAsset constructor', () {
      test('without mipmaps', () async {
        final BitmapDescriptor descriptor =
            await BitmapDescriptor.createFromAsset(
                ImageConfiguration.empty, 'path_to_asset_image',
                mipmaps: false);
        expect(descriptor, isA<BitmapDescriptor>());
        expect(
            descriptor.toJson(),
            equals(<Object>[
              'asset',
              'path_to_asset_image',
              BitmapDescriptor.bitmapAutoScaling,
              1.0
            ]));
      });
      test('with mipmaps', () async {
        final BitmapDescriptor descriptor =
            await BitmapDescriptor.createFromAsset(
                ImageConfiguration.empty, 'path_to_asset_image',
                // ignore: avoid_redundant_argument_values
                mipmaps: true);
        expect(descriptor, isA<BitmapDescriptor>());
        expect(
            descriptor.toJson(),
            equals(<Object>[
              'asset',
              'path_to_asset_image',
              BitmapDescriptor.bitmapAutoScaling,
              1.0
            ]));
      });
      test('with size and without mipmaps', () async {
        final double devicePixelRatio =
            WidgetsBinding.instance.window.devicePixelRatio;
        const Size size = Size(100, 200);
        final ImageConfiguration imageConfiguration =
            ImageConfiguration(size: size, devicePixelRatio: devicePixelRatio);
        final BitmapDescriptor descriptor =
            await BitmapDescriptor.createFromAsset(
                imageConfiguration, 'path_to_asset_image',
                mipmaps: false);

        expect(descriptor, isA<BitmapDescriptor>());
        expect(
            descriptor.toJson(),
            equals(<Object>[
              'asset',
              'path_to_asset_image',
              BitmapDescriptor.bitmapAutoScaling,
              devicePixelRatio,
              <double>[size.width, size.height]
            ]));
      });

      test('with size and mipmaps', () async {
        final double devicePixelRatio =
            WidgetsBinding.instance.window.devicePixelRatio;
        const Size size = Size(100, 200);
        final ImageConfiguration imageConfiguration =
            ImageConfiguration(size: size, devicePixelRatio: devicePixelRatio);
        final BitmapDescriptor descriptor =
            await BitmapDescriptor.createFromAsset(
                imageConfiguration, 'path_to_asset_image',
                // ignore: avoid_redundant_argument_values
                mipmaps: true);

        expect(descriptor, isA<BitmapDescriptor>());
        expect(
            descriptor.toJson(),
            equals(<Object>[
              'asset',
              'path_to_asset_image',
              BitmapDescriptor.bitmapAutoScaling,
              1.0,
              <double>[size.width, size.height]
            ]));
      });
    });

    group('createFromBytes constructor', () {
      test('with empty byte array, throws assertion error', () {
        expect(() {
          BitmapDescriptor.createFromBytes(Uint8List.fromList(<int>[]));
        }, throwsAssertionError);
      });

      test('with bytes', () {
        final BitmapDescriptor descriptor = BitmapDescriptor.createFromBytes(
          Uint8List.fromList(<int>[1, 2, 3]),
        );
        expect(descriptor, isA<BitmapDescriptor>());
        expect(
            descriptor.toJson(),
            equals(<Object>[
              'bytes',
              <int>[1, 2, 3],
              BitmapDescriptor.bitmapAutoScaling,
              1.0
            ]));
      });

      test('with size', () {
        final BitmapDescriptor descriptor = BitmapDescriptor.createFromBytes(
          Uint8List.fromList(<int>[1, 2, 3]),
          size: const Size(40, 20),
        );

        expect(
            descriptor.toJson(),
            equals(<Object>[
              'bytes',
              <int>[1, 2, 3],
              BitmapDescriptor.bitmapAutoScaling,
              1.0,
              <int>[40, 20],
            ]));
      });
    });
  });
}
