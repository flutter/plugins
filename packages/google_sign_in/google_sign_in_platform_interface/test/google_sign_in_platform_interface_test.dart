// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('$GoogleSignInPlatform', () {
    test('$MethodChannelGoogleSignIn is the default instance', () {
      expect(GoogleSignInPlatform.instance, isA<MethodChannelGoogleSignIn>());
    });

    test('Cannot be implemented with `implements`', () {
      expect(() {
        GoogleSignInPlatform.instance = ImplementsGoogleSignInPlatform();
      }, throwsAssertionError);
    });

    test('Can be extended', () {
      GoogleSignInPlatform.instance = ExtendsGoogleSignInPlatform();
    });

    test('Can be mocked with `implements`', () {
      final ImplementsGoogleSignInPlatform mock =
          ImplementsGoogleSignInPlatform();
      when(mock.isMock).thenReturn(true);
      GoogleSignInPlatform.instance = mock;
    });
  });
}

class ImplementsGoogleSignInPlatform extends Mock
    implements GoogleSignInPlatform {}

class ExtendsGoogleSignInPlatform extends GoogleSignInPlatform {}
