// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_identity_services_web/id.dart';
import 'package:google_identity_services_web/loader.dart' as loader;
import 'package:google_identity_services_web/oauth2.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

import 'src/people.dart' as people;
import 'src/utils.dart' as utils;

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

  // The scopes initially requested by the developer.
  //
  // We store this because we might need to add more at `signIn`, if the user
  // doesn't `silentSignIn`, we expand this list to consult the People API to
  // return some basic Authentication information.
  late List<String> _initialScopes;

  // The Google Identity Services client for oauth requests.
  late TokenClient _tokenClient;

  // Streams of credential and token responses.
  late StreamController<CredentialResponse> _credentialResponses;
  late StreamController<TokenResponse> _tokenResponses;

  // The last-seen credential and token responses
  CredentialResponse? _lastCredentialResponse;
  TokenResponse? _lastTokenResponse;

  // If the user *authenticates* (signs in) through oauth2, the SDK doesn't return
  // identity information anymore, so we synthesize it by calling the PeopleAPI
  // (if needed)
  //
  // (This is a synthetic _lastCredentialResponse)
  GoogleSignInUserData? _requestedUserData;

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
    // TODO: make _isInitCalled a future that resolves when `init` is called
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

    // Preserve the requested scopes to use them later in the `signIn` method.
    _initialScopes = List<String>.from(params.scopes);

    // Configure the Streams of credential (authentication)
    // and token (authorization) responses
    _tokenResponses = StreamController<TokenResponse>.broadcast();
    _credentialResponses = StreamController<CredentialResponse>.broadcast();
    _tokenResponses.stream.listen((TokenResponse response) {
      _lastTokenResponse = response;
    }, onError: (Object error) {
      _lastTokenResponse = null;
    });
    _credentialResponses.stream.listen((CredentialResponse response) {
      _lastCredentialResponse = response;
    }, onError: (Object error) {
      _lastCredentialResponse = null;
    });

    // TODO: Expose some form of 'debug' mode from the plugin?
    // TODO: Remove this before releasing.
    id.setLogLevel('debug');

    // Initialize `id` for the silent-sign in code.
    final IdConfiguration idConfig = IdConfiguration(
      client_id: appClientId!,
      callback: allowInterop(_onCredentialResponse),
      cancel_on_tap_outside: false,
      auto_select: true, // Attempt to sign-in silently.
    );
    id.initialize(idConfig);

    // Create a Token Client for authorization calls.
    final TokenClientConfig tokenConfig = TokenClientConfig(
      client_id: appClientId,
      hosted_domain: params.hostedDomain,
      callback: allowInterop(_onTokenResponse),
      error_callback: allowInterop(_onTokenError),
      // `scope` will be modified in the `signIn` method
      scope: ' ',
    );
    _tokenClient = oauth2.initTokenClient(tokenConfig);

    _isInitCalled = true;
    return;
  }

  // Handle a "normal" credential (authentication) response.
  //
  // (Normal doesn't mean successful, this might contain `error` information.)
  void _onCredentialResponse(CredentialResponse response) {
    if (response.error != null) {
      _credentialResponses.addError(response.error!);
    } else {
      _credentialResponses.add(response);
    }
  }

  // Handle a "normal" token (authorization) response.
  //
  // (Normal doesn't mean successful, this might contain `error` information.)
  void _onTokenResponse(TokenResponse response) {
    if (response.error != null) {
      _tokenResponses.addError(response.error!);
    } else {
      _tokenResponses.add(response);
    }
  }

  // Handle a "not-directly-related-to-authorization" error.
  //
  // Token clients have an additional `error_callback` for miscellaneous
  // errors, like "popup couldn't open" or "popup closed by user".
  void _onTokenError(Object? error) {
    // This is handled in a funky (js_interop) way because of:
    // https://github.com/dart-lang/sdk/issues/50899
    _tokenResponses.addError(getProperty(error!, 'type'));
  }

  @override
  Future<GoogleSignInUserData?> signInSilently() async {
    await initialized;

    final Completer<GoogleSignInUserData?> userDataCompleter =
        Completer<GoogleSignInUserData?>();

    // Ask the SDK to render the OneClick sign-in.
    id.prompt(allowInterop((PromptMomentNotification moment) {
      // Kick our handler to the bottom of the JS event queue, so the
      // _credentialResponses stream has time to propagate its last
      // value, so we can use _lastCredentialResponse in _onPromptMoment.
      Future<void>.delayed(Duration.zero, () {
        _onPromptMoment(moment, userDataCompleter);
      });
    }));

    return userDataCompleter.future;
  }

  // Handles "prompt moments" of the OneClick card UI.
  //
  // See: https://developers.google.com/identity/gsi/web/guides/receive-notifications-prompt-ui-status
  Future<void> _onPromptMoment(
    PromptMomentNotification moment,
    Completer<GoogleSignInUserData?> completer,
  ) async {
    if (completer.isCompleted) {
      return; // Skip once the moment has been handled.
    }

    if (moment.isDismissedMoment() &&
        moment.getDismissedReason() ==
            MomentDismissedReason.credential_returned) {
      // This could resolve with the returned credential, like so:
      //
      // completer.complete(
      //   utils.gisResponsesToUserData(
      //     _lastCredentialResponse,
      //   ));
      //
      // But since the credential is not performing any authorization, and current
      // apps expect that, we simulate a "failure" here.
      //
      // A successful `silentSignIn` however, will prevent an extra request later
      // when requesting oauth2 tokens at `signIn`.
      completer.complete(null);
      return;
    }

    // In any other 'failed' moments, return null and add an error to the stream.
    if (moment.isNotDisplayed() ||
        moment.isSkippedMoment() ||
        moment.isDismissedMoment()) {
      final String reason = moment.getNotDisplayedReason()?.toString() ??
          moment.getSkippedReason()?.toString() ??
          moment.getDismissedReason()?.toString() ??
          'silentSignIn failed.';

      _credentialResponses.addError(reason);
      completer.complete(null);
    }
  }

  @override
  Future<GoogleSignInUserData?> signIn() async {
    await initialized;
    final Completer<GoogleSignInUserData?> userDataCompleter =
        Completer<GoogleSignInUserData?>();

    try {
      // This toggles a popup, so `signIn` *must* be called with
      // user activation.
      _tokenClient.requestAccessToken(OverridableTokenClientConfig(
        scope: <String>[
          ..._initialScopes,
          // If the user hasn't gone through the auth process,
          // the plugin will attempt to `requestUserData` after,
          // so we need extra scopes to retrieve that info.
          if (_lastCredentialResponse == null) ...people.scopes,
        ].join(' '),
      ));

      // This stream is modified from _onTokenResponse and _onTokenError.
      await _tokenResponses.stream.first;

      // If the user hasn't authenticated, request their basic profile info
      // from the People API.
      //
      // This synthetic response will *not* contain an `idToken` field.
      if (_lastCredentialResponse == null && _requestedUserData == null) {
        assert(_lastTokenResponse != null);
        _requestedUserData = await people.requestUserData(
          _lastTokenResponse!,
          _lastCredentialResponse?.credential,
        );
      }
      // Complete user data either with the _lastCredentialResponse seen,
      // or the synthetic _requestedUserData from above.
      userDataCompleter.complete(
          utils.gisResponsesToUserData(_lastCredentialResponse) ??
              _requestedUserData);
    } catch (reason) {
      throw PlatformException(
        code: reason.toString(),
        message: 'Exception raised from signIn',
        details:
            'https://developers.google.com/identity/oauth2/web/guides/error',
      );
    }

    return userDataCompleter.future;
  }

  @override
  Future<GoogleSignInTokenData> getTokens({
    required String email,
    bool? shouldRecoverAuth,
  }) async {
    await initialized;

    return utils.gisResponsesToTokenData(
      _lastCredentialResponse,
      _lastTokenResponse,
    );
  }

  @override
  Future<void> signOut() async {
    await initialized;

    clearAuthCache();
    id.disableAutoSelect();
  }

  @override
  Future<void> disconnect() async {
    await initialized;

    if (_lastTokenResponse != null) {
      oauth2.revoke(_lastTokenResponse!.access_token);
    }
    signOut();
  }

  @override
  Future<bool> isSignedIn() async {
    await initialized;

    return _lastCredentialResponse != null || _requestedUserData != null;
  }

  @override
  Future<void> clearAuthCache({String token = 'unused_in_web'}) async {
    await initialized;

    _lastCredentialResponse = null;
    _lastTokenResponse = null;
    _requestedUserData = null;
  }

  @override
  Future<bool> requestScopes(List<String> scopes) async {
    await initialized;

    _tokenClient.requestAccessToken(OverridableTokenClientConfig(
      scope: scopes.join(' '),
      include_granted_scopes: true,
    ));

    await _tokenResponses.stream.first;

    return oauth2.hasGrantedAllScopes(_lastTokenResponse!, scopes);
  }
}
