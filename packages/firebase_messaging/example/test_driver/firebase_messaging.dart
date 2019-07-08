import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseMessaging', () {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

    test('autoInitEnabled', () async {
      await firebaseMessaging.setAutoInitEnabled(false);
      expect(await firebaseMessaging.autoInitEnabled(), false);
      await firebaseMessaging.setAutoInitEnabled(true);
      expect(await firebaseMessaging.autoInitEnabled(), true);
    });

    test('subscribeToTopic', () async {
      firebaseMessaging.subscribeToTopic('foo');
    });

    test('unsubscribeFromTopic', () async {
      firebaseMessaging.unsubscribeFromTopic('foo');
    });

    test('deleteInstanceID', () async {
      final bool result = await firebaseMessaging.deleteInstanceID();
      expect(result, isTrue);
    });
  });
}
