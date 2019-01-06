// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('$SharedPreferences', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );

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

    final List<MethodCall> log = <MethodCall>[];
    SharedPreferences preferences;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getAll') {
          return kTestValues;
        }
        return null;
      });
      preferences = await SharedPreferences.getInstance();
      log.clear();
    });

    tearDown(() {
      preferences.clear();
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
      expect(log, <Matcher>[]);
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
        log,
        <Matcher>[
          isMethodCall('setString', arguments: <String, dynamic>{
            'key': 'flutter.String',
            'value': kTestValues2['flutter.String']
          }),
          isMethodCall('setBool', arguments: <String, dynamic>{
            'key': 'flutter.bool',
            'value': kTestValues2['flutter.bool']
          }),
          isMethodCall('setInt', arguments: <String, dynamic>{
            'key': 'flutter.int',
            'value': kTestValues2['flutter.int']
          }),
          isMethodCall('setDouble', arguments: <String, dynamic>{
            'key': 'flutter.double',
            'value': kTestValues2['flutter.double']
          }),
          isMethodCall('setStringList', arguments: <String, dynamic>{
            'key': 'flutter.List',
            'value': kTestValues2['flutter.List']
          }),
        ],
      );
      log.clear();

      expect(preferences.getString('String'), kTestValues2['flutter.String']);
      expect(preferences.getBool('bool'), kTestValues2['flutter.bool']);
      expect(preferences.getInt('int'), kTestValues2['flutter.int']);
      expect(preferences.getDouble('double'), kTestValues2['flutter.double']);
      expect(preferences.getStringList('List'), kTestValues2['flutter.List']);
      expect(log, equals(<MethodCall>[]));
    });

    test('removing', () async {
      const String key = 'testKey';
      preferences
        ..setString(key, null)
        ..setBool(key, null)
        ..setInt(key, null)
        ..setDouble(key, null)
        ..setStringList(key, null);
      await preferences.remove(key);
      expect(
          log,
          List<Matcher>.filled(
            6,
            isMethodCall(
              'remove',
              arguments: <String, dynamic>{'key': 'flutter.$key'},
            ),
            growable: true,
          ));
    });

    test('containsKey', () async {
      const String key = 'testKey';

      expect(false, preferences.containsKey(key));

      preferences.setString(key, 'test');
      expect(true, preferences.containsKey(key));
    });

    test('clearing', () async {
      await preferences.clear();
      expect(preferences.getString('String'), null);
      expect(preferences.getBool('bool'), null);
      expect(preferences.getInt('int'), null);
      expect(preferences.getDouble('double'), null);
      expect(preferences.getStringList('List'), null);
      expect(log, <Matcher>[isMethodCall('clear', arguments: null)]);
    });

    test('reloading', () async {
      await preferences.setString('String', kTestValues['flutter.String']);
      expect(preferences.getString('String'), kTestValues['flutter.String']);

      SharedPreferences.setMockInitialValues(kTestValues2);
      expect(preferences.getString('String'), kTestValues['flutter.String']);

      await preferences.reload();
      expect(preferences.getString('String'), kTestValues2['flutter.String']);
    });

    test('mocking', () async {
      expect(
          await channel.invokeMapMethod<String, Object>('getAll'), kTestValues);
      SharedPreferences.setMockInitialValues(kTestValues2);
      expect(await channel.invokeMapMethod<String, Object>('getAll'),
          kTestValues2);
    });
  });

  group('$SharedPreferences custom prefix', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );

    const Map<String, dynamic> kTestValues = <String, dynamic>{
      'custom.String': 'hello world',
      'custom.bool': true,
      'custom.int': 42,
      'custom.double': 3.14159,
      'custom.List': <String>['foo', 'bar'],
    };

    const Map<String, dynamic> kTestValues2 = <String, dynamic>{
      'custom.String': 'goodbye world',
      'custom.bool': false,
      'custom.int': 1337,
      'custom.double': 2.71828,
      'custom.List': <String>['baz', 'quox'],
    };

    final List<MethodCall> log = <MethodCall>[];
    SharedPreferences preferences;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getAll') {
          return kTestValues;
        }
        return null;
      });
      preferences = await SharedPreferences.getInstance(prefix: 'custom.');
      log.clear();
    });

    tearDown(() {
      preferences.clear();
    });

    test('reading', () async {
      expect(preferences.get('String'), kTestValues['custom.String']);
      expect(preferences.get('bool'), kTestValues['custom.bool']);
      expect(preferences.get('int'), kTestValues['custom.int']);
      expect(preferences.get('double'), kTestValues['custom.double']);
      expect(preferences.get('List'), kTestValues['custom.List']);
      expect(preferences.getString('String'), kTestValues['custom.String']);
      expect(preferences.getBool('bool'), kTestValues['custom.bool']);
      expect(preferences.getInt('int'), kTestValues['custom.int']);
      expect(preferences.getDouble('double'), kTestValues['custom.double']);
      expect(preferences.getStringList('List'), kTestValues['custom.List']);
      expect(log, <Matcher>[]);
    });

    test('writing', () async {
      await Future.wait(<Future<bool>>[
        preferences.setString('String', kTestValues2['custom.String']),
        preferences.setBool('bool', kTestValues2['custom.bool']),
        preferences.setInt('int', kTestValues2['custom.int']),
        preferences.setDouble('double', kTestValues2['custom.double']),
        preferences.setStringList('List', kTestValues2['custom.List'])
      ]);
      expect(
        log,
        <Matcher>[
          isMethodCall('setString', arguments: <String, dynamic>{
            'key': 'custom.String',
            'value': kTestValues2['custom.String']
          }),
          isMethodCall('setBool', arguments: <String, dynamic>{
            'key': 'custom.bool',
            'value': kTestValues2['custom.bool']
          }),
          isMethodCall('setInt', arguments: <String, dynamic>{
            'key': 'custom.int',
            'value': kTestValues2['custom.int']
          }),
          isMethodCall('setDouble', arguments: <String, dynamic>{
            'key': 'custom.double',
            'value': kTestValues2['custom.double']
          }),
          isMethodCall('setStringList', arguments: <String, dynamic>{
            'key': 'custom.List',
            'value': kTestValues2['custom.List']
          }),
        ],
      );
      log.clear();

      expect(preferences.getString('String'), kTestValues2['custom.String']);
      expect(preferences.getBool('bool'), kTestValues2['custom.bool']);
      expect(preferences.getInt('int'), kTestValues2['custom.int']);
      expect(preferences.getDouble('double'), kTestValues2['custom.double']);
      expect(preferences.getStringList('List'), kTestValues2['custom.List']);
      expect(log, equals(<MethodCall>[]));
    });

    test('removing', () async {
      const String key = 'testKey';
      preferences
        ..setString(key, null)
        ..setBool(key, null)
        ..setInt(key, null)
        ..setDouble(key, null)
        ..setStringList(key, null);
      await preferences.remove(key);
      expect(
          log,
          List<Matcher>.filled(
            6,
            isMethodCall(
              'remove',
              arguments: <String, dynamic>{'key': 'custom.$key'},
            ),
            growable: true,
          ));
    });

    test('containsKey', () async {
      const String key = 'testKey';

      expect(false, preferences.containsKey(key));

      preferences.setString(key, 'test');
      expect(true, preferences.containsKey(key));
    });

    test('clearing', () async {
      await preferences.clear();
      expect(preferences.getString('String'), null);
      expect(preferences.getBool('bool'), null);
      expect(preferences.getInt('int'), null);
      expect(preferences.getDouble('double'), null);
      expect(preferences.getStringList('List'), null);
      expect(log, <Matcher>[isMethodCall('clear', arguments: null)]);
    });

    test('reloading', () async {
      await preferences.setString('String', kTestValues['custom.String']);
      expect(preferences.getString('String'), kTestValues['custom.String']);

      SharedPreferences.setMockInitialValues(kTestValues2);
      expect(preferences.getString('String'), kTestValues['custom.String']);

      await preferences.reload();
      expect(preferences.getString('String'), kTestValues2['custom.String']);
    });

    test('mocking', () async {
      final Map<String, String> params = <String, String>{'prefix': 'custom.'};
      expect(await channel.invokeMapMethod<String, Object>('getAll', params),
          kTestValues);
      SharedPreferences.setMockInitialValues(kTestValues2);
      expect(await channel.invokeMapMethod<String, Object>('getAll', params),
          kTestValues2);
    });
  });
}
