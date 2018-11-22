// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
const String kMockGithubToken = 'github';
const String kMockAuthToken = '23456';
const String kMockAuthTokenSecret = '78901';
const String kMockCustomToken = '12345';
const String kMockPhoneNumber = '5555555555';
const String kMockVerificationId = '12345';
const String kMockSmsCode = '123456';
const String kMockLanguage = 'en';

void main() {
  group('$FirebaseAuth', () {
    final String appName = 'testApp';
    final FirebaseApp app = FirebaseApp(name: appName);
    final FirebaseAuth auth = FirebaseAuth.fromApp(app);
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
          case "fetchSignInMethodsForEmail":
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
          isMethodCall('currentUser',
              arguments: <String, String>{'app': auth.app.name}),
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
          isMethodCall('signInAnonymously',
              arguments: <String, String>{'app': auth.app.name}),
          isMethodCall(
            'getIdToken',
            arguments: <String, dynamic>{
              'refresh': false,
              'app': auth.app.name
            },
          ),
          isMethodCall(
            'getIdToken',
            arguments: <String, dynamic>{'refresh': true, 'app': auth.app.name},
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
              'app': auth.app.name,
            },
          ),
        ],
      );
    });

    test('fetchSignInMethodsForEmail', () async {
      final List<String> providers =
          await auth.fetchSignInMethodsForEmail(email: kMockEmail);
      expect(providers, isNotNull);
      expect(providers.length, 0);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'fetchSignInMethodsForEmail',
            arguments: <String, String>{
              'email': kMockEmail,
              'app': auth.app.name
            },
          ),
        ],
      );
    });

    test('linkWithTwitterCredential', () async {
      final FirebaseUser user = await auth.linkWithTwitterCredential(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithTwitterCredential',
            arguments: <String, String>{
              'authToken': kMockIdToken,
              'authTokenSecret': kMockAccessToken,
              'app': auth.app.name,
            },
          ),
        ],
      );
    });

    test('signInWithTwitter', () async {
      final FirebaseUser user = await auth.signInWithTwitter(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithTwitter',
            arguments: <String, String>{
              'authToken': kMockIdToken,
              'authTokenSecret': kMockAccessToken,
              'app': auth.app.name,
            },
          ),
        ],
      );
    });

    test('linkWithGithubCredential', () async {
      final FirebaseUser user = await auth.linkWithGithubCredential(
        token: kMockGithubToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithGithubCredential',
            arguments: <String, String>{
              'token': kMockGithubToken,
              'app': auth.app.name,
            },
          ),
        ],
      );
    });

    test('signInWithGithub', () async {
      final FirebaseUser user = await auth.signInWithGithub(
        token: kMockGithubToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithGithub',
            arguments: <String, String>{
              'token': kMockGithubToken,
              'app': auth.app.name,
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
              'app': auth.app.name
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
              'app': auth.app.name
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
          'app': auth.app.name,
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
          'app': auth.app.name,
        })
      ]);
    });

    test('reauthenticateWithEmailAndPassword', () async {
      await auth.reauthenticateWithEmailAndPassword(
        email: kMockEmail,
        password: kMockPassword,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithEmailAndPassword',
            arguments: <String, String>{
              'email': kMockEmail,
              'password': kMockPassword,
              'app': auth.app.name,
            },
          ),
        ],
      );
    });
    test('reauthenticateWithGoogleCredential', () async {
      await auth.reauthenticateWithGoogleCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithGoogleCredential',
            arguments: <String, String>{
              'idToken': kMockIdToken,
              'accessToken': kMockAccessToken,
              'app': auth.app.name,
            },
          ),
        ],
      );
    });

    test('reauthenticateWithFacebookCredential', () async {
      await auth.reauthenticateWithFacebookCredential(
        accessToken: kMockAccessToken,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithFacebookCredential',
            arguments: <String, String>{
              'accessToken': kMockAccessToken,
              'app': auth.app.name,
            },
          ),
        ],
      );
    });

    test('reauthenticateWithTwitterCredential', () async {
      await auth.reauthenticateWithTwitterCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithTwitterCredential',
            arguments: <String, String>{
              'authToken': kMockAuthToken,
              'authTokenSecret': kMockAuthTokenSecret,
              'app': auth.app.name,
            },
          ),
        ],
      );
    });

    test('reauthenticateWithGithubCredential', () async {
      await auth.reauthenticateWithGithubCredential(
        token: kMockGithubToken,
      );
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithGithubCredential',
            arguments: <String, String>{
              'app': auth.app.name,
              'token': kMockGithubToken,
            },
          ),
        ],
      );
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
              'app': auth.app.name,
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
              'app': auth.app.name,
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
              'app': auth.app.name,
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
              'app': auth.app.name,
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
              'app': auth.app.name,
              'authToken': kMockAuthToken,
              'authTokenSecret': kMockAuthTokenSecret,
            },
          ),
        ],
      );
    });

    test('signInWithTwitter', () async {
      final FirebaseUser user = await auth.signInWithTwitter(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithTwitter',
            arguments: <String, String>{
              'app': auth.app.name,
              'authToken': kMockAuthToken,
              'authTokenSecret': kMockAuthTokenSecret,
            },
          ),
        ],
      );
    });

    test('linkWithGithubCredential', () async {
      final FirebaseUser user = await auth.linkWithGithubCredential(
        token: kMockGithubToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'linkWithGithubCredential',
            arguments: <String, String>{
              'app': auth.app.name,
              'token': kMockGithubToken,
            },
          ),
        ],
      );
    });

    test('signInWithGithub', () async {
      final FirebaseUser user = await auth.signInWithGithub(
        token: kMockGithubToken,
      );
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithGithub',
            arguments: <String, String>{
              'app': auth.app.name,
              'token': kMockGithubToken,
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
              'app': auth.app.name,
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
            arguments: <String, String>{'app': auth.app.name},
          ),
          isMethodCall(
            'sendEmailVerification',
            arguments: <String, String>{'app': auth.app.name},
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
            arguments: <String, String>{'app': auth.app.name},
          ),
          isMethodCall(
            'reload',
            arguments: <String, String>{'app': auth.app.name},
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
            arguments: <String, String>{'app': auth.app.name},
          ),
          isMethodCall(
            'delete',
            arguments: <String, String>{'app': auth.app.name},
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
              'app': auth.app.name
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
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'updateEmail',
          arguments: <String, String>{
            'email': kMockEmail,
            'app': auth.app.name,
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
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'updatePassword',
          arguments: <String, String>{
            'password': kMockPassword,
            'app': auth.app.name,
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
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'updateProfile',
          arguments: <String, String>{
            'photoUrl': kMockPhotoUrl,
            'displayName': kMockDisplayName,
            'app': auth.app.name,
          },
        ),
      ]);
    });

    test('unlinkEmailAndPassword', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkEmailAndPassword();
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkCredential',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'password',
          },
        ),
      ]);
    });

    test('unlinkGoogleCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkGoogleCredential();
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkCredential',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'google.com',
          },
        ),
      ]);
    });

    test('unlinkFacebookCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFacebookCredential();
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkCredential',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'facebook.com',
          },
        ),
      ]);
    });

    test('unlinkTwitterCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkTwitterCredential();
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkCredential',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'twitter.com',
          },
        ),
      ]);
    });

    test('unlinkGithubCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkGithubCredential();
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkCredential',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'github.com',
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
            'app': auth.app.name,
          })
        ],
      );
    });

    test('onAuthStateChanged', () async {
      mockHandleId = 42;

      Future<void> simulateEvent(Map<String, dynamic> user) async {
        await BinaryMessages.handlePlatformMessage(
          FirebaseAuth.channel.name,
          FirebaseAuth.channel.codec.encodeMethodCall(
            MethodCall(
              'onAuthStateChanged',
              <String, dynamic>{'id': 42, 'user': user, 'app': auth.app.name},
            ),
          ),
          (_) {},
        );
      }

      final AsyncQueue<FirebaseUser> events = AsyncQueue<FirebaseUser>();

      // Subscribe and allow subscription to complete.
      final StreamSubscription<FirebaseUser> subscription =
          auth.onAuthStateChanged.listen(events.add);
      await Future<void>.delayed(const Duration(seconds: 0));

      await simulateEvent(null);
      await simulateEvent(mockFirebaseUser());

      final FirebaseUser user1 = await events.remove();
      expect(user1, isNull);

      final FirebaseUser user2 = await events.remove();
      verifyUser(user2);

      // Cancel subscription and allow cancellation to complete.
      subscription.cancel();
      await Future<void>.delayed(const Duration(seconds: 0));

      expect(
        log,
        <Matcher>[
          isMethodCall('startListeningAuthState', arguments: <String, String>{
            'app': auth.app.name,
          }),
          isMethodCall(
            'stopListeningAuthState',
            arguments: <String, dynamic>{
              'id': 42,
              'app': auth.app.name,
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
              'app': auth.app.name,
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
