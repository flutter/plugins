// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/messages.g.dart',
  dartTestOut: 'test/messages.g.dart',
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  copyrightHeader: 'pigeons/copyright_header.txt',
))
@HostApi(dartHostTestHandler: 'TestSharedPreferencesApi')
abstract class SharedPreferencesApi {
  bool remove(String key);
  bool setBool(String key, bool value);
  bool setDouble(String key, double value);
  bool setInt(String key, int value);
  bool setString(String key, String value);
  bool setStringList(String key, List<String> value);
  bool clear();
  Map<String?, Object?> getAll();
}
