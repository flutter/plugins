// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  group('XTypeGroup', () {
    test('toJSON() creates correct map', () {
      final label = 'test group';
      final extensions = ['txt', 'jpg'];
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

    test('A wildcard group can be created', () {
      final group = XTypeGroup(
        label: 'Any',
      );

      final jsonMap = group.toJSON();
      expect(jsonMap['extensions'], null);
      expect(jsonMap['mimeTypes'], null);
      expect(jsonMap['macUTIs'], null);
      expect(jsonMap['webWildCards'], null);
    });

    test('Leading dots are removed from extensions', () {
      final extensions = ['.txt', '.jpg'];
      final group = XTypeGroup(extensions: extensions);

      expect(group.extensions, ['txt', 'jpg']);
    });
  });
}
