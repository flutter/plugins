// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

import '../mocks/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Autocomplete prediction', () {
    test('toJson() creates correct map', () {
      final Map<Object?, Object?> jsonMap =
          mockPrediction.toJson() as Map<Object?, Object?>;
      expect(jsonMap['distanceMeters'], mockPrediction.distanceMeters);
      expect(jsonMap['fullText'], mockPrediction.fullText);
      expect(jsonMap['placeId'], mockPrediction.placeId);
      expect(jsonMap['placeTypes'], mockPrediction.placeTypes);
      expect(jsonMap['primaryText'], mockPrediction.primaryText);
      expect(jsonMap['secondaryText'], mockPrediction.secondaryText);
    });
  });
}
