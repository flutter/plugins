// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesWindows', () {
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

    SharedPreferencesStorePlatform preferences;

    setUp(() {
      preferences = SharedPreferencesStorePlatform.instance;
      expect(preferences.runtimeType.toString(),
          equals('SharedPreferencesWindows'));
    });

    tearDown(() async {
      expect(await preferences.clear(), isTrue);
    });

    testWidgets('reading', (WidgetTester _) async {
      final Map<String, Object> values = await preferences.getAll();
      expect(values['String'], isNull);
      expect(values['bool'], isNull);
      expect(values['int'], isNull);
      expect(values['double'], isNull);
      expect(values['List'], isNull);
    });

    testWidgets('writing', (WidgetTester _) async {
      expect(
        await preferences.setValue(
            'String', 'String', kTestValues2['flutter.String']),
        isTrue,
      );
      expect(
        await preferences.setValue(
            'Bool', 'bool', kTestValues2['flutter.bool']),
        isTrue,
      );
      expect(
        await preferences.setValue('Int', 'int', kTestValues2['flutter.int']),
        isTrue,
      );
      expect(
        await preferences.setValue(
            'Double', 'double', kTestValues2['flutter.double']),
        isTrue,
      );
      expect(
        await preferences.setValue(
            'StringList', 'List', kTestValues2['flutter.List']),
        isTrue,
      );

      final Map<String, Object> values = await preferences.getAll();
      expect(values['String'], kTestValues2['flutter.String']);
      expect(values['bool'], kTestValues2['flutter.bool']);
      expect(values['int'], kTestValues2['flutter.int']);
      expect(values['double'], kTestValues2['flutter.double']);
      expect(values['List'], kTestValues2['flutter.List']);
    });

    testWidgets('removing', (WidgetTester _) async {
      const String key = 'testKey';
      await preferences.setValue('String', key, kTestValues['flutter.String']);
      await preferences.setValue('Bool', key, kTestValues['flutter.bool']);
      await preferences.setValue('Int', key, kTestValues['flutter.int']);
      await preferences.setValue('Double', key, kTestValues['flutter.double']);
      await preferences.setValue(
          'StringList', key, kTestValues['flutter.List']);
      await preferences.remove(key);
      final Map<String, Object> values = await preferences.getAll();
      expect(values[key], isNull);
    });

    testWidgets('clearing', (WidgetTester _) async {
      await preferences.setValue(
          'String', 'String', kTestValues['flutter.String']);
      await preferences.setValue('Bool', 'bool', kTestValues['flutter.bool']);
      await preferences.setValue('Int', 'int', kTestValues['flutter.int']);
      await preferences.setValue(
          'Double', 'double', kTestValues['flutter.double']);
      await preferences.setValue(
          'StringList', 'List', kTestValues['flutter.List']);
      await preferences.clear();
      final Map<String, Object> values = await preferences.getAll();
      expect(values['String'], null);
      expect(values['bool'], null);
      expect(values['int'], null);
      expect(values['double'], null);
      expect(values['List'], null);
    });
  });
}
