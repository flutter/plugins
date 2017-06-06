// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  Map userData = {
    "email": "john.doe@gmail.com",
    "id": "8162538176523816253123",
    "photoUrl": "https://lh5.googleusercontent.com/photo.jpg",
    "displayName": "John Doe",
  };
  Map defaultResponses = {
    'init': null,
    'signInSilently': userData,
    'signIn': userData,
    'signOut': null,
    'disconnect': null,
  };

  group('$GoogleSignIn', () {
    GoogleSignIn googleSignIn;
    List<String> invokedMethods;
    Map responses;

    setUp(() {
      responses = new Map.from(defaultResponses);
      MockPlatformChannel mockChannel = new MockPlatformChannel();

      invokedMethods = <String>[];

      dynamic answer(Invocation invocation) {
        final method = invocation.positionalArguments[0];
        invokedMethods.add(method);
        final response = responses[method];
        return new Future.value(response);
      }

      when(mockChannel.invokeMethod(typed(any), typed(any))).thenAnswer(answer);
      when(mockChannel.invokeMethod(typed(any))).thenAnswer(answer);

      googleSignIn = new GoogleSignIn.private(channel: mockChannel);
    });

    test('signInSilently', () async {
      await googleSignIn.signInSilently();
      expect(invokedMethods, ['init', 'signInSilently']);
      expect(googleSignIn.currentUser, isNotNull);
    });

    test('signIn', () async {
      await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'signIn']);
      expect(googleSignIn.currentUser, isNotNull);
    });

    test('signOut', () async {
      await googleSignIn.signOut();
      expect(invokedMethods, ['init', 'signOut']);
      expect(googleSignIn.currentUser, isNull);
    });

    test('disconnect; null response', () async {
      await googleSignIn.disconnect();
      expect(invokedMethods, ['init', 'disconnect']);
      expect(googleSignIn.currentUser, isNull);
    });

    test('disconnect; empty response as on iOS', () async {
      responses['disconnect'] = {};
      await googleSignIn.disconnect();
      expect(invokedMethods, ['init', 'disconnect']);
      expect(googleSignIn.currentUser, isNull);
    });

    test('concurrent calls of the same method', () async {
      var futures = [
        googleSignIn.signInSilently(),
        googleSignIn.signInSilently(),
      ];
      expect(futures.first, same(futures.last),
          reason: 'Must return the same Future');
      var users = await Future.wait(futures);
      expect(invokedMethods, ['init', 'signInSilently']);
      expect(googleSignIn.currentUser, isNotNull);
      expect(users, [googleSignIn.currentUser, googleSignIn.currentUser]);

      invokedMethods = <String>[];
      var freshUser = await googleSignIn.signInSilently();
      expect(invokedMethods, ['signInSilently']);
      expect(freshUser, isNot(users.first), reason: 'Must refresh user');
    });

    test('concurrent calls after error succeed', () async {
      responses['signInSilently'] = {'error': 'Not a user'};
      expect(googleSignIn.signInSilently(),
          throwsA(new isInstanceOf<AssertionError>()));
      expect(googleSignIn.signIn(), completion(isNotNull));
    });

    test('concurrent calls of different methods', () async {
      var futures = [
        googleSignIn.signInSilently(),
        googleSignIn.signIn(),
      ];
      expect(futures.first, isNot(futures.last));
      var users = await Future.wait(futures);
      expect(invokedMethods, ['init', 'signInSilently', 'signIn']);
      expect(users.first, isNot(users.last));
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
      expect(invokedMethods,
          ['init', 'signInSilently', 'signOut', 'signIn', 'disconnect']);
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}
