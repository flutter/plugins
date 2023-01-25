// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  input: 'pigeons/messages.dart',
  javaOut:
      'android/src/main/java/io/flutter/plugins/sharedpreferences/Messages.java',
  javaOptions: JavaOptions(
      className: 'Messages', package: 'io.flutter.plugins.sharedpreferences'),
  dartOut: 'lib/messages.g.dart',
  dartTestOut: 'test/messages_test.g.dart',
  copyrightHeader: 'pigeons/copyright.txt',
))
@HostApi(dartHostTestHandler: 'TestSharedPreferencesApi')
abstract class SharedPreferencesApi {
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool remove(String key);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setBool(String key, bool value);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setString(String key, String value);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setInt(String key, Object value);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setDouble(String key, double value);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool setStringList(String key, List<String> value);
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  bool clear();
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  Map<String, dynamic> getAll();
}
