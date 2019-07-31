// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('firebase_in_app_messaging', () {
    FirebaseInAppMessaging fiam;

    setUp(() {
      fiam = FirebaseInAppMessaging();
    });

    test('triggerEvent', () {
      expect(fiam.triggerEvent('someEvent'), completes);
    });

    test('logging', () {
      expect(fiam.setMessagesSuppressed(true), completes);
      expect(fiam.setAutomaticDataCollectionEnabled(true), completes);
    });
  });
}
