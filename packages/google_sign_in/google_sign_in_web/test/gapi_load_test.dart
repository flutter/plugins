// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('browser')

import 'dart:html' as html;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'gapi_mocks/gapi_mocks.dart' as gapi_mocks;
import 'utils.dart';

void main() {
  gapiUrl = toBase64Url(gapi_mocks.auth2InitSuccess(GoogleSignInUserData()));

  test('Plugin is initialized after GAPI fully loads and init is called',
      () async {
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
        reason:
            'The plugin should throw if checking for `initialized` before calling .init');
    await plugin.init(hostedDomain: '', clientId: '');
    await plugin.initialized;
    expect(
      plugin.initialized,
      completes,
      reason: 'The plugin should complete the future once initialized.',
    );
  });
}
