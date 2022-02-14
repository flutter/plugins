// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_ios/shared_preferences_ios.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'messages.g.dart';

class _MockSharedPreferencesApi implements TestUserDefaultsApi {
  final Map<String, Object> items = <String, Object>{};

  @override
  Map<String?, Object?> getAll() {
    return items;
  }

  @override
  void remove(String key) {
    items.remove(key);
  }

  @override
  void setBool(String key, bool value) {
    items[key] = value;
  }

  @override
  void setDouble(String key, double value) {
    items[key] = value;
  }

  @override
  void setValue(String key, Object value) {
    items[key] = value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _MockSharedPreferencesApi api = _MockSharedPreferencesApi();
  SharedPreferencesIos plugin = SharedPreferencesIos();

  setUp(() {
    api = _MockSharedPreferencesApi();
    TestUserDefaultsApi.setup(api);
    plugin = SharedPreferencesIos();
  });

  test('registerWith', () {
    SharedPreferencesIos.registerWith();
    expect(
        SharedPreferencesStorePlatform.instance, isA<SharedPreferencesIos>());
  });

  test('remove', () async {
    api.items['hi'] = 'world';
    expect(await plugin.remove('hi'), isTrue);
    expect(api.items.containsKey('hi'), isFalse);
  });

  test('clear', () async {
    api.items['hi'] = 'world';
    expect(await plugin.clear(), isTrue);
    expect(api.items.containsKey('hi'), isFalse);
  });

  test('getAll', () async {
    api.items['hi'] = 'world';
    api.items['bye'] = 'dust';
    final Map<String?, Object?> all = await plugin.getAll();
    expect(all.length, 2);
    expect(all['hi'], api.items['hi']);
    expect(all['bye'], api.items['bye']);
  });

  test('setValue', () async {
    expect(await plugin.setValue('Bool', 'Bool', true), isTrue);
    expect(api.items['Bool'], true);
    expect(await plugin.setValue('Double', 'Double', 1.5), isTrue);
    expect(api.items['Double'], 1.5);
    expect(await plugin.setValue('Int', 'Int', 12), isTrue);
    expect(api.items['Int'], 12);
    expect(await plugin.setValue('String', 'String', 'hi'), isTrue);
    expect(api.items['String'], 'hi');
    expect(await plugin.setValue('StringList', 'StringList', <String>['hi']),
        isTrue);
    expect(api.items['StringList'], <String>['hi']);
  });

  test('setValueMap', () {
    expect(() async {
      await plugin.setValue('Map', 'key', <String, String>{});
    }, throwsA(isA<PlatformException>()));
  });
}
