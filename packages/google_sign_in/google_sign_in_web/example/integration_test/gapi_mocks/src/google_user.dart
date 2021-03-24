// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

// Creates the JS representation of some user data
String googleUser(GoogleSignInUserData data) => '''
{
  getBasicProfile: () => {
    return {
      getName: () => '${data.displayName}',
      getEmail: () => '${data.email}',
      getId: () => '${data.id}',
      getImageUrl: () => '${data.photoUrl}',
    };
  },
  getAuthResponse: () => {
    return {
      id_token: '${data.idToken}',
      access_token: 'access_${data.idToken}',
    }
  },
  getGrantedScopes: () => 'some scope',
  grant: () => true,
  isSignedIn: () => {
    return ${data != null ? 'true' : 'false'};
  },
}
''';
