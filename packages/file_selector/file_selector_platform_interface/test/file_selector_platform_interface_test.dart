// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_platform_interface/src/method_channel/method_channel_file_selector.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Store the initial instance before any tests change it.
  final FileSelectorPlatform initialInstance = FileSelectorPlatform.instance;

  group('$FileSelectorPlatform', () {
    test('$MethodChannelFileSelector() is the default instance', () {
      expect(initialInstance, isInstanceOf<MethodChannelFileSelector>());
    });

    test('Can be extended', () {
      FileSelectorPlatform.instance = ExtendsFileSelectorPlatform();
    });
  });
}

class ExtendsFileSelectorPlatform extends FileSelectorPlatform {}
