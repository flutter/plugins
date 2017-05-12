// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@Skip('TODO(goderbauer): fix tests, https://github.com/flutter/flutter/issues/10050')
import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'package:flutter/services.dart';

import 'package:google_sign_in/google_sign_in.dart';

void main() {
  group('$GoogleSignIn', () {
    GoogleSignIn googleSignIn;

    List<String> invokedMethods = <String>[];

    setUp(() {
      MockPlatformChannel mockChannel = new MockPlatformChannel();

      invokedMethods = <String>[];

      when(mockChannel.invokeMethod(any, any)).thenAnswer((Invocation invocation) {
        invokedMethods.add(invocation.positionalArguments[0]);
        return new Future.value(null);
      });

      googleSignIn = new GoogleSignIn.private(channel: mockChannel);
    });

    test('signInSilently', () async {
      await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'signInSilently']);
    });

    test('setUserId', () async {
      await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'signIn']);
    });

    test('signOut', () async {
      await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'signOut']);
    });

    test('disconnect', () async {
      await googleSignIn.signIn();
      expect(invokedMethods, ['init', 'disconnect']);
    });
  });
}

class MockPlatformChannel extends Mock implements MethodChannel { }
