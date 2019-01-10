// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';

import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$FirebaseInAppMessaging', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      FirebaseInAppMessaging.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
      log.clear();
    });

    test('setMessageDisplaySuppressed', () async {
      await FirebaseInAppMessaging.instance.setMessageDisplaySuppressed(true);
      expect(log, <Matcher>[
        isMethodCall(
          'FirebaseInAppMessaging#setMessageDisplaySuppressed',
          arguments: true,
        )
      ]);
      log.clear();
      await FirebaseInAppMessaging.instance.setMessageDisplaySuppressed(false);
      expect(log, <Matcher>[
        isMethodCall(
          'FirebaseInAppMessaging#setMessageDisplaySuppressed',
          arguments: false,
        )
      ]);
    });

    test('setAutomaticDataCollectionEnabled', () async {
      await FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(true);
      expect(log, <Matcher>[
        isMethodCall(
          'FirebaseInAppMessaging#setAutomaticDataCollectionEnabled',
          arguments: true,
        )
      ]);
      log.clear();
      await FirebaseInAppMessaging.instance.setAutomaticDataCollectionEnabled(false);
      expect(log, <Matcher>[
        isMethodCall(
          'FirebaseInAppMessaging#setAutomaticDataCollectionEnabled',
          arguments: false,
        )
      ]);
    });

    test('setMessagingDisplay', () async {
      InAppMessagingDisplayMessage _message;
      InAppMessagingDisplayDelegate _delegate;
      FirebaseInAppMessaging.instance.setMessagingDisplay((message, delegate) {
        _message = message;
        _delegate = delegate;
      });
      expect(log, <Matcher>[
        isMethodCall(
          'FirebaseInAppMessaging#useFlutterMessageDisplayComponent',
          arguments: true,
        )
      ]);
      log.clear();

      await BinaryMessages.handlePlatformMessage(
          FirebaseInAppMessaging.channel.name,
          FirebaseInAppMessaging.channel.codec.encodeMethodCall(
            MethodCall(
              'FirebaseInAppMessaging#_displayMessage',
              <String, dynamic>{
                'message': <String, dynamic>{
                  'messageID': '42',
                  'renderAsTestMessage': true,
                },
                'delegate': 1,
              },
            ),
          ),
          (_) {},
      );
      expect(_message.messageID, equals(42));
      expect(_message.renderAsTestMessage, equals(true));
      // TODO(jackson): More tests

      await FirebaseInAppMessaging.instance.setMessagingDisplay(null);
      expect(log, <Matcher>[
        isMethodCall(
          'FirebaseInAppMessaging#useFlutterMessageDisplayComponent',
          arguments: false,
        )
      ]);
    });
  });
}
