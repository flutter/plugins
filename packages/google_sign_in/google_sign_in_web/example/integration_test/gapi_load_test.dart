// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:integration_test/integration_test.dart';

import 'gapi_mocks/gapi_mocks.dart' as gapi_mocks;
import 'src/test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  gapiUrl = toBase64Url(gapi_mocks.auth2InitSuccess(
      GoogleSignInUserData(email: 'test@test.com', id: '1234')));

  testWidgets('Plugin is initialized after GAPI fully loads and init is called',
      (WidgetTester tester) async {
    expect(
      html.querySelector('script[src^="data:"]'),
      isNull,
      reason: 'Mock script not present before instantiating the plugin',
    );
    final GoogleSignInPlugin plugin = GoogleSignInPlugin();
    expect(
      html.querySelector('script[src^="data:"]'),
      isNotNull,
      reason: 'Mock script should be injected',
    );
    expect(() {
      plugin.initialized;
    }, throwsStateError,
        reason: 'The plugin should throw if checking for `initialized` before '
            'calling .initWithParams');
    await plugin.initWithParams(const SignInInitParameters(
      hostedDomain: '',
      clientId: '',
    ));
    await plugin.initialized;
    expect(
      plugin.initialized,
      completes,
      reason: 'The plugin should complete the future once initialized.',
    );
  });
}
