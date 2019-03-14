import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final Completer<void> completer = Completer<void>();
  enableFlutterDriverExtension(handler: (String _) => completer.future);

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

    SharedPreferences preferences;

    setUp(() async {
      preferences = await SharedPreferences.getInstance();
    });

    tearDown(() {
      preferences.clear();
    });

    tearDownAll(() {
      completer.complete(null);
    });

    test('reading', () async {
      expect(preferences.get('String'), isNotNull);
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

    test('writing', () async {
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

    test('removing', () async {
      const String key = 'testKey';
      preferences
        ..setString(key, null)
        ..setBool(key, null)
        ..setInt(key, null)
        ..setDouble(key, null)
        ..setStringList(key, null);
      await preferences.remove(key);
      expect(preferences.get('testKey'), isNull);
    });

    test('clearing', () async {
      await preferences.clear();
      expect(preferences.getString('String'), null);
      expect(preferences.getBool('bool'), null);
      expect(preferences.getInt('int'), null);
      expect(preferences.getDouble('double'), null);
      expect(preferences.getStringList('List'), null);
    });
  });
}

