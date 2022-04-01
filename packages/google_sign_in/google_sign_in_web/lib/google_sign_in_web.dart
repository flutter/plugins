// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:js/js.dart';

import 'src/generated/gapiauth2.dart' as auth2;
import 'src/load_gapi.dart' as gapi;
import 'src/utils.dart' show gapiUserToPluginUserData;

const String _kClientIdMetaSelector = 'meta[name=google-signin-client_id]';
const String _kClientIdAttributeName = 'content';

/// This is only exposed for testing. It shouldn't be accessed by users of the
/// plugin as it could break at any point.
@visibleForTesting
String gapiUrl = 'https://apis.google.com/js/platform.js';

/// Implementation of the google_sign_in plugin for Web.
class GoogleSignInPlugin extends GoogleSignInPlatform {
  /// Constructs the plugin immediately and begins initializing it in the
  /// background.
  ///
  /// The plugin is completely initialized when [initialized] completed.
  GoogleSignInPlugin() {
    _autoDetectedClientId = html
        .querySelector(_kClientIdMetaSelector)
        ?.getAttribute(_kClientIdAttributeName);

    _isGapiInitialized = gapi.inject(gapiUrl).then((_) => gapi.init());
  }

  late Future<void> _isGapiInitialized;
  late Future<void> _isAuthInitialized;
  bool _isInitCalled = false;

  // This method throws if init hasn't been called at some point in the past.
  // It is used by the [initialized] getter to ensure that users can't await
  // on a Future that will never resolve.
  void _assertIsInitCalled() {
    if (!_isInitCalled) {
      throw StateError(
          'GoogleSignInPlugin::init() must be called before any other method in this plugin.');
    }
  }

  /// A future that resolves when both GAPI and Auth2 have been correctly initialized.
  @visibleForTesting
  Future<void> get initialized {
    _assertIsInitCalled();
    return Future.wait(<Future<void>>[_isGapiInitialized, _isAuthInitialized]);
  }

  String? _autoDetectedClientId;

  /// Factory method that initializes the plugin with [GoogleSignInPlatform].
  static void registerWith(Registrar registrar) {
    GoogleSignInPlatform.instance = GoogleSignInPlugin();
  }

  @override
  Future<void> init({
    List<String> scopes = const <String>[],
    SignInOption signInOption = SignInOption.standard,
    String? hostedDomain,
    String? clientId,
  }) async {
    final String? appClientId = clientId ?? _autoDetectedClientId;
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

    await _isGapiInitialized;

    final auth2.GoogleAuth auth = auth2.init(auth2.ClientConfig(
      hosted_domain: hostedDomain,
      // The js lib wants a space-separated list of values
      scope: scopes.join(' '),
      client_id: appClientId!,
    ));

    final Completer<void> isAuthInitialized = Completer<void>();
    _isAuthInitialized = isAuthInitialized.future;
    _isInitCalled = true;

    auth.then(allowInterop((auth2.GoogleAuth initializedAuth) {
      // onSuccess

      // TODO(ditman): https://github.com/flutter/flutter/issues/48528
      // This plugin doesn't notify the app of external changes to the
      // state of the authentication, i.e: if you logout elsewhere...

      isAuthInitialized.complete();
    }), allowInterop((auth2.GoogleAuthInitFailureError reason) {
      // onError
      isAuthInitialized.completeError(PlatformException(
        code: reason.error,
        message: reason.details,
        details:
            'https://developers.google.com/identity/sign-in/web/reference#error_codes',
      ));
    }));

    return _isAuthInitialized;
  }

  @override
  Future<GoogleSignInUserData?> signInSilently() async {
    await initialized;

    return gapiUserToPluginUserData(
        auth2.getAuthInstance()?.currentUser?.get());
  }

  @override
  Future<GoogleSignInUserData?> signIn() async {
    await initialized;
    try {
      return gapiUserToPluginUserData(await auth2.getAuthInstance()?.signIn());
    } on auth2.GoogleAuthSignInError catch (reason) {
      throw PlatformException(
        code: reason.error,
        message: 'Exception raised from GoogleAuth.signIn()',
        details:
            'https://developers.google.com/identity/sign-in/web/reference#error_codes_2',
      );
    }
  }

  @override
  Future<GoogleSignInTokenData> getTokens(
      {required String email, bool? shouldRecoverAuth}) async {
    await initialized;

    final auth2.GoogleUser? currentUser =
        auth2.getAuthInstance()?.currentUser?.get();
    final auth2.AuthResponse? response = currentUser?.getAuthResponse();

    return GoogleSignInTokenData(
        idToken: response?.id_token, accessToken: response?.access_token);
  }

  @override
  Future<void> signOut() async {
    await initialized;

    return auth2.getAuthInstance()?.signOut();
  }

  @override
  Future<void> disconnect() async {
    await initialized;

    final auth2.GoogleUser? currentUser =
        auth2.getAuthInstance()?.currentUser?.get();

    if (currentUser == null) {
      return;
    }

    return currentUser.disconnect();
  }

  @override
  Future<bool> isSignedIn() async {
    await initialized;

    final auth2.GoogleUser? currentUser =
        auth2.getAuthInstance()?.currentUser?.get();

    if (currentUser == null) {
      return false;
    }

    return currentUser.isSignedIn();
  }

  @override
  Future<void> clearAuthCache({required String token}) async {
    await initialized;

    return auth2.getAuthInstance()?.disconnect();
  }

  @override
  Future<bool> requestScopes(List<String> scopes) async {
    await initialized;

    final auth2.GoogleUser? currentUser =
        auth2.getAuthInstance()?.currentUser?.get();

    if (currentUser == null) {
      return false;
    }

    final String grantedScopes = currentUser.getGrantedScopes() ?? '';
    final Iterable<String> missingScopes =
        scopes.where((String scope) => !grantedScopes.contains(scope));

    if (missingScopes.isEmpty) {
      return true;
    }

    final Object? response = await currentUser
        .grant(auth2.SigninOptions(scope: missingScopes.join(' ')));

    return response != null;
  }
}
