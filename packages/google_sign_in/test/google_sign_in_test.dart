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
    const MethodChannel channel = const MethodChannel(
      'plugins.flutter.io/google_sign_in',
    );

    const Map<String, String> kUserData = const <String, String>{
      "email": "john.doe@gmail.com",
      "id": "8162538176523816253123",
      "photoUrl": "https://lh5.googleusercontent.com/photo.jpg",
      "displayName": "John Doe",
    };

    const Map<String, dynamic> kDefaultResponses = const <String, dynamic>{
      'init': null,
      'signInSilently': kUserData,
      'signIn': kUserData,
      'signOut': null,
      'disconnect': null,
    };

    final List<MethodCall> log = <MethodCall>[];
    Map<String, dynamic> responses;
    GoogleSignIn googleSignIn;

    setUp(() {
      responses = new Map<String, dynamic>.from(kDefaultResponses);
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return new Future<dynamic>.value(responses[methodCall.method]);
      });
      googleSignIn = new GoogleSignIn();
      log.clear();
    });

    test('signInSilently', () async {
      await googleSignIn.signInSilently();
      expect(googleSignIn.currentUser, isNotNull);
      expect(
        log,
        <Matcher>[
          isMethodCall('init', arguments: <String, dynamic>{
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
            'scopes': <String>[],
            'hostedDomain': null,
          }),
          isMethodCall('disconnect', arguments: null),
        ],
      );
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

    test('signInSilently does not throw on error', () async {
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        throw "I am an error";
      });
      expect(await googleSignIn.signInSilently(), isNull); // should not throw
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
        return new Future<dynamic>.value(responses[methodCall.method]);
      });
      expect(googleSignIn.signIn(),
          throwsA(const isInstanceOf<PlatformException>()));
      expect(await googleSignIn.signIn(), isNotNull);
    });
  });

  group('GoogleSignIn with fake backend', () {
    const FakeUser kUserData = const FakeUser(
      id: "8162538176523816253123",
      displayName: "John Doe",
      email: "john.doe@gmail.com",
      photoUrl: "https://lh5.googleusercontent.com/photo.jpg",
    );

    GoogleSignIn googleSignIn;

    setUp(() {
      GoogleSignIn.channel.setMockMethodCallHandler(
          (new FakeSignInBackend()..user = kUserData).handleMethodCall);
      googleSignIn = new GoogleSignIn();
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
