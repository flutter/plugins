// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';

import 'package:google_sign_in_web/src/generated/gapiauth2.dart' as gapi;
import 'package:google_sign_in_web/src/utils.dart';
import 'package:mockito/mockito.dart';

class MockGoogleUser extends Mock implements gapi.GoogleUser {}

class MockBasicProfile extends Mock implements gapi.BasicProfile {}

void main() {
  // The non-null use cases are covered by the auth2_test.dart file.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('gapiUserToPluginUserData', () {
    var mockUser;

    setUp(() {
      mockUser = MockGoogleUser();
    });

    testWidgets('null user -> null response', (WidgetTester tester) async {
      expect(gapiUserToPluginUserData(null), isNull);
    });

    testWidgets('not signed-in user -> null response',
        (WidgetTester tester) async {
      when(mockUser.isSignedIn()).thenReturn(false);
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });

    testWidgets('signed-in, but null profile user -> null response',
        (WidgetTester tester) async {
      when(mockUser.isSignedIn()).thenReturn(true);
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });

    testWidgets('signed-in, null userId in profile user -> null response',
        (WidgetTester tester) async {
      when(mockUser.isSignedIn()).thenReturn(true);
      when(mockUser.getBasicProfile()).thenReturn(MockBasicProfile());
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });
  });
}
