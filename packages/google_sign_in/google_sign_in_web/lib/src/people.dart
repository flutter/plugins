// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:http/http.dart' as http;

/// Basic scopes for self-id
const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/userinfo.profile',
  'https://www.googleapis.com/auth/userinfo.email',
];

/// People API to return my profile info...
const String MY_PROFILE = 'https://content-people.googleapis.com/v1/people/me'
    '?sources=READ_SOURCE_TYPE_PROFILE'
    '&personFields=photos%2Cnames%2CemailAddresses';

/// Requests user data from the People API.
///
/// The `idToken` is an optional string that the plugin may have, if the user
/// has consented to the `silentSignIn` flow.
Future<GoogleSignInUserData?> requestUserData(
    TokenResponse tokenResponse, String? idToken) async {

  // Request my profile from the People API...
  final Map<String, Object?> profile = await _get(tokenResponse, MY_PROFILE);

  // Now transform the JSON response into a GoogleSignInUserData...
  final String? userId = _extractId(profile);
  final String? email = _extractField(
    profile['emailAddresses'] as List<Object?>?,
    'value',
  );

  assert(userId != null);
  assert(email != null);

  return GoogleSignInUserData(
    id: userId!,
    email: email!,
    displayName: _extractField(
      profile['names'] as List<Object?>?,
      'displayName',
    ),
    photoUrl: _extractField(
      profile['photos'] as List<Object?>?,
      'url',
    ),
    idToken: idToken,
  );
}

/// Extracts the UserID
String? _extractId(Map<String, Object?> profile) {
  final String? resourceName = profile['resourceName'] as String?;
  return resourceName?.substring(7);
}

String? _extractField(List<Object?>? values, String fieldName) {
  if (values != null) {
    for (final Object? value in values) {
      if (value != null && value is Map<String, Object?>) {
        final bool isPrimary = _deepGet(value,
            path: <String>['metadata', 'primary'], defaultValue: false);
        if (isPrimary) {
          return value[fieldName] as String?;
        }
      }
    }
  }

  return null;
}

/// Attempts to get a property of type `T` from a deeply nested object.
///
/// Returns `default` if the property is not found.
T _deepGet<T>(
  Map<String, Object?> source, {
  required List<String> path,
  required T defaultValue,
}) {
  final String value = path.removeLast();
  Object? data = source;
  for (final String index in path) {
    if (data != null && data is Map) {
      data = data[index];
    } else {
      break;
    }
  }
  if (data != null && data is Map) {
    return (data[value] ?? defaultValue) as T;
  } else {
    return defaultValue;
  }
}

/// Gets from [url] with an authorization header defined by [token].
///
/// Attempts to [jsonDecode] the result.
Future<Map<String, Object?>> _get(TokenResponse token, String url) async {
  final Uri uri = Uri.parse(url);
  final http.Response response = await http.get(uri, headers: <String, String>{
    'Authorization': '${token.token_type} ${token.access_token}',
  });

  if (response.statusCode != 200) {
    throw http.ClientException(response.body, uri);
  }

  return jsonDecode(response.body) as Map<String, Object?>;
}
