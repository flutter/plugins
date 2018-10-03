// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const String kMockProviderId = 'firebase';
const String kMockUid = '12345';
const String kMockDisplayName = 'Flutter Test User';
const String kMockPhotoUrl = 'http://www.example.com/';
const String kMockEmail = 'test@example.com';
const String kMockPassword = 'passw0rd';
const String kMockIdToken = '12345';
const String kMockAccessToken = '67890';
const String kMockAuthToken = '23456';
const String kMockAuthTokenSecret = '78901';
const String kMockCustomToken = '12345';
const String kMockPhoneNumber = '5555555555';
const String kMockVerificationId = '12345';
const String kMockSmsCode = '123456';
const String kMockLanguage = 'en';

void main() {
  group('$FirebaseAuth', () {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final List<MethodCall> log = <MethodCall>[];

    int mockHandleId = 0;

    setUp(() {
      log.clear();
      FirebaseAuth.channel.setMockMethodCallHandler((MethodCall call) async {
        log.add(call);
        switch (call.method) {
          case "getIdToken":
            return kMockIdToken;
            break;
          case "startListeningAuthState":
            return mockHandleId++;
            break;
          case "sendPasswordResetEmail":
          case "updateEmail":
          case "updatePassword":
          case "updateProfile":
            return null;
            break;
          case "fetchProvidersForEmail":
            return List<String>(0);
            break;
          case "verifyPhoneNumber":
            return null;
            break;
          default:
            return mockFirebaseUser();
            break;
        }
      });
    });
    void verifyUser(FirebaseUser user) {
      expect(user, isNotNull);
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

    test('currentUser', () async {
      final FirebaseUser user = await auth.currentUser();
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall('currentUser', arguments: null),
        ],
      );
    });

    test('signInAnonymously', () async {
      final FirebaseUser user = await auth.signInAnonymously();
      verifyUser(user);
      expect(await user.getIdToken(), equals(kMockIdToken));
      expect(await user.getIdToken(refresh: true), equals(kMockIdToken));
      expect(
        log,
        <Matcher>[
          isMethodCall('signInAnonymously', arguments: null),
          isMethodCall(
            'getIdToken',
            arguments: <String, bool>{'refresh': false},
          ),
          isMethodCall(
            'getIdToken',
            arguments: <String, bool>{'refresh': true},
          ),
        ],
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
        <Matcher>[
          isMethodCall(
            'createUserWithEmailAndPassword',
            arguments: <String, String>{
              'email': kMockEmail,
              'password': kMockPassword,
            },
          ),
        ],
      );
    });

    test('fetchProvidersForEmail', () async {
      final List<String> providers =
          await auth.fetchProvidersForEmail(email: kMockEmail);
      expect(providers, isNotNull);
      expect(providers.length, 0);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'fetchProvidersForEmail',
            arguments: <String, String>{'email': kMockEmail},
          ),
        ],
      );
    });

    test('linkWithEmailAndPassword', () async {
      final FirebaseUser user = await auth.linkWithEmailAndPassword(
        email: kMockEmail,
        password: kMockPassword,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithEmailAndPassword',
            arguments: <String, String>{
              'email': kMockEmail,
              'password': kMockPassword,
            },
          ),
        ],
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
        <Matcher>[
          isMethodCall(
            'signInWithGoogle',
            arguments: <String, String>{
              'idToken': kMockIdToken,
              'accessToken': kMockAccessToken,
            },
          ),
        ],
      );
    });

    test('signInWithPhoneNumber', () async {
      await auth.signInWithPhoneNumber(
          verificationId: kMockVerificationId, smsCode: kMockSmsCode);
      expect(log, <Matcher>[
        isMethodCall('signInWithPhoneNumber', arguments: <String, dynamic>{
          'verificationId': kMockVerificationId,
          'smsCode': kMockSmsCode,
        })
      ]);
    });

    test('verifyPhoneNumber', () async {
      await auth.verifyPhoneNumber(
          phoneNumber: kMockPhoneNumber,
          timeout: const Duration(seconds: 5),
          verificationCompleted: null,
          verificationFailed: null,
          codeSent: null,
          codeAutoRetrievalTimeout: null);
      expect(log, <Matcher>[
        isMethodCall('verifyPhoneNumber', arguments: <String, dynamic>{
          'handle': 1,
          'phoneNumber': kMockPhoneNumber,
          'timeout': 5000,
          'forceResendingToken': null,
        })
      ]);
    });

    test('linkWithGoogleCredential', () async {
      final FirebaseUser user = await auth.linkWithGoogleCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithGoogleCredential',
            arguments: <String, String>{
              'idToken': kMockIdToken,
              'accessToken': kMockAccessToken,
            },
          ),
        ],
      );
    });

    test('linkWithFacebookCredential', () async {
      final FirebaseUser user = await auth.linkWithFacebookCredential(
        accessToken: kMockAccessToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithFacebookCredential',
            arguments: <String, String>{
              'accessToken': kMockAccessToken,
            },
          ),
        ],
      );
    });

    test('linkWithTwitterCredential', () async {
      final FirebaseUser user = await auth.linkWithTwitterCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithTwitterCredential',
            arguments: <String, String>{
              'authToken': kMockAuthToken,
              'authTokenSecret': kMockAuthTokenSecret,
            },
          ),
        ],
      );
    });

    test('signInWithFacebook', () async {
      final FirebaseUser user = await auth.signInWithFacebook(
        accessToken: kMockAccessToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithFacebook',
            arguments: <String, String>{
              'accessToken': kMockAccessToken,
            },
          ),
        ],
      );
    });

    test('linkWithEmailAndPassword', () async {
      final FirebaseUser user = await auth.linkWithEmailAndPassword(
        email: kMockEmail,
        password: kMockPassword,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithEmailAndPassword',
            arguments: <String, String>{
              'email': kMockEmail,
              'password': kMockPassword,
            },
          ),
        ],
      );
    });

    test('sendEmailVerification', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.sendEmailVerification();

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: null,
          ),
          isMethodCall(
            'sendEmailVerification',
            arguments: null,
          ),
        ],
      );
    });

    test('reload', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.reload();

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: null,
          ),
          isMethodCall(
            'reload',
            arguments: null,
          ),
        ],
      );
    });

    test('delete', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.delete();

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: null,
          ),
          isMethodCall(
            'delete',
            arguments: null,
          ),
        ],
      );
    });

    test('sendPasswordResetEmail', () async {
      await auth.sendPasswordResetEmail(
        email: kMockEmail,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'sendPasswordResetEmail',
            arguments: <String, String>{
              'email': kMockEmail,
            },
          ),
        ],
      );
    });

    test('updateEmail', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.updateEmail(kMockEmail);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: null,
        ),
        isMethodCall(
          'updateEmail',
          arguments: <String, String>{
            'email': kMockEmail,
          },
        ),
      ]);
    });

    test('updatePassword', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.updatePassword(kMockPassword);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: null,
        ),
        isMethodCall(
          'updatePassword',
          arguments: <String, String>{
            'password': kMockPassword,
          },
        ),
      ]);
    });

    test('updateProfile', () async {
      final UserUpdateInfo userUpdateInfo = UserUpdateInfo();
      userUpdateInfo.photoUrl = kMockPhotoUrl;
      userUpdateInfo.displayName = kMockDisplayName;

      final FirebaseUser user = await auth.currentUser();
      await user.updateProfile(userUpdateInfo);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: null,
        ),
        isMethodCall(
          'updateProfile',
          arguments: <String, String>{
            'photoUrl': kMockPhotoUrl,
            'displayName': kMockDisplayName,
          },
        ),
      ]);
    });

    test('signInWithCustomToken', () async {
      final FirebaseUser user =
          await auth.signInWithCustomToken(token: kMockCustomToken);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall('signInWithCustomToken', arguments: <String, String>{
            'token': kMockCustomToken,
          })
        ],
      );
    });

    test('onAuthStateChanged', () async {
      mockHandleId = 42;

      Future<Null> simulateEvent(Map<String, dynamic> user) async {
        await BinaryMessages.handlePlatformMessage(
          FirebaseAuth.channel.name,
          FirebaseAuth.channel.codec.encodeMethodCall(
            MethodCall(
              'onAuthStateChanged',
              <String, dynamic>{'id': 42, 'user': user},
            ),
          ),
          (_) {},
        );
      }

      final AsyncQueue<FirebaseUser> events = AsyncQueue<FirebaseUser>();

      // Subscribe and allow subscription to complete.
      final StreamSubscription<FirebaseUser> subscription =
          auth.onAuthStateChanged.listen(events.add);
      await Future<Null>.delayed(const Duration(seconds: 0));

      await simulateEvent(null);
      await simulateEvent(mockFirebaseUser());

      final FirebaseUser user1 = await events.remove();
      expect(user1, isNull);

      final FirebaseUser user2 = await events.remove();
      verifyUser(user2);

      // Cancel subscription and allow cancellation to complete.
      subscription.cancel();
      await Future<Null>.delayed(const Duration(seconds: 0));

      expect(
        log,
        <Matcher>[
          isMethodCall('startListeningAuthState', arguments: null),
          isMethodCall(
            'stopListeningAuthState',
            arguments: <String, dynamic>{
              'id': 42,
            },
          ),
        ],
      );
    });

    test('setLanguageCode', () async {
      await auth.setLanguageCode(kMockLanguage);

      expect(
        log,
        <Matcher>[
          isMethodCall(
            'setLanguageCode',
            arguments: <String, String>{
              'language': kMockLanguage,
            },
          ),
        ],
      );
    });
  });
}

Map<String, dynamic> mockFirebaseUser(
        {String providerId = kMockProviderId,
        String uid = kMockUid,
        String displayName = kMockDisplayName,
        String photoUrl = kMockPhotoUrl,
        String email = kMockEmail}) =>
    <String, dynamic>{
      'isAnonymous': true,
      'isEmailVerified': false,
      'providerData': <Map<String, String>>[
        <String, String>{
          'providerId': providerId,
          'uid': uid,
          'displayName': displayName,
          'photoUrl': photoUrl,
          'email': email,
        },
      ],
    };

/// Queue whose remove operation is asynchronous, awaiting a corresponding add.
class AsyncQueue<T> {
  Map<int, Completer<T>> _completers = <int, Completer<T>>{};
  int _nextToRemove = 0;
  int _nextToAdd = 0;

  void add(T element) {
    _completer(_nextToAdd++).complete(element);
  }

  Future<T> remove() {
    final Future<T> result = _completer(_nextToRemove++).future;
    return result;
  }

  Completer<T> _completer(int index) {
    if (_completers.containsKey(index)) {
      return _completers.remove(index);
    } else {
      return _completers[index] = Completer<T>();
    }
  }
}
