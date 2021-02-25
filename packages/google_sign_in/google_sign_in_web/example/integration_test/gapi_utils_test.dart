// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
import 'package:flutter_test/flutter_test.dart';

import 'package:integration_test/integration_test.dart';

import 'package:google_sign_in_web/src/generated/gapiauth2.dart' as gapi;
import 'package:google_sign_in_web/src/utils.dart';

void main() {
  // The non-null use cases are covered by the auth2_test.dart file.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('gapiUserToPluginUserData', () {
    late FakeGoogleUser mockUser;

    setUp(() {
      mockUser = FakeGoogleUser();
    });

    testWidgets('null user -> null response', (WidgetTester tester) async {
      expect(gapiUserToPluginUserData(null), isNull);
    });

    testWidgets('not signed-in user -> null response',
        (WidgetTester tester) async {
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });

    testWidgets('signed-in, but null profile user -> null response',
        (WidgetTester tester) async {
      mockUser.setIsSignedIn(true);
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });

    testWidgets('signed-in, null userId in profile user -> null response',
        (WidgetTester tester) async {
      mockUser.setIsSignedIn(true);
      mockUser.setBasicProfile(FakeBasicProfile());
      expect(gapiUserToPluginUserData(mockUser), isNull);
    });
  });
}

class FakeGoogleUser extends Fake implements gapi.GoogleUser {
  bool _isSignedIn = false;
  gapi.BasicProfile? _basicProfile;

  @override
  bool isSignedIn() => _isSignedIn;
  @override
  gapi.BasicProfile? getBasicProfile() => _basicProfile;

  void setIsSignedIn(bool isSignedIn) {
    _isSignedIn = isSignedIn;
  }

  void setBasicProfile(gapi.BasicProfile basicProfile) {
    _basicProfile = basicProfile;
  }
}

class FakeBasicProfile extends Fake implements gapi.BasicProfile {
  String? _id;

  @override
  String? getId() => _id;
}
