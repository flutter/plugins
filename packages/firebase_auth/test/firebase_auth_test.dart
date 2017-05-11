// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('$FirebaseAuth', () {
    FirebaseAuth auth;

    const String kMockProviderId = 'firebase';
    const String kMockUid = '12345';
    const String kMockDisplayName = 'Flutter Test User';
    const String kMockPhotoUrl = 'http://www.example.com/';
    const String kMockEmail = 'test@example.com';

    setUp(() {
      MockPlatformChannel mockChannel = new MockPlatformChannel();

      when(mockChannel.invokeMethod('signInAnonymously')).thenAnswer((Invocation invocation) {
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
      });

      auth = new FirebaseAuth.private(mockChannel);
    });

    test('signInAnonymously', () async {
      FirebaseUser user = await auth.signInAnonymously();
      expect(user, isNotNull);
      expect(user, auth.currentUser);
      expect(user.isAnonymous, isTrue);
      expect(user.isEmailVerified, isFalse);
      expect(user.providerData.length, 1);
      UserInfo userInfo = user.providerData[0];
      expect(userInfo.providerId, kMockProviderId);
      expect(userInfo.uid, kMockUid);
      expect(userInfo.displayName, kMockDisplayName);
      expect(userInfo.photoUrl, kMockPhotoUrl);
      expect(userInfo.email, kMockEmail);
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel { }
