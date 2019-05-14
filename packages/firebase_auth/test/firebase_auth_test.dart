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
          case "isSignInWithEmailLink":
            return true;
          case "startListeningAuthState":
            return mockHandleId++;
            break;
          case "sendLinkToEmail":
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

    test('sendSignInWithEmailLink', () async {
      await auth.sendSignInWithEmailLink(
        email: 'test@example.com',
        url: 'http://www.example.com/',
        handleCodeInApp: true,
        iOSBundleID: 'com.example.app',
        androidPackageName: 'com.example.app',
        androidInstallIfNotAvailable: false,
        androidMinimumVersion: "12",
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('sendLinkToEmail', arguments: <String, dynamic>{
            'email': 'test@example.com',
            'url': 'http://www.example.com/',
            'handleCodeInApp': true,
            'iOSBundleID': 'com.example.app',
            'androidPackageName': 'com.example.app',
            'androidInstallIfNotAvailable': false,
            'androidMinimumVersion': '12',
            'app': auth.app.name,
          }),
        ],
      );
    });

    test('isSignInWithEmailLink', () async {
      final bool result = await auth.isSignInWithEmailLink('foo');
      expect(result, true);
      expect(
        log,
        <Matcher>[
          isMethodCall('isSignInWithEmailLink',
              arguments: <String, String>{'link': 'foo', 'app': auth.app.name}),
        ],
      );
    });

    test('signInWithEmailAndLink', () async {
      await auth.signInWithEmailAndLink(
        email: 'test@example.com',
        link: '<Url with domain from your Firebase project>',
      );
      expect(
        log,
        <Matcher>[
          isMethodCall('signInWithEmailAndLink', arguments: <String, dynamic>{
            'email': 'test@example.com',
            'link': '<Url with domain from your Firebase project>',
            'app': auth.app.name,
          }),
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
          ),
        ],
      );
    });

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
                'email': kMockEmail,
                'password': kMockPassword,
              },
            },
          ),
        ],
      );
    });

    test('GoogleAuthProvider signInWithCredential', () async {
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
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
              'provider': 'google.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('PhoneAuthProvider signInWithCredential', () async {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: kMockVerificationId,
        smsCode: kMockSmsCode,
      );
      await auth.signInWithCredential(credential);
      expect(log, <Matcher>[
        isMethodCall('signInWithCredential', arguments: <String, dynamic>{
          'app': auth.app.name,
          'provider': 'phone',
          'data': <String, String>{
            'verificationId': kMockVerificationId,
            'smsCode': kMockSmsCode,
          },
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

    test('EmailAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      log.clear();
      final AuthCredential credential = EmailAuthProvider.getCredential(
        email: kMockEmail,
        password: kMockPassword,
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
                'email': kMockEmail,
                'password': kMockPassword,
              }
            },
          ),
        ],
      );
    });
    test('GoogleAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      log.clear();
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
      );
      await user.reauthenticateWithCredential(credential);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'google.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('FacebookAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      log.clear();
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: kMockAccessToken,
      );
      await user.reauthenticateWithCredential(credential);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
            arguments: <String, dynamic>{
              'app': auth.app.name,
              'provider': 'facebook.com',
              'data': <String, String>{
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('TwitterAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      log.clear();
      final AuthCredential credential = TwitterAuthProvider.getCredential(
        authToken: kMockAuthToken,
        authTokenSecret: kMockAuthTokenSecret,
      );
      await user.reauthenticateWithCredential(credential);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
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

    test('GithubAuthProvider reauthenticateWithCredential', () async {
      final FirebaseUser user = await auth.currentUser();
      log.clear();
      final AuthCredential credential = GithubAuthProvider.getCredential(
        token: kMockGithubToken,
      );
      await user.reauthenticateWithCredential(credential);
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'reauthenticateWithCredential',
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

    test('GoogleAuthProvider linkWithCredential', () async {
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: kMockIdToken,
        accessToken: kMockAccessToken,
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
              'provider': 'google.com',
              'data': <String, String>{
                'idToken': kMockIdToken,
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('FacebookAuthProvider linkWithCredential', () async {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: kMockAccessToken,
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
              'provider': 'facebook.com',
              'data': <String, String>{
                'accessToken': kMockAccessToken,
              },
            },
          ),
        ],
      );
    });

    test('FacebookAuthProvider signInWithCredential', () async {
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: kMockAccessToken,
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
                'email': kMockEmail,
                'password': kMockPassword,
              },
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

    test('EmailAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(EmailAuthProvider.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'password',
          },
        ),
      ]);
    });

    test('GoogleAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(GoogleAuthProvider.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'google.com',
          },
        ),
      ]);
    });

    test('FacebookAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(FacebookAuthProvider.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'facebook.com',
          },
        ),
      ]);
    });

    test('PhoneAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(PhoneAuthProvider.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'phone',
          },
        ),
      ]);
    });

    test('TwitterAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(TwitterAuthProvider.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkFromProvider',
          arguments: <String, String>{
            'app': auth.app.name,
            'provider': 'twitter.com',
          },
        ),
      ]);
    });

    test('GithubAuthProvider unlinkFromProvider', () async {
      final FirebaseUser user = await auth.currentUser();
      await user.unlinkFromProvider(GithubAuthProvider.providerId);
      expect(log, <Matcher>[
        isMethodCall(
          'currentUser',
          arguments: <String, String>{'app': auth.app.name},
        ),
        isMethodCall(
          'unlinkFromProvider',
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
