// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferences', () {
    const Map<String, dynamic> kTestValues = <String, dynamic>{
      'flutter.String': 'hello world',
      'flutter.bool': true,
      'flutter.int': 42,
      'flutter.double': 3.14159,
      'flutter.List': <String>['foo', 'bar'],
    };

    const Map<String, dynamic> kTestValues2 = <String, dynamic>{
      'flutter.String': 'goodbye world',
      'flutter.bool': false,
      'flutter.int': 1337,
      'flutter.double': 2.71828,
      'flutter.List': <String>['baz', 'quox'],
    };

    FakeSharedPreferencesStore store;
    SharedPreferences preferences;

    setUp(() async {
      store = FakeSharedPreferencesStore(kTestValues);
      SharedPreferencesStorePlatform.instance = store;
      preferences = await SharedPreferences.getInstance();
      store.log.clear();
    });

    tearDown(() async {
      await preferences.clear();
    });

    test('reading', () async {
      expect(preferences.get('String'), kTestValues['flutter.String']);
      expect(preferences.get('bool'), kTestValues['flutter.bool']);
      expect(preferences.get('int'), kTestValues['flutter.int']);
      expect(preferences.get('double'), kTestValues['flutter.double']);
      expect(preferences.get('List'), kTestValues['flutter.List']);
      expect(preferences.getString('String'), kTestValues['flutter.String']);
      expect(preferences.getBool('bool'), kTestValues['flutter.bool']);
      expect(preferences.getInt('int'), kTestValues['flutter.int']);
      expect(preferences.getDouble('double'), kTestValues['flutter.double']);
      expect(preferences.getStringList('List'), kTestValues['flutter.List']);
      expect(store.log, <Matcher>[]);
    });

    test('writing', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString('String', kTestValues2['flutter.String']),
        preferences.setBool('bool', kTestValues2['flutter.bool']),
        preferences.setInt('int', kTestValues2['flutter.int']),
        preferences.setDouble('double', kTestValues2['flutter.double']),
        preferences.setStringList('List', kTestValues2['flutter.List'])
      ]);
      expect(
        store.log,
        <Matcher>[
          isMethodCall('setValue', arguments: <dynamic>[
            'String',
            'flutter.String',
            kTestValues2['flutter.String'],
          ]),
          isMethodCall('setValue', arguments: <dynamic>[
            'Bool',
            'flutter.bool',
            kTestValues2['flutter.bool'],
          ]),
          isMethodCall('setValue', arguments: <dynamic>[
            'Int',
            'flutter.int',
            kTestValues2['flutter.int'],
          ]),
          isMethodCall('setValue', arguments: <dynamic>[
            'Double',
            'flutter.double',
            kTestValues2['flutter.double'],
          ]),
          isMethodCall('setValue', arguments: <dynamic>[
            'StringList',
            'flutter.List',
            kTestValues2['flutter.List'],
          ]),
        ],
      );
      store.log.clear();

      expect(preferences.getString('String'), kTestValues2['flutter.String']);
      expect(preferences.getBool('bool'), kTestValues2['flutter.bool']);
      expect(preferences.getInt('int'), kTestValues2['flutter.int']);
      expect(preferences.getDouble('double'), kTestValues2['flutter.double']);
      expect(preferences.getStringList('List'), kTestValues2['flutter.List']);
      expect(store.log, equals(<MethodCall>[]));
    });

    test('removing', () async {
      const String key = 'testKey';
      await preferences.setString(key, null);
      await preferences.setBool(key, null);
      await preferences.setInt(key, null);
      await preferences.setDouble(key, null);
      await preferences.setStringList(key, null);
      await preferences.remove(key);
      expect(
          store.log,
          List<Matcher>.filled(
            6,
            isMethodCall(
              'remove',
              arguments: 'flutter.$key',
            ),
            growable: true,
          ));
    });

    test('containsKey', () async {
      const String key = 'testKey';

      expect(false, preferences.containsKey(key));

      await preferences.setString(key, 'test');
      expect(true, preferences.containsKey(key));
    });

    test('clearing', () async {
      await preferences.clear();
      expect(preferences.getString('String'), null);
      expect(preferences.getBool('bool'), null);
      expect(preferences.getInt('int'), null);
      expect(preferences.getDouble('double'), null);
      expect(preferences.getStringList('List'), null);
      expect(store.log, <Matcher>[isMethodCall('clear', arguments: null)]);
    });

    test('reloading', () async {
      await preferences.setString('String', kTestValues['flutter.String']);
      expect(preferences.getString('String'), kTestValues['flutter.String']);

      SharedPreferences.setMockInitialValues(kTestValues2);
      expect(preferences.getString('String'), kTestValues['flutter.String']);

      await preferences.reload();
      expect(preferences.getString('String'), kTestValues2['flutter.String']);
    });

    test('back to back calls should return same instance.', () async {
      final Future<SharedPreferences> first = SharedPreferences.getInstance();
      final Future<SharedPreferences> second = SharedPreferences.getInstance();
      expect(await first, await second);
    });

    group('mocking', () {
      const String _key = 'dummy';
      const String _prefixedKey = 'flutter.' + _key;

      test('test 1', () async {
        SharedPreferences.setMockInitialValues(
            <String, dynamic>{_prefixedKey: 'my string'});
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String value = prefs.getString(_key);
        expect(value, 'my string');
      });

      test('test 2', () async {
        SharedPreferences.setMockInitialValues(
            <String, dynamic>{_prefixedKey: 'my other string'});
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String value = prefs.getString(_key);
        expect(value, 'my other string');
      });
    });

    test('writing copy of strings list', () async {
      final List<String> myList = <String>[];
      await preferences.setStringList("myList", myList);
      myList.add("foobar");

      final List<String> cachedList = preferences.getStringList('myList');
      expect(cachedList, <String>[]);

      cachedList.add("foobar2");

      expect(preferences.getStringList('myList'), <String>[]);
    });
  });

  test('calling mock initial values with non-prefixed keys succeeds', () async {
    SharedPreferences.setMockInitialValues(<String, String>{
      'test': 'foo',
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String value = prefs.getString('test');
    expect(value, 'foo');
  });
}

class FakeSharedPreferencesStore implements SharedPreferencesStorePlatform {
  FakeSharedPreferencesStore(Map<String, Object> data)
      : backend = InMemorySharedPreferencesStore.withData(data);

  final InMemorySharedPreferencesStore backend;
  final List<MethodCall> log = <MethodCall>[];

  @override
  bool get isMock => true;

  @override
  Future<bool> clear() {
    log.add(MethodCall('clear'));
    return backend.clear();
  }

  @override
  Future<Map<String, Object>> getAll() {
    log.add(MethodCall('getAll'));
    return backend.getAll();
  }

  @override
  Future<bool> remove(String key) {
    log.add(MethodCall('remove', key));
    return backend.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    log.add(MethodCall('setValue', <dynamic>[valueType, key, value]));
    return backend.setValue(valueType, key, value);
  }
}
