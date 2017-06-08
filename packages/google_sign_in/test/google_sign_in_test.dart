// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  group('$GoogleSignIn', () {
    GoogleSignIn googleSignIn;

    List<String> invokedMethods;
    Map<String, dynamic> stubResponse;

    setUp(() {
      MockPlatformChannel mockChannel = new MockPlatformChannel();

      invokedMethods = <String>[];
      stubResponse = _failureResponse();

      Function invocationRecorder = (Invocation invocation) async {
        invokedMethods.add(invocation.positionalArguments[0]);
        return stubResponse;
      };
      // Mock with and without optional 2nd argument.
      when(mockChannel.invokeMethod(any)).thenAnswer(invocationRecorder);
      when(mockChannel.invokeMethod(any, any)).thenAnswer(invocationRecorder);

      googleSignIn = new GoogleSignIn.private(channel: mockChannel);
    });

    test('signInSilently failure', () async {
      GoogleSignInAccount user = await googleSignIn.signInSilently();
      expect(invokedMethods, ['init', 'signInSilently']);
      expect(user, isNull);
    });

    test('signInSilently success', () async {
      stubResponse = _successResponse();
      GoogleSignInAccount user = await googleSignIn.signInSilently();
      expect(invokedMethods, ['init', 'signInSilently']);
      expect(user.id, equals('12345'));

      // Second call of signInSilently() should avoid second plugin call.
      invokedMethods.clear();
      GoogleSignInAccount userAgain = await googleSignIn.signInSilently();
      expect(invokedMethods, isEmpty);
      expect(userAgain, same(user));
    });

    test('signIn failure', () async {
      GoogleSignInAccount user = await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'signIn']);
      expect(user, isNull);
    });

    test('signIn success', () async {
      stubResponse = _successResponse();
      GoogleSignInAccount user = await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'signIn']);
      expect(user.id, equals('12345'));

      // Second call of signIn() should avoid second plugin call.
      invokedMethods.clear();
      GoogleSignInAccount userAgain = await googleSignIn.signIn();
      expect(invokedMethods, isEmpty);
      expect(userAgain, same(user));
    });

    test('signIn failure', () async {
      await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'signIn']);
    });

    test('signOut', () async {
      await googleSignIn.signOut();
      expect(invokedMethods, ['init', 'signOut']);
    });

    test('disconnect', () async {
      await googleSignIn.disconnect();
      expect(invokedMethods, ['init', 'disconnect']);
    });

    test('disconnect; empty response as on iOS', () async {
      stubResponse = _emptyResponse();
      await googleSignIn.disconnect();
      expect(invokedMethods, ['init', 'disconnect']);
    });
  });
}

Map<String, dynamic> _failureResponse() => null;

Map<String, dynamic> _emptyResponse() => <String, dynamic>{};

Map<String, dynamic> _successResponse() => <String, dynamic>{
  'displayName': 'Mr Ed',
  'id': '12345',
};

class MockPlatformChannel extends Mock implements MethodChannel { }
