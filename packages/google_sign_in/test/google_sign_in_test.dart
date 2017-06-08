// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:test/test.dart';

void main() {
  group('$GoogleSignIn', () {
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
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signInSilently'),
          ]));
    });

    test('signIn', () async {
      await googleSignIn.signIn();
      expect(googleSignIn.currentUser, isNotNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signIn'),
          ]));
    });

    test('signOut', () async {
      await googleSignIn.signOut();
      expect(googleSignIn.currentUser, isNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signOut'),
          ]));
    });

    test('disconnect; null response', () async {
      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('disconnect'),
          ]));
    });

    test('disconnect; empty response as on iOS', () async {
      responses['disconnect'] = <String, dynamic>{};
      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('disconnect'),
          ]));
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
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signInSilently'),
          ]));
    });

    test('can sign in after previously failed attempt', () async {
      responses['signInSilently'] = <String, dynamic>{'error': 'Not a user'};
      expect(googleSignIn.signInSilently(),
          throwsA(const isInstanceOf<AssertionError>()));
      expect(await googleSignIn.signIn(), isNotNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signInSilently'),
            const MethodCall('signIn'),
          ]));
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
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signInSilently'),
          ]));
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
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signOut'),
            const MethodCall('signOut'),
            const MethodCall('disconnect'),
            const MethodCall('disconnect'),
          ]));
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
          equals(<MethodCall>[
            new MethodCall('init',
                <String, dynamic>{'scopes': <String>[], 'hostedDomain': null}),
            const MethodCall('signInSilently'),
            const MethodCall('signOut'),
            const MethodCall('signIn'),
            const MethodCall('disconnect'),
          ]));
    });
  });
}
