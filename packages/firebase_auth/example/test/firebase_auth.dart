// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  final Completer<String> completer = Completer<String>();
  enableFlutterDriverExtension(handler: (_) => completer.future);
  tearDownAll(() => completer.complete(null));

  group('$FirebaseAuth', () {
    final FirebaseAuth auth = FirebaseAuth.instance;

    test('anonymous auth', () async {
      final FirebaseUser user = await auth.signInAnonymously();
      expect(user.uid, isNotNull);
      expect(user.isAnonymous, isTrue);
    });

    test('email auth', () async {
      final String email = 'test@example.com';
      final String password = 'pa55word';
      FirebaseUser user;
      try {
        user = await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on PlatformException catch(e) {
        expect(e.code, 'ERROR_USER_NOT_FOUND');
        user = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      expect(user.uid, isNotNull);
      expect(user.isAnonymous, isFalse);
    });
  });
}
