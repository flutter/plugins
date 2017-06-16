// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('$FirebaseAuth', () {
    FirebaseAuth auth = FirebaseAuth.instance;
    List<MethodCall> log = <MethodCall>[];

    const String kMockProviderId = 'firebase';
    const String kMockUid = '12345';
    const String kMockDisplayName = 'Flutter Test User';
    const String kMockPhotoUrl = 'http://www.example.com/';
    const String kMockEmail = 'test@example.com';
    const String kMockPassword = 'passw0rd';
    const String kMockIdToken = '12345';
    const String kMockAccessToken = '67890';

    setUp(() {
      log.clear();
      FirebaseAuth.channel.setMockMethodCallHandler((MethodCall call) async {
        log.add(call);
        switch (call.method) {
          case "getToken":
            return kMockIdToken;
            break;
          default:
            return <String, dynamic>{
              'isAnonymous': true,
              'isEmailVerified': false,
              'providerData': <Map<String, String>>[
                {
                  'providerId': kMockProviderId,
                  'uid': kMockUid,
                  'displayName': kMockDisplayName,
                  'photoUrl': kMockPhotoUrl,
                  'email': kMockEmail,
                },
              ],
            };
            break;
        }
      });
    });
    void verifyUser(FirebaseUser user) {
      expect(user, isNotNull);
      expect(user, auth.currentUser);
      expect(user.isAnonymous, isTrue);
      expect(user.isEmailVerified, isFalse);
      expect(user.providerData.length, 1);
      final UserInfo userInfo = user.providerData[0];
      expect(userInfo.providerId, kMockProviderId);
      expect(userInfo.uid, kMockUid);
      expect(userInfo.displayName, kMockDisplayName);
      expect(userInfo.photoUrl, kMockPhotoUrl);
      expect(userInfo.email, kMockEmail);
    }

    test('signInAnonymously', () async {
      final FirebaseUser user = await auth.signInAnonymously();
      verifyUser(user);
      expect(await user.getToken(), equals(kMockIdToken));
      expect(await user.getToken(refresh: true), equals(kMockIdToken));
      expect(
        log,
        equals([
          new MethodCall('signInAnonymously'),
          new MethodCall('getToken', {'refresh': false}),
          new MethodCall('getToken', {'refresh': true}),
        ]),
      );
    });

    test('createUserWithEmailAndPassword', () async {
      final FirebaseUser user = await auth.createUserWithEmailAndPassword(
        email: kMockEmail,
        password: kMockPassword,
      );
      verifyUser(user);
      expect(
        log,
        equals([
          new MethodCall('createUserWithEmailAndPassword', {
            'email': kMockEmail,
            'password': kMockPassword,
          })
        ]),
      );
    });

    test('signInWithEmailAndPassword', () async {
      final FirebaseUser user = await auth.signInWithEmailAndPassword(
        email: kMockEmail,
        password: kMockPassword,
      );
      verifyUser(user);
      expect(
        log,
        equals([
          new MethodCall('signInWithEmailAndPassword', {
            'email': kMockEmail,
            'password': kMockPassword,
          })
        ]),
      );
    });

    test('signInWithGoogle', () async {
      final FirebaseUser user = await auth.signInWithGoogle(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      verifyUser(user);
      expect(
        log,
        equals([
          new MethodCall('signInWithGoogle', {
            'idToken': kMockIdToken,
            'accessToken': kMockAccessToken,
          })
        ]),
      );
    });
  });
}
