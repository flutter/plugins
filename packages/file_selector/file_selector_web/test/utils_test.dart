// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_web/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileSelectorWeb utils', () {
    group('acceptedTypesToString', () {
      test('works', () {
        final List<XTypeGroup> acceptedTypes = <XTypeGroup>[
          const XTypeGroup(label: 'images', webWildCards: <String>['images/*']),
          const XTypeGroup(label: 'jpgs', extensions: <String>['jpg', 'jpeg']),
          const XTypeGroup(label: 'pngs', mimeTypes: <String>['image/png']),
        ];
        final String accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'images/*,.jpg,.jpeg,image/png');
      });

      test('works with an empty list', () {
        final List<XTypeGroup> acceptedTypes = <XTypeGroup>[];
        final String accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, '');
      });

      test('works with extensions', () {
        final List<XTypeGroup> acceptedTypes = <XTypeGroup>[
          const XTypeGroup(label: 'jpgs', extensions: <String>['jpeg', 'jpg']),
          const XTypeGroup(label: 'pngs', extensions: <String>['png']),
        ];
        final String accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, '.jpeg,.jpg,.png');
      });

      test('works with mime types', () {
        final List<XTypeGroup> acceptedTypes = <XTypeGroup>[
          const XTypeGroup(
              label: 'jpgs', mimeTypes: <String>['image/jpeg', 'image/jpg']),
          const XTypeGroup(label: 'pngs', mimeTypes: <String>['image/png']),
        ];
        final String accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'image/jpeg,image/jpg,image/png');
      });

      test('works with web wild cards', () {
        final List<XTypeGroup> acceptedTypes = <XTypeGroup>[
          const XTypeGroup(label: 'images', webWildCards: <String>['image/*']),
          const XTypeGroup(label: 'audios', webWildCards: <String>['audio/*']),
          const XTypeGroup(label: 'videos', webWildCards: <String>['video/*']),
        ];
        final String accepts = acceptedTypesToString(acceptedTypes);
        expect(accepts, 'image/*,audio/*,video/*');
      });

      test('throws for a type group that does not support web', () {
        final List<XTypeGroup> acceptedTypes = <XTypeGroup>[
          const XTypeGroup(label: 'text', macUTIs: <String>['public.text']),
        ];
        expect(() => acceptedTypesToString(acceptedTypes), throwsArgumentError);
      });
    });
  });
}
