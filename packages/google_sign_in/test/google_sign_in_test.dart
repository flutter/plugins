// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

void main() {
  Map userData = {
    "email": "john.doe@gmail.com",
    "id": "8162538176523816253123",
    "photoUrl": "https://lh5.googleusercontent.com/photo.jpg",
    "displayName": "John Doe",
  };
  Map methodResponses = {
    'init': null,
    'signInSilently': userData,
    'signIn': userData,
    'signOut': null,
    'disconnect': {},
  };

  group('$GoogleSignIn', () {
    GoogleSignIn googleSignIn;

    List<String> invokedMethods = <String>[];

    setUp(() {
      MockPlatformChannel mockChannel = new MockPlatformChannel();

      invokedMethods = <String>[];

      dynamic answer(Invocation invocation) {
        final method = invocation.positionalArguments[0];
        invokedMethods.add(method);
        final response = methodResponses[method];
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

    test('disconnect', () async {
      await googleSignIn.disconnect();
      expect(invokedMethods, ['init', 'disconnect']);
      expect(googleSignIn.currentUser, isNull);
    });

    test('concurrent signIn', () async {
      var futures = [
        googleSignIn.signInSilently(),
        googleSignIn.signInSilently(),
        googleSignIn.signIn()
      ];
      var users = await Future.wait(futures);
      expect(invokedMethods, ['init', 'signInSilently']);
      expect(googleSignIn.currentUser, isNotNull);
      expect(users, [
        googleSignIn.currentUser,
        googleSignIn.currentUser,
        googleSignIn.currentUser
      ]);
    });

    test('concurrent signOut', () async {
      var futures = [
        googleSignIn.signOut(),
        googleSignIn.signOut(),
        googleSignIn.disconnect()
      ];
      var users = await Future.wait(futures);
      expect(invokedMethods, ['init', 'signOut']);
      expect(googleSignIn.currentUser, isNull);
      expect(users, [null, null, null]);
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel {}
