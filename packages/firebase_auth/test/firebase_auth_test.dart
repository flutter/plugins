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
<<<<<<< HEAD
=======
          case "updateEmail":
          case "updatePhoneNumberCredential":
          case "updatePassword":
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
          case "updateProfile":
            return null;
            break;
          case "updateEmail":
            return null;
            break;
          case "fetchProvidersForEmail":
            return new List<String>(0);
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
<<<<<<< HEAD
            'fetchProvidersForEmail',
            arguments: <String, String>{'email': kMockEmail},
=======
            'fetchSignInMethodsForEmail',
            arguments: <String, String>{
              'email': kMockEmail,
              'app': auth.app.name
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider (withLink) linkWithCredential', () async {
      final AuthCredential credential = EmailAuthProvider.getCredentialWithLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'password',
              'data': <String, String>{
                'email': 'test@example.com',
                'link': '<Url with domain from your Firebase project>',
              },
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider (withLink) signInWithCredential', () async {
      final AuthCredential credential = EmailAuthProvider.getCredentialWithLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      final FirebaseUser user = await auth.signInWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'password',
              'data': <String, String>{
                'email': 'test@example.com',
                'link': '<Url with domain from your Firebase project>',
              },
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider (withLink) reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      log.clear();
      final AuthCredential credential = EmailAuthProvider.getCredentialWithLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      await user.reauthenticateWithCredential(credential);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'password',
              'data': <String, String>{
                'email': 'test@example.com',
                'link': '<Url with domain from your Firebase project>',
              }
            },
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
          ),
        ],
      );
    });

<<<<<<< HEAD
    test('linkWithEmailAndPassword', () async {
      final FirebaseUser user = await auth.linkWithEmailAndPassword(
        email: kMockEmail,
        password: kMockPassword,
      );
=======
    test('TwitterAuthProvider linkWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockIdToken,
                'authTokenSecret': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider signInWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockIdToken,
        authTokenSecret: kMockAccessToken,
      );
      final FirebaseUser user = await auth.signInWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockIdToken,
                'authTokenSecret': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('GithubAuthProvider linkWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              }
            },
          ),
        ],
      );
    });

    test('GitHubAuthProvider signInWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      final FirebaseUser user = await auth.signInWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              },
            },
          ),
        ],
      );
    });

    test('EmailAuthProvider linkWithCredential', () async {
      final AuthCredential credential = EmailAuthProvider.getCredential(
        email: kMockEmail,
        password: kMockPassword,
      );
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
<<<<<<< HEAD
            'linkWithEmailAndPassword',
            arguments: <String, String>{
              'email': kMockEmail,
              'password': kMockPassword,
=======
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'password',
              'data': <String, String>{
                'email': kMockEmail,
                'password': kMockPassword,
              },
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
<<<<<<< HEAD
=======
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
<<<<<<< HEAD
            'linkWithGoogleCredential',
            arguments: <String, String>{
              'idToken': kMockIdToken,
              'accessToken': kMockAccessToken,
=======
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'google.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
              },
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
            },
          ),
        ],
      );
    });

    test('linkWithFacebookCredential', () async {
      final FirebaseUser user = await auth.linkWithFacebookCredential(
        accessToken: kMockAccessToken,
      );
<<<<<<< HEAD
=======
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
<<<<<<< HEAD
            'linkWithFacebookCredential',
            arguments: <String, String>{
              'accessToken': kMockAccessToken,
=======
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'facebook.com',
              'data': <String, String>{
                'accessToken': kMockAccessToken,
              },
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
            },
          ),
        ],
      );
    });

    test('signInWithFacebook', () async {
      final FirebaseUser user = await auth.signInWithFacebook(
        accessToken: kMockAccessToken,
      );
<<<<<<< HEAD
=======
      final FirebaseUser user = await auth.signInWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'facebook.com',
              'data': <String, String>{
                'accessToken': kMockAccessToken,
              }
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider linkWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockAuthToken,
                'authTokenSecret': kMockAuthTokenSecret,
              },
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider signInWithCredential', () async {
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      final FirebaseUser user = await auth.signInWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'signInWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'twitter.com',
              'data': <String, String>{
                'authToken': kMockAuthToken,
                'authTokenSecret': kMockAuthTokenSecret,
              },
            },
          ),
        ],
      );
    });

    test('GithubAuthProvider linkWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'github.com',
              'data': <String, String>{
                'token': kMockGithubToken,
              },
            },
          ),
        ],
      );
    });

    test('GithubAuthProvider signInWithCredential', () async {
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      final FirebaseUser user = await auth.signInWithCredential(credential);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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
<<<<<<< HEAD
=======
      FirebaseUser user = await auth.currentUser();
      user = await user.linkWithCredential(credential);
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
      verifyUser(user);
      expect(
        log,
        <Matcher>[
          isMethodCall(
<<<<<<< HEAD
            'linkWithEmailAndPassword',
            arguments: <String, String>{
              'email': kMockEmail,
              'password': kMockPassword,
=======
            'currentUser',
            arguments: <String, dynamic>{
              'app': auth.app.name,
            },
          ),
          isMethodCall(
            'linkWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'password',
              'data': <String, String>{
                'email': kMockEmail,
                'password': kMockPassword,
              },
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
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

<<<<<<< HEAD
=======
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

    test('updatePhoneNumberCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      final AuthCredential credentials = PhoneAuthProvider.getCredential(
        verificationId: kMockVerificationId,
        smsCode: kMockSmsCode,
      );
      await user.updatePhoneNumberCredential(credentials);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'updatePhoneNumberCredential',
          arguments: <String, dynamic>{
            'app': auth.app.name,
            'provider': 'phone',
            'data': <String, String>{
              'verificationId': kMockVerificationId,
              'smsCode': kMockSmsCode,
            },
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

>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
    test('updateProfile', () async {
      final UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.photoUrl = kMockPhotoUrl;
      userUpdateInfo.displayName = kMockDisplayName;

      await auth.updateProfile(userUpdateInfo);
      expect(log, <Matcher>[
        isMethodCall(
          'updateProfile',
          arguments: <String, String>{
            'photoUrl': kMockPhotoUrl,
            'displayName': kMockDisplayName,
          },
        ),
      ]);
    });

    test('updateEmail', () async {
      final String updatedEmail = 'atestemail@gmail.com';
      auth.updateEmail(email: updatedEmail);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'updateEmail',
            arguments: <String, String>{'email': updatedEmail},
          ),
        ],
      );
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

<<<<<<< HEAD
      Future<Null> simulateEvent(Map<String, dynamic> user) async {
=======
      Future<void> simulateEvent(Map<String, dynamic> user) async {
        // TODO(hterkelsen): Remove this when defaultBinaryMessages is in stable.
        // https://github.com/flutter/flutter/issues/33446
        // ignore: deprecated_member_use
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
        await BinaryMessages.handlePlatformMessage(
          FirebaseAuth.channel.name,
          FirebaseAuth.channel.codec.encodeMethodCall(
            new MethodCall(
              'onAuthStateChanged',
              <String, dynamic>{'id': 42, 'user': user},
            ),
          ),
          (_) {},
        );
      }

      final AsyncQueue<FirebaseUser> events = new AsyncQueue<FirebaseUser>();

      // Subscribe and allow subscription to complete.
      final StreamSubscription<FirebaseUser> subscription =
          auth.onAuthStateChanged.listen(events.add);
      await new Future<Null>.delayed(const Duration(seconds: 0));

      await simulateEvent(null);
      await simulateEvent(mockFirebaseUser());

      final FirebaseUser user1 = await events.remove();
      expect(user1, isNull);

      final FirebaseUser user2 = await events.remove();
      verifyUser(user2);

      // Cancel subscription and allow cancellation to complete.
      subscription.cancel();
      await new Future<Null>.delayed(const Duration(seconds: 0));

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
      return _completers[index] = new Completer<T>();
    }
  }
}
