// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('XTypeGroup', () {
    test('toJSON() creates correct map', () {
      const List<String> extensions = <String>['txt', 'jpg'];
      const List<String> mimeTypes = <String>['text/plain'];
      const List<String> macUTIs = <String>['public.plain-text'];
      const List<String> webWildCards = <String>['image/*'];
      const String label = 'test group';
      const XTypeGroup group = XTypeGroup(
        label: label,
        extensions: extensions,
        mimeTypes: mimeTypes,
        macUTIs: macUTIs,
        webWildCards: webWildCards,
      );

      final Map<String, dynamic> jsonMap = group.toJSON();
      expect(jsonMap['label'], label);
      expect(jsonMap['extensions'], extensions);
      expect(jsonMap['mimeTypes'], mimeTypes);
      expect(jsonMap['macUTIs'], macUTIs);
      expect(jsonMap['webWildCards'], webWildCards);
    });

    test('a wildcard group can be created', () {
      const XTypeGroup group = XTypeGroup(
        label: 'Any',
      );

      final Map<String, dynamic> jsonMap = group.toJSON();
      expect(jsonMap['extensions'], null);
      expect(jsonMap['mimeTypes'], null);
      expect(jsonMap['macUTIs'], null);
      expect(jsonMap['webWildCards'], null);
      expect(group.allowsAny, true);
    });

    test('allowsAny treats empty arrays the same as null', () {
      const XTypeGroup group = XTypeGroup(
        label: 'Any',
        extensions: <String>[],
        mimeTypes: <String>[],
        macUTIs: <String>[],
        webWildCards: <String>[],
      );

      expect(group.allowsAny, true);
    });

    test('allowsAny returns false if anything is set', () {
      const XTypeGroup extensionOnly =
          XTypeGroup(label: 'extensions', extensions: <String>['txt']);
      const XTypeGroup mimeOnly =
          XTypeGroup(label: 'mime', mimeTypes: <String>['text/plain']);
      const XTypeGroup utiOnly =
          XTypeGroup(label: 'utis', macUTIs: <String>['public.text']);
      const XTypeGroup webOnly =
          XTypeGroup(label: 'web', webWildCards: <String>['.txt']);

      expect(extensionOnly.allowsAny, false);
      expect(mimeOnly.allowsAny, false);
      expect(utiOnly.allowsAny, false);
      expect(webOnly.allowsAny, false);
    });

    test('passing only macUTIs should fill uniformTypeIdentifiers', () {
      const List<String> macUTIs = <String>['public.plain-text'];
      const XTypeGroup group = XTypeGroup(
        macUTIs: macUTIs,
      );

      expect(group.uniformTypeIdentifiers, macUTIs);
    });

    test(
        'passing only uniformTypeIdentifiers should fill uniformTypeIdentifiers',
        () {
      const List<String> uniformTypeIdentifiers = <String>['public.plain-text'];
      const XTypeGroup group = XTypeGroup(
        uniformTypeIdentifiers: uniformTypeIdentifiers,
      );

      expect(group.uniformTypeIdentifiers, uniformTypeIdentifiers);
    });

    test('macUTIs getter return macUTIs value passed in constructor', () {
      const List<String> macUTIs = <String>['public.plain-text'];
      const XTypeGroup group = XTypeGroup(
        macUTIs: macUTIs,
      );

      expect(group.macUTIs, macUTIs);
    });

    test('macUTIs getter returns uniformTypeIdentifiers value passed in constructor', () {
      const List<String> uniformTypeIdentifiers = <String>['public.plain-text'];
      const XTypeGroup group = XTypeGroup(
        uniformTypeIdentifiers: uniformTypeIdentifiers,
      );

      expect(group.macUTIs, uniformTypeIdentifiers);
    });

    test('passing both uniformTypeIdentifiers and macUTIs should throw', () {
      const List<String> macUTIs = <String>['public.plain-text'];
      const List<String> uniformTypeIndentifiers = <String>[
        'public.plain-images'
      ];
      expect(
          () => XTypeGroup(
              macUTIs: macUTIs,
              uniformTypeIdentifiers: uniformTypeIndentifiers),
          throwsA(predicate((Object? e) =>
              e is AssertionError &&
              e.message ==
                  'It is only allowed to specify either macUTIs or uniformTypeIdentifiers')));
    });

    test(
        'having uniformTypeIdentifiers and macUTIs as null should leave uniformTypeIdentifiers as null',
        () {
      const XTypeGroup group = XTypeGroup();

      expect(group.uniformTypeIdentifiers, null);
    });

    test('leading dots are removed from extensions', () {
      const List<String> extensions = <String>['.txt', '.jpg'];
      const XTypeGroup group = XTypeGroup(extensions: extensions);

      expect(group.extensions, <String>['txt', 'jpg']);
    });
  });
}
