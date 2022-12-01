// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('LatLng bounds', () {
    test('toJson() creates correct json object', () {
      final List<Object?> jsonObject =
          mockLocationBias.toJson() as List<Object?>;
      expect(jsonObject[0], <double>[60.4518, 22.2666]);
      expect(jsonObject[1], <double>[70.0821, 27.8718]);
    });
  });
}
