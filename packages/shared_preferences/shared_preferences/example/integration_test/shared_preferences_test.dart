// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('$SharedPreferences', () {
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

    late SharedPreferences preferences;

    setUp(() async {
      preferences = await SharedPreferences.getInstance();
    });

    tearDown(() {
      preferences.clear();
    });

    testWidgets('reading', (WidgetTester _) async {
      expect(preferences.get('String'), isNull);
      expect(preferences.get('bool'), isNull);
      expect(preferences.get('int'), isNull);
      expect(preferences.get('double'), isNull);
      expect(preferences.get('List'), isNull);
      expect(preferences.getString('String'), isNull);
      expect(preferences.getBool('bool'), isNull);
      expect(preferences.getInt('int'), isNull);
      expect(preferences.getDouble('double'), isNull);
      expect(preferences.getStringList('List'), isNull);
    });

    testWidgets('writing', (WidgetTester _) async {
      await Future.wait(<Future<bool>>[
        preferences.setString('String', kTestValues2['flutter.String']),
        preferences.setBool('bool', kTestValues2['flutter.bool']),
        preferences.setInt('int', kTestValues2['flutter.int']),
        preferences.setDouble('double', kTestValues2['flutter.double']),
        preferences.setStringList('List', kTestValues2['flutter.List'])
      ]);
      expect(preferences.getString('String'), kTestValues2['flutter.String']);
      expect(preferences.getBool('bool'), kTestValues2['flutter.bool']);
      expect(preferences.getInt('int'), kTestValues2['flutter.int']);
      expect(preferences.getDouble('double'), kTestValues2['flutter.double']);
      expect(preferences.getStringList('List'), kTestValues2['flutter.List']);
    });

    testWidgets('removing', (WidgetTester _) async {
      const String key = 'testKey';
      await preferences.setString(key, kTestValues['flutter.String']);
      await preferences.setBool(key, kTestValues['flutter.bool']);
      await preferences.setInt(key, kTestValues['flutter.int']);
      await preferences.setDouble(key, kTestValues['flutter.double']);
      await preferences.setStringList(key, kTestValues['flutter.List']);
      await preferences.remove(key);
      expect(preferences.get('testKey'), isNull);
    });

    testWidgets('clearing', (WidgetTester _) async {
      await preferences.setString('String', kTestValues['flutter.String']);
      await preferences.setBool('bool', kTestValues['flutter.bool']);
      await preferences.setInt('int', kTestValues['flutter.int']);
      await preferences.setDouble('double', kTestValues['flutter.double']);
      await preferences.setStringList('List', kTestValues['flutter.List']);
      await preferences.clear();
      expect(preferences.getString('String'), null);
      expect(preferences.getBool('bool'), null);
      expect(preferences.getInt('int'), null);
      expect(preferences.getDouble('double'), null);
      expect(preferences.getStringList('List'), null);
    });

    testWidgets('simultaneous writes', (WidgetTester _) async {
      final List<Future<bool>> writes = <Future<bool>>[];
      final int writeCount = 100;
      for (int i = 1; i <= writeCount; i++) {
        writes.add(preferences.setInt('int', i));
      }
      List<bool> result = await Future.wait(writes, eagerError: true);
      // All writes should succeed.
      expect(result.where((element) => !element), isEmpty);
      // The last write should win.
      expect(preferences.getInt('int'), writeCount);
    });

    testWidgets(
        'string clash with lists, big integers and doubles (Android only)',
        (WidgetTester _) async {
      await preferences.clear();
      // special prefixes plus a string value
      expect(
          // prefix for lists
          preferences.setString(
              'String',
              'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu' +
                  kTestValues2['flutter.String']),
          throwsA(isA<PlatformException>()));
      await preferences.reload();
      expect(preferences.getString('String'), null);
      expect(
          // prefix for big integers
          preferences.setString(
              'String',
              'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy' +
                  kTestValues2['flutter.String']),
          throwsA(isA<PlatformException>()));
      await preferences.reload();
      expect(preferences.getString('String'), null);
      expect(
          // prefix for doubles
          preferences.setString(
              'String',
              'VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu' +
                  kTestValues2['flutter.String']),
          throwsA(isA<PlatformException>()));
      await preferences.reload();
      expect(preferences.getString('String'), null);
    }, skip: !Platform.isAndroid);
  });
}
