import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_inappmessaging/firebase_inappmessaging.dart';

void main() {
  group('$FirebaseInAppMessaging', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      log.clear();
      FirebaseInAppMessaging.channel.setMockMethodCallHandler((
          MethodCall methodcall) async {
        log.add(methodcall);
        return true;
      });
    });

    test('triggerEvent', () async {
      final FirebaseInAppMessaging fiam = new FirebaseInAppMessaging();
      fiam.triggerEvent('someEvent');
      expect(log,
          <Matcher>[
            isMethodCall(
                'triggerEvent', arguments: { "eventName": "someEvent"}),
          ]);
    });

    test('setMessagesSuppressed', () async {
      final FirebaseInAppMessaging fiam = new FirebaseInAppMessaging();
      fiam.setMessagesSuppressed(true);
      expect(log,
          <Matcher>[
            isMethodCall('setMessagesSuppressed', arguments: { true: true}),
          ]);

      fiam.setMessagesSuppressed(false);
      expect(log,
          <Matcher>[
            isMethodCall('setMessagesSuppressed', arguments: { true: true}),
            isMethodCall('setMessagesSuppressed', arguments: { false: false}),
          ]);
    });

    test('setDataCollectionEnabled', () async {
      final FirebaseInAppMessaging fiam = new FirebaseInAppMessaging();
      fiam.setDataCollectionEnabled(true);
      expect(log,
          <Matcher>[
            isMethodCall('dataCollectionEnabled', arguments: { true: true}),
          ]);

      fiam.setDataCollectionEnabled(false);
      expect(log,
          <Matcher>[
            isMethodCall('dataCollectionEnabled', arguments: { true: true}),
            isMethodCall('dataCollectionEnabled', arguments: { false: false}),
          ]);
    });
  });
}
