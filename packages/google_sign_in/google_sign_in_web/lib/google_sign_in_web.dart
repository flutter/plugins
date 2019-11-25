// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:meta/meta.dart';

import 'src/generated/gapiauth2.dart' as auth2;
// TODO: Remove once this lands https://github.com/dart-lang/language/issues/671
import 'src/generated/gapiauth2.dart' show GoogleAuthExtensions;
import 'src/load_gapi.dart' as gapi;
import 'src/utils.dart' show gapiUserToPluginUserData;

const String _kClientIdMetaSelector = 'meta[name=google-signin-client_id]';
const String _kClientIdAttributeName = 'content';

@visibleForTesting
String gapiUrl = 'https://apis.google.com/js/platform.js';

/// Implementation of the google_sign_in plugin for Web
class GoogleSignInPlugin extends GoogleSignInPlatform {
  GoogleSignInPlugin() {
    _autoDetectedClientId = html
        .querySelector(_kClientIdMetaSelector)
        ?.getAttribute(_kClientIdAttributeName);

    _isGapiInitialized = gapi.inject(gapiUrl).then((_) => gapi.init());
  }

  Future<void> _isGapiInitialized;

  @visibleForTesting
  Future<void> get initialized => _isGapiInitialized;

  String _autoDetectedClientId;
  FutureOr<auth2.GoogleUser> _lastSeenUser;

  static void registerWith(Registrar registrar) {
    GoogleSignInPlatform.instance = GoogleSignInPlugin();
  }

  @override
  Future<void> init(
      {@required String hostedDomain,
      List<String> scopes = const <String>[],
      SignInOption signInOption = SignInOption.standard,
      String clientId}) async {
    final String appClientId = clientId ?? _autoDetectedClientId;
    assert(
        appClientId != null,
        'ClientID not set. Either set it on a '
        '<meta name="google-signin-client_id" content="CLIENT_ID" /> tag,'
        ' or pass clientId when calling init()');

    assert(
        !scopes.any((String scope) => scope.contains(' ')),
        'OAuth 2.0 Scopes for Google APIs can\'t contain spaces.'
        'Check https://developers.google.com/identity/protocols/googlescopes '
        'for a list of valid OAuth 2.0 scopes.');

    await initialized;

    final auth2.GoogleAuth auth = auth2.init(auth2.ClientConfig(
      hosted_domain: hostedDomain,
      // The js lib wants a space-separated list of values
      scope: scopes.join(' '),
      client_id: appClientId,
    ));

    // Subscribe to changes in the auth instance returned by init,
    // and cache the _lastSeenUser as we get notified of new values.
    final Completer<auth2.GoogleUser> initUserCompleter =
        Completer<auth2.GoogleUser>();

    auth.currentUser.listen(allowInterop((auth2.GoogleUser nextUser) {
      if (!initUserCompleter.isCompleted) {
        initUserCompleter.complete(nextUser);
      } else {
        _lastSeenUser = nextUser;
      }
    }));
    _lastSeenUser = initUserCompleter.future;

    return null;
  }

  @override
  Future<GoogleSignInUserData> signInSilently() async {
    await initialized;

    return gapiUserToPluginUserData(await _lastSeenUser);
  }

  @override
  Future<GoogleSignInUserData> signIn() async {
    await initialized;

    return gapiUserToPluginUserData(await auth2.getAuthInstance().signIn());
  }

  @override
  Future<GoogleSignInTokenData> getTokens(
      {@required String email, bool shouldRecoverAuth}) async {
    await initialized;

    final auth2.GoogleUser currentUser =
        auth2.getAuthInstance()?.currentUser?.get();
    final auth2.AuthResponse response = currentUser.getAuthResponse();

    return GoogleSignInTokenData(
        idToken: response.id_token, accessToken: response.access_token);
  }

  @override
  Future<void> signOut() async {
    await initialized;

    return auth2.getAuthInstance().signOut();
  }

  @override
  Future<void> disconnect() async {
    await initialized;

    final auth2.GoogleUser currentUser =
        auth2.getAuthInstance()?.currentUser?.get();
    return currentUser.disconnect();
  }

  @override
  Future<bool> isSignedIn() async {
    await initialized;

    final auth2.GoogleUser currentUser =
        auth2.getAuthInstance()?.currentUser?.get();
    return currentUser.isSignedIn();
  }

  @override
  Future<void> clearAuthCache({String token}) async {
    await initialized;

    _lastSeenUser = null;
    return auth2.getAuthInstance().disconnect();
  }
}
