// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const Map<String, dynamic> kTestValues = <String, dynamic>{
    'flutter.String': 'hello world',
    'flutter.bool': true,
    'flutter.int': 42,
    'flutter.double': 3.14159,
    'flutter.List': <String>['foo', 'bar'],
  };

  group('SharedPreferences: setting the platform', () {
    final Map<String, Object> values = <String, Object>{};
    SharedPreferences.platform = MockSharedPreferences(values);

    test('mock shared preferences', () async {
      SharedPreferences.setMockInitialValues(
          <String, Object>{'flutter.String': kTestValues['flutter.String']});
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      expect(preferences.getString('String'), kTestValues['flutter.String']);
      expect((await SharedPreferences.platform.getAll()).isEmpty, true);

      SharedPreferences.setMockInitialValues(null);
      await preferences.reload();
      expect(preferences.getString('String'), null);
    });

    test('some basics', () async {
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();

      preferences.setString('String', kTestValues['flutter.String']);
      preferences.setBool('bool', kTestValues['flutter.bool']);
      preferences.setInt('int', kTestValues['flutter.int']);
      preferences.setDouble('double', kTestValues['flutter.double']);
      preferences.setStringList('List', kTestValues['flutter.List']);

      expect(values['flutter.String'], kTestValues['flutter.String']);
      expect(values['flutter.bool'], kTestValues['flutter.bool']);
      expect(values['flutter.int'], kTestValues['flutter.int']);
      expect(values['flutter.double'], kTestValues['flutter.double']);
      expect(values['flutter.List'], kTestValues['flutter.List']);

      preferences.clear();
      expect(values['flutter.String'], null);
      expect(values['flutter.bool'], null);
      expect(values['flutter.int'], null);
      expect(values['flutter.double'], null);
      expect(values['flutter.List'], null);
    });
  });
}

class MockSharedPreferences extends SharedPreferencesPlatform {
  MockSharedPreferences(this.values);
  final Map<String, Object> values;

  @override
  Future<Map<String, Object>> getAll() =>
      Future<Map<String, Object>>.value(values);

  @override
  Future<bool> remove(String key) {
    return Future<bool>.value(values.remove(key) != null);
  }

  @override
  Future<bool> clear() {
    values.clear();
    return Future<bool>.value(true);
  }

  @override
  Future<bool> setBool(String key, bool value) => _setValue(key, value);

  @override
  Future<bool> setDouble(String key, double value) => _setValue(key, value);

  @override
  Future<bool> setInt(String key, int value) => _setValue(key, value);

  @override
  Future<bool> setString(String key, String value) => _setValue(key, value);

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _setValue(key, value);

  Future<bool> _setValue(String key, Object value) {
    if (value == null) return remove(key);

    values[key] = value;
    return Future<bool>.value(true);
  }
}
