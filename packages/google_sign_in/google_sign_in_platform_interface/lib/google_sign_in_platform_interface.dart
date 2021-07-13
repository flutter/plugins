// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:meta/meta.dart' show visibleForTesting;
import 'src/method_channel_google_sign_in.dart';
import 'src/types.dart';

export 'src/method_channel_google_sign_in.dart';
export 'src/types.dart';

/// The interface that implementations of google_sign_in must implement.
///
/// Platform implementations that live in a separate package should extend this
/// class rather than implement it as `google_sign_in` does not consider newly
/// added methods to be breaking changes. Extending this class (using `extends`)
/// ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by
/// newly added [GoogleSignInPlatform] methods.
abstract class GoogleSignInPlatform {
  /// Only mock implementations should set this to `true`.
  ///
  /// Mockito mocks implement this class with `implements` which is forbidden
  /// (see class docs). This property provides a backdoor for mocks to skip the
  /// verification that the class isn't implemented with `implements`.
  @visibleForTesting
  bool get isMock => false;

  /// The default instance of [GoogleSignInPlatform] to use.
  ///
  /// Platform-specific plugins should override this with their own
  /// platform-specific class that extends [GoogleSignInPlatform] when they
  /// register themselves.
  ///
  /// Defaults to [MethodChannelGoogleSignIn].
  static GoogleSignInPlatform get instance => _instance;

  static GoogleSignInPlatform _instance = MethodChannelGoogleSignIn();

  // TODO(amirh): Extract common platform interface logic.
  // https://github.com/flutter/flutter/issues/43368
  static set instance(GoogleSignInPlatform instance) {
    if (!instance.isMock) {
      try {
        instance._verifyProvidesDefaultImplementations();
      } on NoSuchMethodError catch (_) {
        throw AssertionError(
            'Platform interfaces must not be implemented with `implements`');
      }
    }
    _instance = instance;
  }

  /// This method ensures that [GoogleSignInPlatform] isn't implemented with `implements`.
  ///
  /// See class docs for more details on why using `implements` to implement
  /// [GoogleSignInPlatform] is forbidden.
  ///
  /// This private method is called by the [instance] setter, which should fail
  /// if the provided instance is a class implemented with `implements`.
  void _verifyProvidesDefaultImplementations() {}

  /// Initializes the plugin. You must call this method before calling other
  /// methods.
  ///
  /// The [hostedDomain] argument specifies a hosted domain restriction. By
  /// setting this, sign in will be restricted to accounts of the user in the
  /// specified domain. By default, the list of accounts will not be restricted.
  ///
  /// The list of [scopes] are OAuth scope codes to request when signing in.
  /// These scope codes will determine the level of data access that is granted
  /// to your application by the user. The full list of available scopes can be
  /// found here: <https://developers.google.com/identity/protocols/googlescopes>
  ///
  /// The [signInOption] determines the user experience. [SigninOption.games] is
  /// only supported on Android.
  ///
  /// See:
  /// https://developers.google.com/identity/sign-in/web/reference#gapiauth2initparams
  Future<void> init({
    List<String> scopes = const <String>[],
    SignInOption signInOption = SignInOption.standard,
    String? hostedDomain,
    String? clientId,
  }) async {
    throw UnimplementedError('init() has not been implemented.');
  }

  /// Attempts to reuse pre-existing credentials to sign in again, without user interaction.
  Future<GoogleSignInUserData?> signInSilently() async {
    throw UnimplementedError('signInSilently() has not been implemented.');
  }

  /// Signs in the user with the options specified to [init].
  Future<GoogleSignInUserData?> signIn() async {
    throw UnimplementedError('signIn() has not been implemented.');
  }

  /// Returns the Tokens used to authenticate other API calls.
  Future<GoogleSignInTokenData> getTokens(
      {required String email, bool? shouldRecoverAuth}) async {
    throw UnimplementedError('getTokens() has not been implemented.');
  }

  /// Signs out the current account from the application.
  Future<void> signOut() async {
    throw UnimplementedError('signOut() has not been implemented.');
  }

  /// Revokes all of the scopes that the user granted.
  Future<void> disconnect() async {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Returns whether the current user is currently signed in.
  Future<bool> isSignedIn() async {
    throw UnimplementedError('isSignedIn() has not been implemented.');
  }

  /// Clears any cached information that the plugin may be holding on to.
  Future<void> clearAuthCache({required String token}) async {
    throw UnimplementedError('clearAuthCache() has not been implemented.');
  }

  /// Requests the user grants additional Oauth [scopes].
  ///
  /// Scopes should come from the full  list
  /// [here](https://developers.google.com/identity/protocols/googlescopes).
  Future<bool> requestScopes(List<String> scopes) async {
    throw UnimplementedError('requestScopes() has not been implmented.');
  }
}
