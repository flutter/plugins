import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e2e/e2e.dart';

void main() {
  E2EWidgetsFlutterBinding.ensureInitialized();

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

    const String filename1 = "SharedPreferencesTests1";
    const String filename2 = "SharedPreferencesTests2";

    SharedPreferences preferences1;
    SharedPreferences preferences2;

    setUp(() async {
      preferences1 = await SharedPreferences.getInstance(filename: filename1);
      preferences2 = await SharedPreferences.getInstance(filename: filename2);
    });

    tearDown(() {
      preferences1.clear();
    });

    test('reading', () async {
      expect(preferences1.get('String'), isNull);
      expect(preferences1.get('bool'), isNull);
      expect(preferences1.get('int'), isNull);
      expect(preferences1.get('double'), isNull);
      expect(preferences1.get('List'), isNull);
      expect(preferences1.getString('String'), isNull);
      expect(preferences1.getBool('bool'), isNull);
      expect(preferences1.getInt('int'), isNull);
      expect(preferences1.getDouble('double'), isNull);
      expect(preferences1.getStringList('List'), isNull);

      expect(preferences2.get('String'), isNull);
      expect(preferences2.get('bool'), isNull);
      expect(preferences2.get('int'), isNull);
      expect(preferences2.get('double'), isNull);
      expect(preferences2.get('List'), isNull);
      expect(preferences2.getString('String'), isNull);
      expect(preferences2.getBool('bool'), isNull);
      expect(preferences2.getInt('int'), isNull);
      expect(preferences2.getDouble('double'), isNull);
      expect(preferences2.getStringList('List'), isNull);
    });

    test('writing', () async {
      await Future.wait(<Future<bool>>[
        preferences1.setString('String', kTestValues2['flutter.String']),
        preferences1.setBool('bool', kTestValues2['flutter.bool']),
        preferences1.setInt('int', kTestValues2['flutter.int']),
        preferences1.setDouble('double', kTestValues2['flutter.double']),
        preferences1.setStringList('List', kTestValues2['flutter.List']),

        preferences2.setString('String', kTestValues2['flutter.String']),
        preferences2.setBool('bool', kTestValues2['flutter.bool']),
        preferences2.setInt('int', kTestValues2['flutter.int']),
        preferences2.setDouble('double', kTestValues2['flutter.double']),
        preferences2.setStringList('List', kTestValues2['flutter.List'])
      ]);
      expect(preferences1.getString('String'), kTestValues2['flutter.String']);
      expect(preferences1.getBool('bool'), kTestValues2['flutter.bool']);
      expect(preferences1.getInt('int'), kTestValues2['flutter.int']);
      expect(preferences1.getDouble('double'), kTestValues2['flutter.double']);
      expect(preferences1.getStringList('List'), kTestValues2['flutter.List']);
      
      expect(preferences2.getString('String'), kTestValues2['flutter.String']);
      expect(preferences2.getBool('bool'), kTestValues2['flutter.bool']);
      expect(preferences2.getInt('int'), kTestValues2['flutter.int']);
      expect(preferences2.getDouble('double'), kTestValues2['flutter.double']);
      expect(preferences2.getStringList('List'), kTestValues2['flutter.List']);
    });

    test('removing', () async {
      const String key = 'testKey';
      preferences1
        ..setString(key, kTestValues['flutter.String'])
        ..setBool(key, kTestValues['flutter.bool'])
        ..setInt(key, kTestValues['flutter.int'])
        ..setDouble(key, kTestValues['flutter.double'])
        ..setStringList(key, kTestValues['flutter.List']);
      await preferences1.remove(key);
      expect(preferences1.get('testKey'), isNull);
      
      preferences2
        ..setString(key, kTestValues['flutter.String'])
        ..setBool(key, kTestValues['flutter.bool'])
        ..setInt(key, kTestValues['flutter.int'])
        ..setDouble(key, kTestValues['flutter.double'])
        ..setStringList(key, kTestValues['flutter.List']);
      await preferences2.remove(key);
      expect(preferences2.get('testKey'), isNull);
    });

    test('clearing', () async {
      preferences1
        ..setString('String', kTestValues['flutter.String'])
        ..setBool('bool', kTestValues['flutter.bool'])
        ..setInt('int', kTestValues['flutter.int'])
        ..setDouble('double', kTestValues['flutter.double'])
        ..setStringList('List', kTestValues['flutter.List']);
      await preferences1.clear();
      expect(preferences1.getString('String'), null);
      expect(preferences1.getBool('bool'), null);
      expect(preferences1.getInt('int'), null);
      expect(preferences1.getDouble('double'), null);
      expect(preferences1.getStringList('List'), null);

      preferences2
        ..setString('String', kTestValues['flutter.String'])
        ..setBool('bool', kTestValues['flutter.bool'])
        ..setInt('int', kTestValues['flutter.int'])
        ..setDouble('double', kTestValues['flutter.double'])
        ..setStringList('List', kTestValues['flutter.List']);
      await preferences2.clear();
      expect(preferences2.getString('String'), null);
      expect(preferences2.getBool('bool'), null);
      expect(preferences2.getInt('int'), null);
      expect(preferences2.getDouble('double'), null);
      expect(preferences2.getStringList('List'), null);
    });
  });
}
