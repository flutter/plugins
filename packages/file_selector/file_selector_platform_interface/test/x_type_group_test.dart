// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  group('XTypeGroup', () {
    test('fails assertion with no parameters set', () {
      expect(() => XTypeGroup(), throwsAssertionError);
    });

    test('toJSON() creates correct map', () {
      final label = 'test group';
      final extensions = ['.txt', '.jpg'];
      final mimeTypes = ['text/plain'];
      final macUTIs = ['public.plain-text'];
      final webWildCards = ['image/*'];

      final group = XTypeGroup(
        label: label,
        extensions: extensions,
        mimeTypes: mimeTypes,
        macUTIs: macUTIs,
        webWildCards: webWildCards,
      );

      final jsonMap = group.toJSON();
      expect(jsonMap['label'], label);
      expect(jsonMap['extensions'], extensions);
      expect(jsonMap['mimeTypes'], mimeTypes);
      expect(jsonMap['macUTIs'], macUTIs);
      expect(jsonMap['webWildCards'], webWildCards);
    });
  });
}
