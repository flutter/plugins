// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
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
      expect(preferences.getString('String'), kTestValues['flutter.String']);
      expect(preferences.getBool('bool'), kTestValues['flutter.bool']);
      expect(preferences.getInt('int'), kTestValues['flutter.int']);
      expect(preferences.getDouble('double'), kTestValues['flutter.double']);
      expect(preferences.getStringList('List'), kTestValues['flutter.List']);
      expect(log, <Matcher>[]);
    });

    test('writing', () async {
      preferences.setString('String', kTestValues2['flutter.String']);
      preferences.setBool('bool', kTestValues2['flutter.bool']);
      preferences.setInt('int', kTestValues2['flutter.int']);
      preferences.setDouble('double', kTestValues2['flutter.double']);
      preferences.setStringList('List', kTestValues2['flutter.List']);
      expect(preferences.getString('String'), kTestValues2['flutter.String']);
      expect(preferences.getBool('bool'), kTestValues2['flutter.bool']);
      expect(preferences.getInt('int'), kTestValues2['flutter.int']);
      expect(preferences.getDouble('double'), kTestValues2['flutter.double']);
      expect(preferences.getStringList('List'), kTestValues2['flutter.List']);
      expect(log, equals(<MethodCall>[]));
      await preferences.commit();
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
          isMethodCall('commit', arguments: null),
        ],
      );
    });

    test('removing', () async {
      const String key = 'testKey';
      preferences
        ..setString(key, null)
        ..setBool(key, null)
        ..setInt(key, null)
        ..setDouble(key, null)
        ..setStringList(key, null)
        ..remove(key);
      await preferences.commit();
      expect(
        log,
        new List<Matcher>.filled(
          6,
          isMethodCall(
            'remove',
            arguments: <String, dynamic>{'key': 'flutter.$key'},
          ),
          growable: true,
        )..add(isMethodCall('commit', arguments: null)),
      );
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

    test('mocking', () async {
      expect(await channel.invokeMethod('getAll'), kTestValues);
      SharedPreferences.setMockInitialValues(kTestValues2);
      expect(await channel.invokeMethod('getAll'), kTestValues2);
    });
  });
}
