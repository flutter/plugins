import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class RemoteConfig {
  static const MethodChannel _channel =
      const MethodChannel('firebase_remote_config');

  Map<String, dynamic> _parameters;
  Map<String, dynamic> _defaults;
  bool debugMode = false;

  RemoteConfig._() {}

  static RemoteConfig _instance = new RemoteConfig._();

  /// Gets the instance of RemoteConfig for the default Firebase app.
  static RemoteConfig get instance => _instance;

  Future<Map<String, dynamic>> fetch({int expiration: 43200}) async {
    _parameters = await _channel.invokeMethod(
      'RemoteConfig#fetch',
      <String, dynamic>{
        'debugMode': debugMode,
        'expiration': expiration
      }
    );
    return new Future<Map<String, dynamic>>.value(_parameters);
  }

  Future<void> setDefaults(Map<String, dynamic> defaults) async {
    await _channel.invokeMethod(
      'RemoteConfig#setDefaults',
      <String, dynamic> {
        'defaults': defaults
      }
    );
    _defaults = defaults;
    return new Future<void>.value();
  }

  String getString(String key) {
    final dynamic value = _parameters[key];
    if (value != null) {
      return UTF8.decode(value);
    } else {
      return _defaults[key];
    }
  }

  int getInt(String key) {
    final dynamic value = _parameters[key];
    if (value != null) {
      final String strValue = UTF8.decode(value);
      final intValue = int.parse(strValue, onError: (String source) => null);
      if (intValue == null) {
        // TODO: return error
      }
      return intValue;
    } else {
      return _defaults[key];
    }
  }

  double getDouble(String key) {
    final dynamic value = _parameters[key];
    if (value != null) {
      final String strValue = UTF8.decode(value);
      final doubleValue = double.parse(strValue, (String source) => null);
      if (doubleValue == null) {
        // TODO: return error
      }
      return doubleValue;
    } else {
      return _defaults[key];
    }
  }

  bool getBool(String key) {
    final dynamic value = _parameters[key];
    if (value != null) {
      final String strValue = UTF8.decode(value);
      return strValue.toLowerCase() == 'true';
    } else {
      return _defaults[key];
    }
  }

}
