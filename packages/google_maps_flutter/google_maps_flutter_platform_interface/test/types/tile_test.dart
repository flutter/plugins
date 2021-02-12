// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tile tests', () {
    test('toJson returns correct format', () async {
      final Uint8List data = Uint8List.fromList([0, 1]);
      final Tile tile = Tile(100, 200, data);
      final Object json = tile.toJson();
      expect(json, <String, Object>{
        'width': 100,
        'height': 200,
        'data': data,
      });
    });

    test('toJson handles null data', () async {
      final Tile tile = Tile(0, 0, null);
      final Object json = tile.toJson();
      expect(json, <String, Object>{
        'width': 0,
        'height': 0,
      });
    });
  });
}
