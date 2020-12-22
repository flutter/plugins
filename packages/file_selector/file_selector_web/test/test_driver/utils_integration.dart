// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.9

import 'dart:html';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:file_selector_web/src/utils.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  group('FileSelectorWeb utils', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    group('acceptedTypesToString', () {
      testWidgets('works', (_) async {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'images', webWildCards: ['images/*']),
          XTypeGroup(label: 'jpgs', extensions: ['jpg', 'jpeg']),
          XTypeGroup(label: 'pngs', mimeTypes: ['image/png']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'images/*,.jpg,.jpeg,image/png');
      });

      testWidgets('works with an empty list', (_) async {
        final List<XTypeGroup> acceptedTypes = [];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, '');
      });

      testWidgets('works with extensions', (_) async {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'jpgs', extensions: ['jpeg', 'jpg']),
          XTypeGroup(label: 'pngs', extensions: ['png']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, '.jpeg,.jpg,.png');
      });

      testWidgets('works with mime types', (_) async {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'jpgs', mimeTypes: ['image/jpeg', 'image/jpg']),
          XTypeGroup(label: 'pngs', mimeTypes: ['image/png']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'image/jpeg,image/jpg,image/png');
      });

      testWidgets('works with web wild cards', (_) async {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'images', webWildCards: ['image/*']),
          XTypeGroup(label: 'audios', webWildCards: ['audio/*']),
          XTypeGroup(label: 'videos', webWildCards: ['video/*']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'image/*,audio/*,video/*');
      });
    });

    group('convertFileToXFile', () {
      testWidgets('works', (_) async {
        final file = convertFileToXFile(File(['123456'], 'numbers.txt'));

        expect(file.name, 'numbers.txt');
        expect(await file.length(), 6);
        expect(await file.readAsString(), '123456');
        expect(await file.lastModified(), isNotNull);
      });
    });
  });
}
