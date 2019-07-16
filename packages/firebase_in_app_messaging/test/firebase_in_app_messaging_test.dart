import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';

void main() {
  group('$FirebaseInAppMessaging', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      log.clear();
      FirebaseInAppMessaging.channel
          .setMockMethodCallHandler((MethodCall methodcall) async {
        log.add(methodcall);
        return true;
      });
    });

    test('triggerEvent', () async {
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
      fiam.triggerEvent('someEvent');
      expect(log, <Matcher>[
        isMethodCall('triggerEvent',
            arguments: <String, String>{"eventName": "someEvent"}),
      ]);
    });

    test('setMessagesSuppressed', () async {
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
      fiam.setMessagesSuppressed(true);
      expect(log, <Matcher>[
        isMethodCall('setMessagesSuppressed',
            arguments: <bool, bool>{true: true}),
      ]);

      fiam.setMessagesSuppressed(false);
      expect(log, <Matcher>[
        isMethodCall('setMessagesSuppressed',
            arguments: <bool, bool>{true: true}),
        isMethodCall('setMessagesSuppressed',
            arguments: <bool, bool>{false: false}),
      ]);
    });

    test('setDataCollectionEnabled', () async {
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
      fiam.setDataCollectionEnabled(true);
      expect(log, <Matcher>[
        isMethodCall('dataCollectionEnabled',
            arguments: <bool, bool>{true: true}),
      ]);

      fiam.setDataCollectionEnabled(false);
      expect(log, <Matcher>[
        isMethodCall('dataCollectionEnabled',
            arguments: <bool, bool>{true: true}),
        isMethodCall('dataCollectionEnabled',
            arguments: <bool, bool>{false: false}),
      ]);
    });
  });
}
