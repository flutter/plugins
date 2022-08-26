// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(SharedPreferencesStorePlatform, () {
    test('disallows implementing interface', () {
      expect(
        () {
          SharedPreferencesStorePlatform.instance = IllegalImplementation();
        },
        throwsAssertionError,
      );
    });

    test('disallows implementing interface, unusual exception', () {
      expect(
        () {
          SharedPreferencesStorePlatform.instance = IllegalImplementationWithUnusualException();
        },
        throwsAssertionError,
      );
    });
  });
}

class IllegalImplementation implements SharedPreferencesStorePlatform {
  // Intentionally declare self as not a mock to trigger the
  // compliance check.
  @override
  bool get isMock => false;

  @override
  Future<bool> clear() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, Object>> getAll() {
    throw UnimplementedError();
  }

  @override
  Future<bool> remove(String key) {
    throw UnimplementedError();
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    throw UnimplementedError();
  }
}

class IllegalImplementationWithUnusualException extends IllegalImplementation {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw _UnusualException();
  }
}

class _UnusualException {}
