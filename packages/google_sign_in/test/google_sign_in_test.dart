// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in/testing.dart';

void main() {
  group('GoogleSignIn', () {
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/google_sign_in',
    );

    const Map<String, String> kUserData = <String, String>{
      "email": "john.doe@gmail.com",
      "id": "8162538176523816253123",
      "photoUrl": "https://lh5.googleusercontent.com/photo.jpg",
      "displayName": "John Doe",
    };

    const Map<String, dynamic> kDefaultResponses = <String, dynamic>{
      'init': null,
      'signInSilently': kUserData,
      'signIn': kUserData,
      'signOut': null,
      'disconnect': null,
      'isSignedIn': true,
      'getTokens': <dynamic, dynamic>{
        'idToken': '123',
        'accessToken': '456',
      },
    };

    final List<MethodCall> log = <MethodCall>[];
    Map<String, dynamic> responses;
    GoogleSignIn googleSignIn;

    setUp(() {
      responses = Map<String, dynamic>.from(kDefaultResponses);
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return Future<dynamic>.value(responses[methodCall.method]);
      });
      googleSignIn = GoogleSignIn();
      log.clear();
    });

    test('signInSilently', () async {
      await googleSignIn.signInSilently();
      expect(googleSignIn.currentUser, isNotNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signInSilently', arguments: null),
        ],
      );
    });

    test('signIn', () async {
      await googleSignIn.signIn();
      expect(googleSignIn.currentUser, isNotNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signIn', arguments: null),
        ],
      );
    });

    test('signOut', () async {
      await googleSignIn.signOut();
      expect(googleSignIn.currentUser, isNull);
      expect(log, <Matcher>[
        isMethodCall('init', arguments: <String, dynamic>{
          'signInOption': 'SignInOption.standard',
          'scopes': <String>[],
          'hostedDomain': null,
        }),
        isMethodCall('signOut', arguments: null),
      ]);
    });

    test('disconnect; null response', () async {
      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('disconnect', arguments: null),
        ],
      );
    });

    test('disconnect; empty response as on iOS', () async {
      responses['disconnect'] = <String, dynamic>{};
      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('disconnect', arguments: null),
        ],
      );
    });

    test('isSignedIn', () async {
      final bool result = await googleSignIn.isSignedIn();
      expect(result, isTrue);
      expect(log, <Matcher>[
        isMethodCall('init', arguments: <String, dynamic>{
          'signInOption': 'SignInOption.standard',
          'scopes': <String>[],
          'hostedDomain': null,
        }),
        isMethodCall('isSignedIn', arguments: null),
      ]);
    });

    test('concurrent calls of the same method trigger sign in once', () async {
      final List<Future<GoogleSignInAccount>> futures =
          <Future<GoogleSignInAccount>>[
        googleSignIn.signInSilently(),
        googleSignIn.signInSilently(),
      ];
      expect(futures.first, isNot(futures.last),
          reason: 'Must return new Future');
      final List<GoogleSignInAccount> users = await Future.wait(futures);
      expect(googleSignIn.currentUser, isNotNull);
      expect(users, <GoogleSignInAccount>[
        googleSignIn.currentUser,
        googleSignIn.currentUser
      ]);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signInSilently', arguments: null),
        ],
      );
    });

    test('can sign in after previously failed attempt', () async {
      responses['signInSilently'] = <String, dynamic>{'error': 'Not a user'};
      expect(await googleSignIn.signInSilently(), isNull);
      expect(await googleSignIn.signIn(), isNotNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signInSilently', arguments: null),
          isMethodCall('signIn', arguments: null),
        ],
      );
    });

    test('concurrent calls of different signIn methods', () async {
      final List<Future<GoogleSignInAccount>> futures =
          <Future<GoogleSignInAccount>>[
        googleSignIn.signInSilently(),
        googleSignIn.signIn(),
      ];
      expect(futures.first, isNot(futures.last));
      final List<GoogleSignInAccount> users = await Future.wait(futures);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signInSilently', arguments: null),
        ],
      );
      expect(users.first, users.last, reason: 'Must return the same user');
      expect(googleSignIn.currentUser, users.last);
    });

    test('can sign in after aborted flow', () async {
      responses['signIn'] = null;
      expect(await googleSignIn.signIn(), isNull);
      responses['signIn'] = kUserData;
      expect(await googleSignIn.signIn(), isNotNull);
    });

    test('signOut/disconnect methods always trigger native calls', () async {
      final List<Future<GoogleSignInAccount>> futures =
          <Future<GoogleSignInAccount>>[
        googleSignIn.signOut(),
        googleSignIn.signOut(),
        googleSignIn.disconnect(),
        googleSignIn.disconnect(),
      ];
      await Future.wait(futures);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signOut', arguments: null),
          isMethodCall('signOut', arguments: null),
          isMethodCall('disconnect', arguments: null),
          isMethodCall('disconnect', arguments: null),
        ],
      );
    });

    test('queue of many concurrent calls', () async {
      final List<Future<GoogleSignInAccount>> futures =
          <Future<GoogleSignInAccount>>[
        googleSignIn.signInSilently(),
        googleSignIn.signOut(),
        googleSignIn.signIn(),
        googleSignIn.disconnect(),
      ];
      await Future.wait(futures);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signInSilently', arguments: null),
          isMethodCall('signOut', arguments: null),
          isMethodCall('signIn', arguments: null),
          isMethodCall('disconnect', arguments: null),
        ],
      );
    });

    test('signInSilently suppresses errors by default', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        throw "I am an error";
      });
      expect(await googleSignIn.signInSilently(), isNull); // should not throw
    });

    test('signInSilently forwards errors', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        throw "I am an error";
      });
      expect(googleSignIn.signInSilently(suppressErrors: false),
          throwsA(isInstanceOf<PlatformException>()));
    });

    test('can sign in after init failed before', () async {
      int initCount = 0;
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        if (methodCall.method == 'init') {
          initCount++;
          if (initCount == 1) {
            throw "First init fails";
          }
        }
        return Future<dynamic>.value(responses[methodCall.method]);
      });
      expect(googleSignIn.signIn(), throwsA(isInstanceOf<PlatformException>()));
      expect(await googleSignIn.signIn(), isNotNull);
    });

    test('created with standard factory uses correct options', () async {
      googleSignIn = GoogleSignIn.standard();

      await googleSignIn.signInSilently();
      expect(googleSignIn.currentUser, isNotNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.standard',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signInSilently', arguments: null),
        ],
      );
    });

    test('created with defaultGamesSignIn factory uses correct options',
        () async {
      googleSignIn = GoogleSignIn.games();

      await googleSignIn.signInSilently();
      expect(googleSignIn.currentUser, isNotNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
            'signInOption': 'SignInOption.games',
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('signInSilently', arguments: null),
        ],
      );
    });

    test('authentication', () async {
      await googleSignIn.signIn();
      log.clear();

      final GoogleSignInAccount user = googleSignIn.currentUser;
      final GoogleSignInAuthentication auth = await user.authentication;

      expect(auth.accessToken, '456');
      expect(auth.idToken, '123');
      expect(
        log,
        <Matcher>[
          isMethodCall('getTokens', arguments: <String, dynamic>{
            'email': 'john.doe@gmail.com',
            'shouldRecoverAuth': true,
          }),
        ],
      );
    });
  });

  group('GoogleSignIn with fake backend', () {
    const FakeUser kUserData = FakeUser(
      id: "8162538176523816253123",
      displayName: "John Doe",
      email: "john.doe@gmail.com",
      photoUrl: "https://lh5.googleusercontent.com/photo.jpg",
    );

    GoogleSignIn googleSignIn;

    setUp(() {
      GoogleSignIn.channel.setMockMethodCallHandler(
          (FakeSignInBackend()..user = kUserData).handleMethodCall);
      googleSignIn = GoogleSignIn();
    });

    test('user starts as null', () async {
      expect(googleSignIn.currentUser, isNull);
    });

    test('can sign in and sign out', () async {
      await googleSignIn.signIn();

      final GoogleSignInAccount user = googleSignIn.currentUser;

      expect(user.displayName, equals(kUserData.displayName));
      expect(user.email, equals(kUserData.email));
      expect(user.id, equals(kUserData.id));
      expect(user.photoUrl, equals(kUserData.photoUrl));

      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
    });

    test('disconnect when signout already succeeds', () async {
      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
    });
  });
}
