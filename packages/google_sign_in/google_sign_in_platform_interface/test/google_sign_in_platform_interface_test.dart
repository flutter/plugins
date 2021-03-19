// Copyright 2013 The Flutter Authors. All rights reserved.
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
      }, throwsA(isA<Error>()));
    });

    test('Can be extended', () {
      GoogleSignInPlatform.instance = ExtendsGoogleSignInPlatform();
    });

    test('Can be mocked with `implements`', () {
      GoogleSignInPlatform.instance = ImplementsWithIsMock();
    });
  });
}

class ImplementsWithIsMock extends Mock implements GoogleSignInPlatform {
  @override
  bool get isMock => true;
}

class ImplementsGoogleSignInPlatform extends Mock
    implements GoogleSignInPlatform {}

class ExtendsGoogleSignInPlatform extends GoogleSignInPlatform {}
