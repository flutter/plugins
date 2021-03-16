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
    const Map<String, Object> kTestValues = <String, Object>{
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

    late FakeSharedPreferencesStore store;
    late SharedPreferences preferences;

    setUp(() async {
      store = FakeSharedPreferencesStore(kTestValues);
      SharedPreferencesStorePlatform.instance = store;
      preferences = await SharedPreferences.getInstance();
      store.log.clear();
    });

    tearDown(() async {
      await preferences.clear();
      await store.clear();
      SharedPreferences.destroy();
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
      await preferences.remove(key);
      expect(
          store.log,
          List<Matcher>.filled(
            1,
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
      await preferences.setString(
          'String', kTestValues['flutter.String'] as String);
      expect(preferences.getString('String'), kTestValues['flutter.String']);

      SharedPreferences.setMockInitialValues(
          kTestValues2.cast<String, Object>());
      expect(preferences.getString('String'), kTestValues['flutter.String']);

      await preferences.reload();
      expect(preferences.getString('String'), kTestValues2['flutter.String']);
    });

    test('back to back calls should return same instance.', () async {
      final Future<SharedPreferences> first = SharedPreferences.getInstance();
      final Future<SharedPreferences> second = SharedPreferences.getInstance();
      expect(await first, await second);
    });

    test('string list type is dynamic (usually from method channel)', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'dynamic_list': <dynamic>['1', '2']
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? value = prefs.getStringList('dynamic_list');
      expect(value, <String>['1', '2']);
    });

    group('mocking', () {
      const String _key = 'dummy';
      const String _prefixedKey = 'flutter.' + _key;

      test('test 1', () async {
        SharedPreferences.setMockInitialValues(
            <String, Object>{_prefixedKey: 'my string'});
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? value = prefs.getString(_key);
        expect(value, 'my string');
      });

      test('test 2', () async {
        SharedPreferences.setMockInitialValues(
            <String, Object>{_prefixedKey: 'my other string'});
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? value = prefs.getString(_key);
        expect(value, 'my other string');
      });
    });

    test('writing copy of strings list', () async {
      final List<String> myList = <String>[];
      await preferences.setStringList('myList', myList);
      myList.add('foobar');

      final List<String> cachedList = preferences.getStringList('myList')!;
      expect(cachedList, <String>[]);

      cachedList.add('foobar2');

      expect(preferences.getStringList('myList'), <String>[]);
    });
  });

  group('Mock with non-prefixed', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, String>{
        'test': 'foo',
      });
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() {
      SharedPreferences.destroy();
    });

    test('calling mock initial values with non-prefixed keys succeeds',
        () async {
      final String value = prefs.getString('test')!;
      expect(value, 'foo');
    });
  });

  group('Custom prefix', () {
    const Map<String, Object> kTestValues = <String, Object>{
      'flutter.String': 'hello world',
      'flutter.bool': true,
      'flutter.int': 42,
      'flutter.double': 3.14159,
      'flutter.List': <String>['foo', 'bar'],
      'custom.customString': 'hello custom prefix',
      'custom.customBool': false,
      'custom.customInt': 24,
      'custom.customDouble': 2.71828,
      'custom.customList': <String>['boo', 'doo'],
    };

    tearDown(() {
      SharedPreferences.destroy();
    });

    test('read keys with default prefix only', () async {
      FakeSharedPreferencesStore store =
          FakeSharedPreferencesStore(kTestValues);
      SharedPreferencesStorePlatform.instance = store;
      SharedPreferences preferences = await SharedPreferences.getInstance();

      expect(preferences.prefix, 'flutter.');

      expect(preferences.getKeys(),
          Set<String>.from(['String', 'bool', 'int', 'double', 'List']));

      expect(preferences.get('String'), kTestValues['flutter.String']);
      expect(preferences.get('bool'), kTestValues['flutter.bool']);
      expect(preferences.get('int'), kTestValues['flutter.int']);
      expect(preferences.get('double'), kTestValues['flutter.double']);
      expect(preferences.get('List'), kTestValues['flutter.List']);

      expect(preferences.get('customString'), null);
      expect(preferences.get('customBool'), null);
      expect(preferences.get('customInt'), null);
      expect(preferences.get('customDouble'), null);
      expect(preferences.get('customList'), null);
    });

    test('read keys with custom prefix only', () async {
      FakeSharedPreferencesStore store =
          FakeSharedPreferencesStore(kTestValues);
      SharedPreferencesStorePlatform.instance = store;
      SharedPreferences preferences =
          await SharedPreferences.getInstance(prefix: 'custom.');

      expect(preferences.prefix, 'custom.');

      expect(
          preferences.getKeys(),
          Set<String>.from([
            'customString',
            'customBool',
            'customInt',
            'customDouble',
            'customList'
          ]));

      expect(preferences.get('String'), null);
      expect(preferences.get('bool'), null);
      expect(preferences.get('int'), null);
      expect(preferences.get('double'), null);
      expect(preferences.get('List'), null);

      expect(
          preferences.get('customString'), kTestValues['custom.customString']);
      expect(preferences.get('customBool'), kTestValues['custom.customBool']);
      expect(preferences.get('customInt'), kTestValues['custom.customInt']);
      expect(
          preferences.get('customDouble'), kTestValues['custom.customDouble']);
      expect(preferences.get('customList'), kTestValues['custom.customList']);
    });

    test('switch prefix should throw exception', () async {
      FakeSharedPreferencesStore store = FakeSharedPreferencesStore({});
      SharedPreferencesStorePlatform.instance = store;
      await SharedPreferences.getInstance();

      expect(
        () async => await SharedPreferences.getInstance(prefix: 'pre'),
        throwsA(isInstanceOf<SharedPreferencesException>()),
      );
    });

    test('no prefix should load all keys from device as is', () async {
      FakeSharedPreferencesStore store =
          FakeSharedPreferencesStore(kTestValues);
      SharedPreferencesStorePlatform.instance = store;
      SharedPreferences preferences =
          await SharedPreferences.getInstance(prefix: '');

      expect(
          preferences.getKeys(),
          Set<String>.from([
            'flutter.String',
            'flutter.bool',
            'flutter.int',
            'flutter.double',
            'flutter.List',
            'custom.customString',
            'custom.customBool',
            'custom.customInt',
            'custom.customDouble',
            'custom.customList'
          ]));
    });
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
