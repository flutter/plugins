// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  setUp(() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser currentUser = await auth.currentUser();
    if (currentUser != null) {
      await auth.signOut();
    }
  });

  group('$FirebaseAuth', () {
    final FirebaseAuth auth = FirebaseAuth.instance;

    test('signInAnonymously', () async {
      final int start = DateTime.now().millisecondsSinceEpoch;
      final FirebaseUser user = await auth.signInAnonymously();
      expect(user.uid, isNotNull);
      expect(user.isAnonymous, isTrue);
      expect(user.metadata.lastSignInTimestamp, greaterThan(start));
      expect(user.metadata.creationTimestamp, greaterThan(start));
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
