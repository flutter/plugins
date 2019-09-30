import 'dart:async';
import 'package:flutter/services.dart';
import 'shared_preferences_platform_interface.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/shared_preferences');

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
class MethodChannelSharedPreferences extends SharedPreferencesPlatform {
  @override
  Future<Map<String, Object>> getAll() =>
      _kChannel.invokeMapMethod<String, Object>('getAll');

  @override
  Future<bool> remove(String key) =>
      _kChannel.invokeMethod<bool>('remove', <String, dynamic>{'key': key});

  @override
  Future<bool> clear() => _kChannel.invokeMethod<bool>('clear');

  @override
  Future<bool> setBool(String key, bool value) => _kChannel.invokeMethod<bool>(
      'setBool', <String, dynamic>{'key': key, 'value': value});

  @override
  Future<bool> setInt(String key, int value) => _kChannel.invokeMethod<bool>(
      'setInt', <String, dynamic>{'key': key, 'value': value});

  @override
  Future<bool> setDouble(String key, double value) =>
      _kChannel.invokeMethod<bool>(
          'setDouble', <String, dynamic>{'key': key, 'value': value});

  @override
  Future<bool> setString(String key, String value) =>
      _kChannel.invokeMethod<bool>(
          'setString', <String, dynamic>{'key': key, 'value': value});

  @override
  Future<bool> setStringList(String key, List<String> value) =>
      _kChannel.invokeMethod<bool>(
          'setStringList', <String, dynamic>{'key': key, 'value': value});
}
