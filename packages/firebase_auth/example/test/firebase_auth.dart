// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseAuth', () {
    final FirebaseAuth auth = FirebaseAuth.instance;

    setUp(() async {
      await auth.signOut();
    });

    test('signInAnonymously', () async {
      final AuthResult result = await auth.signInAnonymously();
      final FirebaseUser user = result.user;
      final AdditionalUserInfo additionalUserInfo = result.additionalUserInfo;
      expect(additionalUserInfo.username, isNull);
      expect(additionalUserInfo.isNewUser, isNotNull);
      expect(additionalUserInfo.profile, isNull);
      // TODO(jackson): Fix behavior to be consistent across platforms
      // https://github.com/firebase/firebase-ios-sdk/issues/3450
      expect(
          additionalUserInfo.providerId == null ||
              additionalUserInfo.providerId == 'password',
          isTrue);
      expect(user.uid, isNotNull);
      expect(user.isAnonymous, isTrue);
      expect(user.metadata.creationTime.isAfter(DateTime(2018, 1, 1)), isTrue);
      expect(user.metadata.creationTime.isBefore(DateTime.now()), isTrue);
      final IdTokenResult tokenResult = await user.getIdToken();
      expect(tokenResult.token, isNotNull);
      expect(tokenResult.expirationTime.isAfter(DateTime.now()), isTrue);
      expect(tokenResult.authTime, isNotNull);
      expect(tokenResult.issuedAtTime, isNotNull);
      // TODO(jackson): Fix behavior to be consistent across platforms
      // https://github.com/firebase/firebase-ios-sdk/issues/3445
      expect(
          tokenResult.signInProvider == null ||
              tokenResult.signInProvider == 'anonymous',
          isTrue);
      expect(tokenResult.claims['provider_id'], 'anonymous');
      expect(tokenResult.claims['firebase']['sign_in_provider'], 'anonymous');
      expect(tokenResult.claims['user_id'], user.uid);
      await auth.signOut();
      final FirebaseUser user2 = (await auth.signInAnonymously()).user;
      expect(user2.uid, isNot(equals(user.uid)));
      expect(user2.metadata.creationTime.isBefore(user.metadata.creationTime),
          isFalse);
      expect(
          user2.metadata.lastSignInTime, equals(user2.metadata.creationTime));
    });

    test('email auth', () async {
      final String testEmail = 'testuser${Uuid().v4()}@example.com';
      final String testPassword = 'testpassword';
      AuthResult result = await auth.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      final FirebaseUser user = result.user;
      expect(user.uid, isNotNull);
      expect(user.isAnonymous, isFalse);
      auth.signOut();
      final Future<AuthResult> failedResult = auth.signInWithEmailAndPassword(
        email: testEmail,
        password: 'incorrect password',
      );
      expect(failedResult, throwsA(isInstanceOf<PlatformException>()));
      result = await auth.signInWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
      expect(result.user.uid, equals(user.uid));
      await user.delete();
    });

    test('isSignInWithEmailLink', () async {
      final String emailLink1 = 'https://www.example.com/action?mode=signIn&'
          'oobCode=oobCode&apiKey=API_KEY';
      final String emailLink2 =
          'https://www.example.com/action?mode=verifyEmail&'
          'oobCode=oobCode&apiKey=API_KEY';
      final String emailLink3 = 'https://www.example.com/action?mode=signIn';
      expect(await auth.isSignInWithEmailLink(emailLink1), true);
      expect(await auth.isSignInWithEmailLink(emailLink2), false);
      expect(await auth.isSignInWithEmailLink(emailLink3), false);
    });
  });
}
