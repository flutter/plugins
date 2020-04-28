// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
@TestOn('browser')

import 'package:flutter_test/flutter_test.dart';

import 'package:google_sign_in_web/src/generated/gapiauth2.dart' as gapi;
import 'package:google_sign_in_web/src/utils.dart';
import 'package:mockito/mockito.dart';

class MockGoogleUser extends Mock implements gapi.GoogleUser {}

class MockBasicProfile extends Mock implements gapi.BasicProfile {}

void main() {
  // The non-null use cases are covered by the auth2_test.dart file.

  group('gapiUserToPluginUserData', () {
    var mockUser;

    setUp(() {
      mockUser = MockGoogleUser();
    });

    test('null user -> null response', () {
      expect(gapiUserToPluginUserData(null), isNull);
    });

    test('not signed-in user -> null response', () {
      when(mockUser.isSignedIn()).thenReturn(false);
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });

    test('signed-in, but null profile user -> null response', () {
      when(mockUser.isSignedIn()).thenReturn(true);
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });

    test('signed-in, null userId in profile user -> null response', () {
      when(mockUser.isSignedIn()).thenReturn(true);
      when(mockUser.getBasicProfile()).thenReturn(MockBasicProfile());
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });
  });
}
