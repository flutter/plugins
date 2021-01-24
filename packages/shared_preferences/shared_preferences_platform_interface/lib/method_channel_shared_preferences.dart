// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';

import 'shared_preferences_platform_interface.dart';

const MethodChannel _kChannel =
    MethodChannel('plugins.flutter.io/shared_preferences');

/// Wraps NSUserDefaults (on iOS) and SharedPreferences (on Android), providing
/// a persistent store for simple data.
///
/// Data is persisted to disk asynchronously.
class MethodChannelSharedPreferencesStore
    extends SharedPreferencesStorePlatform {
  @override
  Future<bool> remove(String key) {
    return _invokeBoolMethod('remove', <String, dynamic>{
      'key': key,
    });
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    return _invokeBoolMethod('set$valueType', <String, dynamic>{
      'key': key,
      'value': value,
    });
  }

  Future<bool> _invokeBoolMethod(String method, Map<String, dynamic> params) {
    return _kChannel
        .invokeMethod<bool>(method, params)
        // TODO(yjbanov): I copied this from the original
        //                shared_preferences.dart implementation, but I
        //                actually do not know why it's necessary to pipe the
        //                result through an identity function.
        //
        //                Source: https://github.com/flutter/plugins/blob/3a87296a40a2624d200917d58f036baa9fb18df8/packages/shared_preferences/lib/shared_preferences.dart#L134
        .then<bool>((dynamic result) => result);
  }

  @override
  Future<bool> clear() {
    return _kChannel.invokeMethod<bool>('clear');
  }

  @override
  Future<Map<String, Object>> getAll() {
    return _kChannel.invokeMapMethod<String, Object>('getAll');
  }
}
