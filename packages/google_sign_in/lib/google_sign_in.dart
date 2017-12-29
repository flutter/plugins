// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:ui' show hashValues;

import 'package:flutter/services.dart' show MethodChannel;
import 'package:meta/meta.dart' show visibleForTesting;

import 'src/common.dart';

export 'src/common.dart';
export 'widgets.dart';

class GoogleSignInAuthentication {
  final Map<String, String> _data;

  GoogleSignInAuthentication._(this._data);

  /// An OpenID Connect ID token that identifies the user.
  String get idToken => _data['idToken'];

  /// The OAuth2 access token to access Google services.
  String get accessToken => _data['accessToken'];

  @override
  String toString() => 'GoogleSignInAuthentication:$_data';
}

class GoogleSignInAccount implements GoogleIdentity {
  GoogleSignInAccount._(this._googleSignIn, Map<String, dynamic> data)
      : displayName = data['displayName'],
        email = data['email'],
        id = data['id'],
        photoUrl = data['photoUrl'],
        _idToken = data['idToken'] {
    assert(displayName != null);
    assert(id != null);
  }

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

  Future<GoogleSignInAuthentication> get authentication async {
    if (_googleSignIn.currentUser != this) {
      throw new StateError('User is no longer signed in.');
    }

    final Map<String, String> response =
        await GoogleSignIn.channel.invokeMethod(
      'getTokens',
      <String, dynamic>{'email': email},
    );
    // On Android, there isn't an API for refreshing the idToken, so re-use
    // the one we obtained on login.
    if (response['idToken'] == null) {
      response['idToken'] = _idToken;
    }
    return new GoogleSignInAuthentication._(response);
  }

  Future<Map<String, String>> get authHeaders async {
    final String token = (await authentication).accessToken;
    return <String, String>{
      "Authorization": "Bearer $token",
      "X-Goog-AuthUser": "0",
    };
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
  /// The [MethodChannel] over which this class communicates.
  @visibleForTesting
  static const MethodChannel channel =
      const MethodChannel('plugins.flutter.io/google_sign_in');

  /// The list of [scopes] are OAuth scope codes requested when signing in.
  final List<String> scopes;

  /// Domain to restrict sign-in to.
  final String hostedDomain;

  /// Initializes global sign-in configuration settings.
  ///
  /// The list of [scopes] are OAuth scope codes to request when signing in.
  /// These scope codes will determine the level of data access that is granted
  /// to your application by the user.
  ///
  /// The [hostedDomain] argument specifies a hosted domain restriction. By
  /// setting this, sign in will be restricted to accounts of the user in the
  /// specified domain. By default, the list of accounts will not be restricted.
  GoogleSignIn({this.scopes, this.hostedDomain});

  StreamController<GoogleSignInAccount> _currentUserController =
      new StreamController<GoogleSignInAccount>.broadcast();

  /// Subscribe to this stream to be notified when the current user changes.
  Stream<GoogleSignInAccount> get onCurrentUserChanged =>
      _currentUserController.stream;

  // Future that completes when we've finished calling `init` on the native side
  Future<Null> _initialization;

  Future<GoogleSignInAccount> _callMethod(String method) async {
    if (_initialization == null) {
      _initialization = channel.invokeMethod("init", <String, dynamic>{
        'scopes': scopes ?? <String>[],
        'hostedDomain': hostedDomain,
      })
        ..catchError((dynamic _) {
          // Invalidate initialization if it errored out.
          _initialization = null;
        });
    }
    await _initialization;
    final Map<String, dynamic> response = await channel.invokeMethod(method);
    return _setCurrentUser(response != null && response.isNotEmpty
        ? new GoogleSignInAccount._(this, response)
        : null);
  }

  GoogleSignInAccount _setCurrentUser(GoogleSignInAccount currentUser) {
    if (currentUser != _currentUser) {
      _currentUser = currentUser;
      _currentUserController.add(_currentUser);
    }
    return _currentUser;
  }

  /// Keeps track of the most recently scheduled method call.
  _MethodCompleter _lastMethodCompleter;

  /// Adds call to [method] in a queue for execution.
  ///
  /// At most one in flight call is allowed to prevent concurrent (out of order)
  /// updates to [currentUser] and [onCurrentUserChanged].
  Future<GoogleSignInAccount> _addMethodCall(String method) {
    if (_lastMethodCompleter == null) {
      _lastMethodCompleter = new _MethodCompleter(method)
        ..complete(_callMethod(method));
      return _lastMethodCompleter.future;
    }

    final _MethodCompleter completer = new _MethodCompleter(method);
    _lastMethodCompleter.future.whenComplete(() {
      // If after the last completed call currentUser is not null and requested
      // method is a sign in method, re-use the same authenticated user
      // instead of making extra call to the native side.
      const List<String> kSignInMethods = const <String>[
        'signIn',
        'signInSilently'
      ];
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
  Future<GoogleSignInAccount> signInSilently() {
    return _addMethodCall('signInSilently').catchError((dynamic _) {
      // ignore, we promised to be silent.
      // TODO(goderbauer): revisit when the native side throws less aggressively.
    });
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
  Future<GoogleSignInAccount> signIn() => _addMethodCall('signIn');

  /// Marks current user as being in the signed out state.
  Future<GoogleSignInAccount> signOut() => _addMethodCall('signOut');

  /// Disconnects the current user from the app and revokes previous
  /// authentication.
  Future<GoogleSignInAccount> disconnect() => _addMethodCall('disconnect');
}

class _MethodCompleter {
  final String method;
  final Completer<GoogleSignInAccount> _completer =
      new Completer<GoogleSignInAccount>();

  _MethodCompleter(this.method);

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
