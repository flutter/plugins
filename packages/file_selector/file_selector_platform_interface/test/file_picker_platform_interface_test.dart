// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:file_picker_platform_interface/file_selector_platform_interface.dart';
import 'package:file_picker_platform_interface/src/method_channel/method_channel_file_selector.dart';

void main() {
  group('$FilePickerPlatform', () {
    test('$MethodChannelFilePicker() is the default instance', () {
      expect(FilePickerPlatform.instance,
          isInstanceOf<MethodChannelFilePicker>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        FilePickerPlatform.instance = ImplementsFilePickerPlatform();
      }, throwsA(isInstanceOf<AssertionError>()));
    });

    test('Can be mocked with `implements`', () {
      final FilePickerPlatformMock mock = FilePickerPlatformMock();
      FilePickerPlatform.instance = mock;
    });

    test('Can be extended', () {
      FilePickerPlatform.instance = ExtendsFilePickerPlatform();
    });
  });


}


class FilePickerPlatformMock extends Mock
    with MockPlatformInterfaceMixin
    implements FilePickerPlatform {}

class ImplementsFilePickerPlatform extends Mock
    implements FilePickerPlatform {}

class ExtendsFilePickerPlatform extends FilePickerPlatform {}