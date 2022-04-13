// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/src/v4/webview_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('absent should initialize isPresent to false', () {
    const WebSetting<String> absent = WebSetting<String>.absent();
    expect(absent.isPresent, isFalse);
  });

  test('Cannot access value of absent setting', () {
    const WebSetting<String> absent = WebSetting<String>.absent();
    expect(() => absent.value, throwsA(isA<StateError>()));
  });

  test('Setting should return value it is initialized with', () {
    const WebSetting<String> setting = WebSetting<String>.of('Test value');
    expect(setting.isPresent, isTrue);
    expect(setting.value, 'Test value');
  });
}
