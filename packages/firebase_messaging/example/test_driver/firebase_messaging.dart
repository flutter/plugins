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

    test('getToken', () async {
      final String token = await firebaseMessaging.getToken();
      expect(token, isNotNull);
    });

    test('subscribeToTopic and unsubscribeFromTopic', () async {
      await firebaseMessaging.subscribeToTopic('foo');
      firebaseMessaging.unsubscribeFromTopic('foo');
    });
  });
}
