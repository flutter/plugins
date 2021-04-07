// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:file_selector_web/src/utils.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

void main() {
  group('FileSelectorWeb utils', () {
    group('acceptedTypesToString', () {
      test('works', () {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'images', webWildCards: ['images/*']),
          XTypeGroup(label: 'jpgs', extensions: ['jpg', 'jpeg']),
          XTypeGroup(label: 'pngs', mimeTypes: ['image/png']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'images/*,.jpg,.jpeg,image/png');
      });

      test('works with an empty list', () {
        final List<XTypeGroup> acceptedTypes = [];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, '');
      });

      test('works with extensions', () {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'jpgs', extensions: ['jpeg', 'jpg']),
          XTypeGroup(label: 'pngs', extensions: ['png']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, '.jpeg,.jpg,.png');
      });

      test('works with mime types', () {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'jpgs', mimeTypes: ['image/jpeg', 'image/jpg']),
          XTypeGroup(label: 'pngs', mimeTypes: ['image/png']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'image/jpeg,image/jpg,image/png');
      });

      test('works with web wild cards', () {
        final List<XTypeGroup> acceptedTypes = [
          XTypeGroup(label: 'images', webWildCards: ['image/*']),
          XTypeGroup(label: 'audios', webWildCards: ['audio/*']),
          XTypeGroup(label: 'videos', webWildCards: ['video/*']),
        ];
        final accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'image/*,audio/*,video/*');
      });
    });
  });
}
