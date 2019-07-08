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

    // TODO(jackson): token retrieval isn't working on test devices yet
    test('subscribeToTopic', () async {
      await firebaseMessaging.subscribeToTopic('foo');
    }, skip: true);

    // TODO(jackson): token retrieval isn't working on test devices yet
    test('unsubscribeFromTopic', () async {
      await firebaseMessaging.unsubscribeFromTopic('foo');
    }, skip: true);

    test('deleteInstanceID', () async {
      final bool result = await firebaseMessaging.deleteInstanceID();
      expect(result, isTrue);
    });
  });
}
