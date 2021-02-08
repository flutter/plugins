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
      final Map<String, dynamic> json = tile.toJson();
      expect(json['width'], 100);
      expect(json['height'], 200);
      expect(json['data'], data);
    });

    test('toJson returns empty if nothing presents', () async {
      final Tile tile = Tile(null, null, null);
      final Map<String, dynamic> json = tile.toJson();
      expect(json.isEmpty, true);
    });
  });
}
