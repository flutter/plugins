// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ui' show hashValues;

import 'package:flutter/services.dart' show MethodChannel, PlatformException;
import 'package:meta/meta.dart' show visibleForTesting;

import 'src/common.dart';

export 'src/common.dart';
export 'widgets.dart';

enum SignInOption { standard, games }

class GoogleSignInAuthentication {
  GoogleSignInAuthentication._(this._data);

  final Map<dynamic, dynamic> _data;

  /// An OpenID Connect ID token that identifies the user.
  String get idToken => _data['idToken'];

  /// The OAuth2 access token to access Google services.
  String get accessToken => _data['accessToken'];

  @override
  String toString() => 'GoogleSignInAuthentication:$_data';
}

class GoogleSignInAccount implements GoogleIdentity {
  GoogleSignInAccount._(this._googleSignIn, Map<dynamic, dynamic> data)
      : displayName = data['displayName'],
        email = data['email'],
        id = data['id'],
        photoUrl = data['photoUrl'],
        _idToken = data['idToken'] {
    assert(id != null);
  }

  // These error codes must match with ones declared on Android and iOS sides.

  /// Error code indicating there was a failed attempt to recover user authentication.
  static const String kFailedToRecoverAuthError = 'failed_to_recover_auth';

  /// Error indicating that authentication can be recovered with user action;
  static const String kUserRecoverableAuthError = 'user_recoverable_auth';

  @override
  final String displayName;

  @override
  final String email;

  @override
  final String id;

  @override
  final String photoUrl;

  final String _idToken;
  final GoogleSignIn _googleSignIn;

  /// Retrieve [GoogleSignInAuthentication] for this account.
  ///
  /// [shouldRecoverAuth] sets whether to attempt to recover authentication if
  /// user action is needed. If an attempt to recover authentication fails a
  /// [PlatformException] is thrown with possible error code
  /// [kFailedToRecoverAuthError].
  ///
  /// Otherwise, if [shouldRecoverAuth] is false and the authentication can be
  /// recovered by user action a [PlatformException] is thrown with error code
  /// [kUserRecoverableAuthError].
  Future<GoogleSignInAuthentication> get authentication async {
    if (_googleSignIn.currentUser != this) {
      throw StateError('User is no longer signed in.');
    }

    final Map<dynamic, dynamic> response =
        await GoogleSignIn.channel.invokeMethod(
      'getTokens',
      <String, dynamic>{
        'email': email,
        'shouldRecoverAuth': true,
      },
    );
    // On Android, there isn't an API for refreshing the idToken, so re-use
    // the one we obtained on login.
    if (response['idToken'] == null) {
      response['idToken'] = _idToken;
    }
    return GoogleSignInAuthentication._(response);
  }

  Future<Map<String, String>> get authHeaders async {
    final String token = (await authentication).accessToken;
    return <String, String>{
      "Authorization": "Bearer $token",
      "X-Goog-AuthUser": "0",
    };
  }

  /// Clears any client side cache that might be holding invalid tokens.
  ///
  /// If client runs into 401 errors using a token, it is expected to call
  /// this method and grab `authHeaders` once again.
  Future<void> clearAuthCache() async {
    final String token = (await authentication).accessToken;
    await GoogleSignIn.channel.invokeMethod(
      'clearAuthCache',
      <String, dynamic>{'token': token},
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! GoogleSignInAccount) return false;
    final GoogleSignInAccount otherAccount = other;
    return displayName == otherAccount.displayName &&
        email == otherAccount.email &&
        id == otherAccount.id &&
        photoUrl == otherAccount.photoUrl &&
        _idToken == otherAccount._idToken;
  }

  @override
  int get hashCode => hashValues(displayName, email, id, photoUrl, _idToken);

  @override
  String toString() {
    final Map<String, dynamic> data = <String, dynamic>{
      'displayName': displayName,
      'email': email,
      'id': id,
      'photoUrl': photoUrl,
    };
    return 'GoogleSignInAccount:$data';
  }
}

/// GoogleSignIn allows you to authenticate Google users.
class GoogleSignIn {
  /// Initializes global sign-in configuration settings.
  ///
  /// The [signInOption] determines the user experience. [SigninOption.games]
  /// must not be used on iOS.
  ///
  /// The list of [scopes] are OAuth scope codes to request when signing in.
  /// These scope codes will determine the level of data access that is granted
  /// to your application by the user. The full list of available scopes can
  /// be found here:
  /// <https://developers.google.com/identity/protocols/googlescopes>
  ///
  /// The [hostedDomain] argument specifies a hosted domain restriction. By
  /// setting this, sign in will be restricted to accounts of the user in the
  /// specified domain. By default, the list of accounts will not be restricted.
  GoogleSignIn({this.signInOption, this.scopes, this.hostedDomain});

  /// Factory for creating default sign in user experience.
  factory GoogleSignIn.standard({List<String> scopes, String hostedDomain}) {
    return GoogleSignIn(
        signInOption: SignInOption.standard,
        scopes: scopes,
        hostedDomain: hostedDomain);
  }

  /// Factory for creating sign in suitable for games. This option must not be
  /// used on iOS because the games API is not supported.
  factory GoogleSignIn.games() {
    return GoogleSignIn(signInOption: SignInOption.games);
  }

  // These error codes must match with ones declared on Android and iOS sides.

  /// Error code indicating there is no signed in user and interactive sign in
  /// flow is required.
  static const String kSignInRequiredError = 'sign_in_required';

  /// Error code indicating that interactive sign in process was canceled by the
  /// user.
  static const String kSignInCanceledError = 'sign_in_canceled';

  /// Error code indicating that attempt to sign in failed.
  static const String kSignInFailedError = 'sign_in_failed';

  /// The [MethodChannel] over which this class communicates.
  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('plugins.flutter.io/google_sign_in');

  /// Option to determine the sign in user experience. [SignInOption.games] must
  /// not be used on iOS.
  final SignInOption signInOption;

  /// The list of [scopes] are OAuth scope codes requested when signing in.
  final List<String> scopes;

  /// Domain to restrict sign-in to.
  final String hostedDomain;

  StreamController<GoogleSignInAccount> _currentUserController =
      StreamController<GoogleSignInAccount>.broadcast();

  /// Subscribe to this stream to be notified when the current user changes.
  Stream<GoogleSignInAccount> get onCurrentUserChanged =>
      _currentUserController.stream;

  // Future that completes when we've finished calling `init` on the native side
  Future<void> _initialization;

  Future<GoogleSignInAccount> _callMethod(String method) async {
    await _ensureInitialized();

    final Map<dynamic, dynamic> response = await channel.invokeMethod(method);
    return _setCurrentUser(response != null && response.isNotEmpty
        ? GoogleSignInAccount._(this, response)
        : null);
  }

  GoogleSignInAccount _setCurrentUser(GoogleSignInAccount currentUser) {
    if (currentUser != _currentUser) {
      _currentUser = currentUser;
      _currentUserController.add(_currentUser);
    }
    return _currentUser;
  }

  Future<void> _ensureInitialized() {
    if (_initialization == null) {
      _initialization = channel.invokeMethod('init', <String, dynamic>{
        'signInOption': (signInOption ?? SignInOption.standard).toString(),
        'scopes': scopes ?? <String>[],
        'hostedDomain': hostedDomain,
      })
        ..catchError((dynamic _) {
          // Invalidate initialization if it errored out.
          _initialization = null;
        });
    }
    return _initialization;
  }

  /// Keeps track of the most recently scheduled method call.
  _MethodCompleter _lastMethodCompleter;

  /// Adds call to [method] in a queue for execution.
  ///
  /// At most one in flight call is allowed to prevent concurrent (out of order)
  /// updates to [currentUser] and [onCurrentUserChanged].
  Future<GoogleSignInAccount> _addMethodCall(String method) {
    if (_lastMethodCompleter == null) {
      _lastMethodCompleter = _MethodCompleter(method)
        ..complete(_callMethod(method));
      return _lastMethodCompleter.future;
    }

    final _MethodCompleter completer = _MethodCompleter(method);
    _lastMethodCompleter.future.whenComplete(() {
      // If after the last completed call currentUser is not null and requested
      // method is a sign in method, re-use the same authenticated user
      // instead of making extra call to the native side.
      const List<String> kSignInMethods = <String>['signIn', 'signInSilently'];
      if (kSignInMethods.contains(method) && _currentUser != null) {
        completer.complete(_currentUser);
      } else {
        completer.complete(_callMethod(method));
      }
    }).catchError((dynamic _) {
      // Ignore if previous call completed with an error.
    });
    _lastMethodCompleter = completer;
    return _lastMethodCompleter.future;
  }

  /// The currently signed in account, or null if the user is signed out.
  GoogleSignInAccount get currentUser => _currentUser;
  GoogleSignInAccount _currentUser;

  /// Attempts to sign in a previously authenticated user without interaction.
  ///
  /// Returned Future resolves to an instance of [GoogleSignInAccount] for a
  /// successful sign in or `null` if there is no previously authenticated user.
  /// Use [signIn] method to trigger interactive sign in process.
  ///
  /// Authentication process is triggered only if there is no currently signed in
  /// user (that is when `currentUser == null`), otherwise this method returns
  /// a Future which resolves to the same user instance.
  ///
  /// Re-authentication can be triggered only after [signOut] or [disconnect].
  ///
  /// When [suppressErrors] is set to `false` and an error occurred during sign in
  /// returned Future completes with [PlatformException] whose `code` can be
  /// either [kSignInRequiredError] (when there is no authenticated user) or
  /// [kSignInFailedError] (when an unknown error occurred).
  Future<GoogleSignInAccount> signInSilently({bool suppressErrors = true}) {
    final Future<GoogleSignInAccount> result = _addMethodCall('signInSilently');
    if (suppressErrors) {
      return result.catchError((dynamic _) => null);
    }
    return result;
  }

  /// Returns a future that resolves to whether a user is currently signed in.
  Future<bool> isSignedIn() async {
    await _ensureInitialized();
    final bool result = await channel.invokeMethod('isSignedIn');
    return result;
  }

  /// Starts the interactive sign-in process.
  ///
  /// Returned Future resolves to an instance of [GoogleSignInAccount] for a
  /// successful sign in or `null` in case sign in process was aborted.
  ///
  /// Authentication process is triggered only if there is no currently signed in
  /// user (that is when `currentUser == null`), otherwise this method returns
  /// a Future which resolves to the same user instance.
  ///
  /// Re-authentication can be triggered only after [signOut] or [disconnect].
  Future<GoogleSignInAccount> signIn() {
    final Future<GoogleSignInAccount> result = _addMethodCall('signIn');
    bool isCanceled(dynamic error) =>
        error is PlatformException && error.code == kSignInCanceledError;
    return result.catchError((dynamic _) => null, test: isCanceled);
  }

  /// Marks current user as being in the signed out state.
  Future<GoogleSignInAccount> signOut() => _addMethodCall('signOut');

  /// Disconnects the current user from the app and revokes previous
  /// authentication.
  Future<GoogleSignInAccount> disconnect() => _addMethodCall('disconnect');
}

class _MethodCompleter {
  _MethodCompleter(this.method);

  final String method;
  final Completer<GoogleSignInAccount> _completer =
      Completer<GoogleSignInAccount>();

  void complete(FutureOr<GoogleSignInAccount> value) {
    if (value is Future<GoogleSignInAccount>) {
      value.then(_completer.complete, onError: _completer.completeError);
    } else {
      _completer.complete(value);
    }
  }

  bool get isCompleted => _completer.isCompleted;
  Future<GoogleSignInAccount> get future => _completer.future;
}
