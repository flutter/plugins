// Copyright 2020 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_platform_interface/src/method_channel/method_channel_file_selector.dart';

void main() {
  group('$FileSelectorPlatform', () {
    test('$MethodChannelFileSelector() is the default instance', () {
      expect(FileSelectorPlatform.instance,
          isInstanceOf<MethodChannelFileSelector>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FileSelectorPlatform.instance = ImplementsFileSelectorPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final FileSelectorPlatformMock mock = FileSelectorPlatformMock();
      FileSelectorPlatform.instance = mock;
    });

    test('Can be extended', () {
      FileSelectorPlatform.instance = ExtendsFileSelectorPlatform();
    });
  });
}

class FileSelectorPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements FileSelectorPlatform {}

class ImplementsFileSelectorPlatform extends Mock
    implements FileSelectorPlatform {}

class ExtendsFileSelectorPlatform extends FileSelectorPlatform {}
