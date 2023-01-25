// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_platform_interface/method_channel_shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../test/messages_test.g.dart';

// Mock Implementation of the SharedPreferencesApi
class _MockAPI extends TestSharedPreferencesApi {
  final Map<String, Object> items = <String, Object>{};

  @override
  bool clear() {
    items.clear();
    return true;
  }

  @override
  Map<String?, dynamic> getAll() {
    return items;
  }

  @override
  bool remove(String key) {
    items.remove(key);
    return true;
  }

  @override
  bool setBool(String key, bool value) {
    items[key] = value;
    return true;
  }

  @override
  bool setDouble(String key, double value) {
    items[key] = value;
    return true;
  }

  @override
  bool setInt(String key, Object value) {
    items[key] = value;
    return true;
  }

  @override
  bool setString(String key, String value) {
    items[key] = value;
    return true;
  }

  @override
  bool setStringList(String key, List<String?> value) {
    items[key] = value;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockAPI api;

  group(MethodChannelSharedPreferencesStore, () {
    setUp(() async {
      api = _MockAPI();
      TestSharedPreferencesApi.setup(api);
    });

    test('registered instance', () {
      SharedPreferencesAndroid.registerWith();
      expect(SharedPreferencesStorePlatform.instance,
          isA<SharedPreferencesAndroid>());
    });
    test('remove', () async {
      final SharedPreferencesAndroid plugin = SharedPreferencesAndroid();
      api.items['flutter.hi'] = 'world';
      expect(await plugin.remove('flutter.hi'), isTrue);
      expect(api.items.containsKey('flutter.hi'), isFalse);
    });

    test('clear', () async {
      final SharedPreferencesAndroid plugin = SharedPreferencesAndroid();
      api.items['flutter.hi'] = 'world';
      expect(await plugin.clear(), isTrue);
      expect(api.items.containsKey('flutter.hi'), isFalse);
    });

    test('getAll', () async {
      final SharedPreferencesAndroid plugin = SharedPreferencesAndroid();
      api.items['flutter.aBool'] = true;
      api.items['flutter.aDouble'] = 3.14;
      api.items['flutter.anInt'] = 42;
      api.items['flutter.aString'] = 'hello world';
      api.items['flutter.aStringList'] = <String>['hello', 'world'];
      final Map<String?, Object?> all = await plugin.getAll();
      expect(all.length, 5);
      expect(all['flutter.aBool'], api.items['flutter.aBool']);
      expect(all['flutter.aDouble'],
          closeTo(api.items['flutter.aDouble']! as num, 0.0001));
      expect(all['flutter.anInt'], api.items['flutter.anInt']);
      expect(all['flutter.aString'], api.items['flutter.aString']);
      expect(all['flutter.aStringList'], api.items['flutter.aStringList']);
    });

    test('setValue', () async {
      final SharedPreferencesAndroid plugin = SharedPreferencesAndroid();
      expect(await plugin.setValue('Bool', 'flutter.Bool', true), isTrue);
      expect(api.items['flutter.Bool'], true);
      expect(await plugin.setValue('Double', 'flutter.Double', 1.5), isTrue);
      expect(api.items['flutter.Double'], 1.5);
      expect(await plugin.setValue('Int', 'flutter.Int', 12), isTrue);
      expect(api.items['flutter.Int'], 12);
      expect(await plugin.setValue('String', 'flutter.String', 'hi'), isTrue);
      expect(api.items['flutter.String'], 'hi');
      expect(
          await plugin
              .setValue('StringList', 'flutter.StringList', <String>['hi']),
          isTrue);
      expect(api.items['flutter.StringList'], <String>['hi']);
    });
    test('setValue with unsupported type', () {
      final SharedPreferencesAndroid plugin = SharedPreferencesAndroid();
      expect(() async {
        await plugin.setValue('Map', 'flutter.key', <String, String>{});
      }, throwsA(isA<PlatformException>()));
    });
  });
}
