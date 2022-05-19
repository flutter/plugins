// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_web/src/generated/gapiauth2.dart' as gapi;
import 'package:google_sign_in_web/src/utils.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  // The non-null use cases are covered by the auth2_test.dart file.
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('gapiUserToPluginUserData', () {
    late FakeGoogleUser fakeUser;

    setUp(() {
      fakeUser = FakeGoogleUser();
    });

    testWidgets('null user -> null response', (WidgetTester tester) async {
      expect(gapiUserToPluginUserData(null), isNull);
    });

    testWidgets('not signed-in user -> null response',
        (WidgetTester tester) async {
      expect(gapiUserToPluginUserData(fakeUser), isNull);
    });

    testWidgets('signed-in, but null profile user -> null response',
        (WidgetTester tester) async {
      fakeUser.setIsSignedIn(true);
      expect(gapiUserToPluginUserData(fakeUser), isNull);
    });

    testWidgets('signed-in, null userId in profile user -> null response',
        (WidgetTester tester) async {
      fakeUser.setIsSignedIn(true);
      fakeUser.setBasicProfile(FakeBasicProfile());
      expect(gapiUserToPluginUserData(fakeUser), isNull);
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

  // ignore: use_setters_to_change_properties
  void setIsSignedIn(bool isSignedIn) {
    _isSignedIn = isSignedIn;
  }

  // ignore: use_setters_to_change_properties
  void setBasicProfile(gapi.BasicProfile basicProfile) {
    _basicProfile = basicProfile;
  }
}

class FakeBasicProfile extends Fake implements gapi.BasicProfile {
  String? _id;

  @override
  String? getId() => _id;
}
