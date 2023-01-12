// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_identity_services_web/loader.dart' as loader;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'src/gis_client.dart';

const String _kClientIdMetaSelector = 'meta[name=google-signin-client_id]';
const String _kClientIdAttributeName = 'content';

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

    _isJsSdkLoaded = loader.loadWebSdk();
  }

  late Future<void> _isJsSdkLoaded;
  bool _isInitCalled = false;

  // The instance of [GisSdkClient] backing the plugin.
  late GisSdkClient _gisClient;

  // This method throws if init or initWithParams hasn't been called at some
  // point in the past. It is used by the [initialized] getter to ensure that
  // users can't await on a Future that will never resolve.
  void _assertIsInitCalled() {
    if (!_isInitCalled) {
      throw StateError(
        'GoogleSignInPlugin::init() or GoogleSignInPlugin::initWithParams() '
        'must be called before any other method in this plugin.',
      );
    }
  }

  /// A future that resolves when the SDK has been correctly loaded.
  @visibleForTesting
  Future<void> get initialized {
    _assertIsInitCalled();
    return _isJsSdkLoaded;
  }

  // Stores the clientId found in the DOM (if any).
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
  }) {
    return initWithParams(SignInInitParameters(
      scopes: scopes,
      signInOption: signInOption,
      hostedDomain: hostedDomain,
      clientId: clientId,
    ));
  }

  @override
  Future<void> initWithParams(SignInInitParameters params) async {
    final String? appClientId = params.clientId ?? _autoDetectedClientId;
    assert(
        appClientId != null,
        'ClientID not set. Either set it on a '
        '<meta name="google-signin-client_id" content="CLIENT_ID" /> tag,'
        ' or pass clientId when initializing GoogleSignIn');

    assert(params.serverClientId == null,
        'serverClientId is not supported on Web.');

    assert(
        !params.scopes.any((String scope) => scope.contains(' ')),
        "OAuth 2.0 Scopes for Google APIs can't contain spaces. "
        'Check https://developers.google.com/identity/protocols/googlescopes '
        'for a list of valid OAuth 2.0 scopes.');

    await _isJsSdkLoaded;

    final GisSdkClient gisClient = GisSdkClient(
      clientId: appClientId!,
      hostedDomain: params.hostedDomain,
      initialScopes: List<String>.from(params.scopes),
      // *TODO(dit): Remove this before releasing.
      loggingEnabled: true,
    );

    return initWithClient(gisClient);
  }

  /// Initializes the plugin with a pre-made [GisSdkClient], that can be overridden from tests.
  @visibleForTesting
  Future<void> initWithClient(GisSdkClient gisClient) async {
    _gisClient = gisClient;

    _isInitCalled = true;
  }

  @override
  Future<GoogleSignInUserData?> signInSilently() async {
    await initialized;

    // Since the new GIS SDK does *not* perform authorization at the same time as
    // authentication (and every one of our users expects that), we need to tell
    // the plugin that this failed regardless of the actual result.
    //
    // However, if this succeeds, we'll save a People API request later.
    return _gisClient.signInSilently().then((_) => null);
  }

  @override
  Future<GoogleSignInUserData?> signIn() async {
    await initialized;

    // This method mainly does oauth2 authorization, which happens to also do
    // authentication if needed. However, the authentication information is not
    // returned anymore.
    //
    // This method will synthesize authentication information from the People API
    // if needed (or use the last identity seen from signInSilently).
    try {
      return _gisClient.signIn();
    } catch (reason) {
      throw PlatformException(
        code: reason.toString(),
        message: 'Exception raised from signIn',
        details:
            'https://developers.google.com/identity/oauth2/web/guides/error',
      );
    }
  }

  @override
  Future<GoogleSignInTokenData> getTokens({
    required String email,
    bool? shouldRecoverAuth,
  }) async {
    await initialized;

    return _gisClient.getTokens();
  }

  @override
  Future<void> signOut() async {
    await initialized;

    _gisClient.signOut();
  }

  @override
  Future<void> disconnect() async {
    await initialized;

    _gisClient.disconnect();
  }

  @override
  Future<bool> isSignedIn() async {
    await initialized;

    return _gisClient.isSignedIn();
  }

  @override
  Future<void> clearAuthCache({required String token}) async {
    await initialized;

    _gisClient.clearAuthCache();
  }

  @override
  Future<bool> requestScopes(List<String> scopes) async {
    await initialized;

    return _gisClient.requestScopes(scopes);
  }
}
