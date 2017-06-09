// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('$SharedPreferences', () {
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/shared_preferences',
    );

    const Map<String, dynamic> kTestValues = const <String, dynamic>{
      'flutter.String': 'hello world',
      'flutter.bool': true,
      'flutter.int': 42,
      'flutter.double': 3.14159,
      'flutter.List': const <String>['foo', 'bar'],
    };

    const Map<String, dynamic> kTestValues2 = const <String, dynamic>{
      'flutter.String': 'goodbye world',
      'flutter.bool': false,
      'flutter.int': 1337,
      'flutter.double': 2.71828,
      'flutter.List': const <String>['baz', 'quox'],
    };

    final List<MethodCall> log = <MethodCall>[];
    SharedPreferences sharedPreferences;

    setUp(() async {
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getAll') {
          return kTestValues;
        }
        return null;
      });
      sharedPreferences = await SharedPreferences.getInstance();
      log.clear();
    });

    tearDown(() {
      sharedPreferences.clear();
    });

    test('reading', () async {
      expect(
          sharedPreferences.getString('String'), kTestValues['flutter.String']);
      expect(sharedPreferences.getBool('bool'), kTestValues['flutter.bool']);
      expect(sharedPreferences.getInt('int'), kTestValues['flutter.int']);
      expect(
          sharedPreferences.getDouble('double'), kTestValues['flutter.double']);
      expect(
          sharedPreferences.getStringList('List'), kTestValues['flutter.List']);
      expect(log, equals(<MethodCall>[]));
    });

    test('writing', () async {
      sharedPreferences.setString('String', kTestValues2['flutter.String']);
      sharedPreferences.setBool('bool', kTestValues2['flutter.bool']);
      sharedPreferences.setInt('int', kTestValues2['flutter.int']);
      sharedPreferences.setDouble('double', kTestValues2['flutter.double']);
      sharedPreferences.setStringList('List', kTestValues2['flutter.List']);
      expect(sharedPreferences.getString('String'),
          kTestValues2['flutter.String']);
      expect(sharedPreferences.getBool('bool'), kTestValues2['flutter.bool']);
      expect(sharedPreferences.getInt('int'), kTestValues2['flutter.int']);
      expect(sharedPreferences.getDouble('double'),
          kTestValues2['flutter.double']);
      expect(sharedPreferences.getStringList('List'),
          kTestValues2['flutter.List']);
      expect(log, equals(<MethodCall>[]));
      await sharedPreferences.commit();
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('setString', <String, dynamic>{
              'key': 'flutter.String',
              'value': kTestValues2['flutter.String']
            }),
            new MethodCall('setBool', <String, dynamic>{
              'key': 'flutter.bool',
              'value': kTestValues2['flutter.bool']
            }),
            new MethodCall('setInt', <String, dynamic>{
              'key': 'flutter.int',
              'value': kTestValues2['flutter.int']
            }),
            new MethodCall('setDouble', <String, dynamic>{
              'key': 'flutter.double',
              'value': kTestValues2['flutter.double']
            }),
            new MethodCall('setStringList', <String, dynamic>{
              'key': 'flutter.List',
              'value': kTestValues2['flutter.List']
            }),
            const MethodCall('commit'),
          ]));
    });

    test('clearing', () async {
      await sharedPreferences.clear();
      expect(sharedPreferences.getString('String'), null);
      expect(sharedPreferences.getBool('bool'), null);
      expect(sharedPreferences.getInt('int'), null);
      expect(sharedPreferences.getDouble('double'), null);
      expect(sharedPreferences.getStringList('List'), null);
      expect(log, equals(<MethodCall>[const MethodCall('clear')]));
    });

    test('mocking', () async {
      expect(await channel.invokeMethod('getAll'), kTestValues);
      SharedPreferences.setMockInitialValues(kTestValues2);
      expect(await channel.invokeMethod('getAll'), kTestValues2);
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}
