import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
      expect(log,
          <Matcher>[isMethodCall('setMessagesSuppressed', arguments: true)]);

      fiam.setMessagesSuppressed(false);
      expect(log, <Matcher>[
        isMethodCall('setMessagesSuppressed', arguments: true),
        isMethodCall('setMessagesSuppressed', arguments: false),
      ]);
    });

    test('setDataCollectionEnabled', () async {
      final FirebaseInAppMessaging fiam = FirebaseInAppMessaging();
      fiam.setAutomaticDataCollectionEnabled(true);
      expect(log, <Matcher>[
        isMethodCall('setAutomaticDataCollectionEnabled', arguments: true)
      ]);

      fiam.setAutomaticDataCollectionEnabled(false);
      expect(log, <Matcher>[
        isMethodCall('setAutomaticDataCollectionEnabled', arguments: true),
        isMethodCall('setAutomaticDataCollectionEnabled', arguments: false),
      ]);
    });
  });
}
