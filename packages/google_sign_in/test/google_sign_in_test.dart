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

    const Map kUserData = const {
      "email": "john.doe@gmail.com",
      "id": "8162538176523816253123",
      "photoUrl": "https://lh5.googleusercontent.com/photo.jpg",
      "displayName": "John Doe",
    };

    const Map kDefaultResponses = const {
      'init': null,
      'signInSilently': kUserData,
      'signIn': kUserData,
      'signOut': null,
      'disconnect': null,
    };

    final List<MethodCall> log = <MethodCall>[];
    Map responses;
    GoogleSignIn googleSignIn;

    setUp(() {
      responses = new Map.from(kDefaultResponses);
      channel.setMockMethodCallHandler((MethodCall methodCall) {
        log.add(methodCall);
        return new Future.value(responses[methodCall.method]);
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
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('signInSilently'),
          ]));
    });

    test('signIn', () async {
      await googleSignIn.signIn();
      expect(googleSignIn.currentUser, isNotNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('signIn'),
          ]));
    });

    test('signOut', () async {
      await googleSignIn.signOut();
      expect(googleSignIn.currentUser, isNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('signOut'),
          ]));
    });

    test('disconnect; null response', () async {
      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('disconnect'),
          ]));
    });

    test('disconnect; empty response as on iOS', () async {
      responses['disconnect'] = {};
      await googleSignIn.disconnect();
      expect(googleSignIn.currentUser, isNull);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('disconnect'),
          ]));
    });

    test('concurrent calls of the same method', () async {
      var futures = [
        googleSignIn.signInSilently(),
        googleSignIn.signInSilently(),
      ];
      expect(futures.first, same(futures.last),
          reason: 'Must return the same Future');
      var users = await Future.wait(futures);
      expect(googleSignIn.currentUser, isNotNull);
      expect(users, [googleSignIn.currentUser, googleSignIn.currentUser]);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('signInSilently'),
          ]));

      log.clear();
      var freshUser = await googleSignIn.signInSilently();
      expect(freshUser, users.first, reason: 'Must return the same user');
      expect(log, isEmpty);
    });

    test('concurrent calls after error succeed', () async {
      responses['signInSilently'] = {'error': 'Not a user'};
      expect(googleSignIn.signInSilently(),
          throwsA(new isInstanceOf<AssertionError>()));
      expect(googleSignIn.signIn(), completion(isNotNull));
    });

    test('concurrent calls of different signIn methods', () async {
      var futures = [
        googleSignIn.signInSilently(),
        googleSignIn.signIn(),
      ];
      expect(futures.first, isNot(futures.last));
      var users = await Future.wait(futures);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('signInSilently'),
          ]));
      expect(users.first, users.last, reason: 'Must return the same user');
      expect(googleSignIn.currentUser, users.last);
    });

    test('queue of many concurrent calls', () async {
      var futures = [
        googleSignIn.signInSilently(),
        googleSignIn.signOut(),
        googleSignIn.signIn(),
        googleSignIn.disconnect(),
      ];
      await Future.wait(futures);
      expect(
          log,
          equals(<MethodCall>[
            new MethodCall('init', {'scopes': [], 'hostedDomain': null}),
            new MethodCall('signInSilently'),
            new MethodCall('signOut'),
            new MethodCall('signIn'),
            new MethodCall('disconnect'),
          ]));
    });
  });
}
