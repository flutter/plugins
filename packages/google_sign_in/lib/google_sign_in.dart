// Copyright 2017, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart' show MethodChannel;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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

class GoogleSignInAccount {
  final String displayName;
  final String email;
  final String id;
  final String photoUrl;
  final String _idToken;
  final GoogleSignIn _googleSignIn;

  GoogleSignInAccount._(this._googleSignIn, Map<String, dynamic> data)
      : displayName = data['displayName'],
        email = data['email'],
        id = data['id'],
        photoUrl = data['photoUrl'],
        _idToken = data['idToken'] {
    assert(displayName != null);
    assert(id != null);
  }


  Future<GoogleSignInAuthentication> get authentication async {
    if (_googleSignIn.currentUser != this) {
      throw new StateError('User is no longer signed in.');
    }

    Map<String, String> response = await _googleSignIn._channel.invokeMethod(
      'getTokens',
      <String, dynamic>{'email': email},
    );
    // On Android, there isn't an API for refreshing the idToken, so re-use
    // the one we obtained on login.
    if (response['idToken'] == null)
      response['idToken'] = _idToken;
    return new GoogleSignInAuthentication._(response);
  }

  Future<Map<String, String>> get authHeaders async {
    String token = (await authentication).accessToken;
    return <String, String>{
      "Authorization": "Bearer $token",
      "X-Goog-AuthUser": "0",
    };
  }

  @override
  String toString() {
    Map<String, dynamic> data = <String, dynamic>{
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
  final MethodChannel _channel;

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
  GoogleSignIn({ this.scopes, this.hostedDomain })
    : _channel = const MethodChannel('plugins.flutter.io/google_sign_in');

  @visibleForTesting
  GoogleSignIn.private({ this.scopes, this.hostedDomain, MethodChannel channel })
    : _channel = channel;

  StreamController<GoogleSignInAccount> _streamController =
  new StreamController<GoogleSignInAccount>.broadcast();

  /// Subscribe to this stream to be notified when the current user changes
  Stream<GoogleSignInAccount> get onCurrentUserChanged =>
  _streamController.stream;

  // Future that completes when we've finished calling init on the native side
  Future<Null> _initialization;

  Future<GoogleSignInAccount> _callMethod(String method) async {
    if (_initialization == null) {
      _initialization = _channel.invokeMethod(
        "init",
        <String, dynamic>{
          'scopes': scopes ?? [],
          'hostedDomain': hostedDomain,
        },
      );
    }
    await _initialization;
    Map<String, dynamic> response = await _channel.invokeMethod(method);
    _currentUser = (response != null && response.isNotEmpty)
        ? new GoogleSignInAccount._(this, response) : null;
    _streamController.add(_currentUser);
    return _currentUser;
  }

  /// The currently signed in account, or null if the user is signed out
  GoogleSignInAccount _currentUser;
  GoogleSignInAccount get currentUser => _currentUser;

  /// Attempts to sign in a previously authenticated user without interaction.
  ///
  /// If there is already a signed-in user, returns it.
  Future<GoogleSignInAccount> signInSilently() async => _currentUser ?? _callMethod('signInSilently');

  /// Starts the sign-in process.
  ///
  /// If there is already a signed-in user, returns it.
  Future<GoogleSignInAccount> signIn() async => _currentUser ?? _callMethod('signIn');

  /// Marks current user as being in the signed out state.
  Future<GoogleSignInAccount> signOut() => _callMethod('signOut');

  /// Disconnects the current user from the app and revokes previous
  /// authentication.
  Future<GoogleSignInAccount> disconnect() => _callMethod('disconnect');
}

/// Builds a CircleAvatar profile image of the appropriate resolution
class GoogleUserCircleAvatar extends StatelessWidget {
  const GoogleUserCircleAvatar(this._primaryProfileImageUrl);
  final String _primaryProfileImageUrl;

  Widget build(BuildContext context) {
    return new CircleAvatar(
      child: new LayoutBuilder(builder: _buildClippedImage),
    );
  }

  /// Adds sizing information to the URL, inserted as the last
  /// directory before the image filename. The format is "/sNN-c/",
  /// where NN is the max width/height of the image, and "c" indicates we
  /// want the image cropped.
  String _sizedProfileImageUrl(double size) {
    if (_primaryProfileImageUrl == null) return null;
    Uri profileUri = Uri.parse(_primaryProfileImageUrl);
    List<String> pathSegments = new List<String>.from(profileUri.pathSegments);
    pathSegments.remove("s1337"); // placeholder value added by iOS plugin
    return new Uri(
      scheme: profileUri.scheme,
      host: profileUri.host,
      pathSegments: pathSegments,
      query: "sz=${size.round()}",
    ).toString();
  }

  Widget _buildClippedImage(BuildContext context, BoxConstraints constraints) {
    assert(constraints.maxWidth == constraints.maxHeight);
    String url = _sizedProfileImageUrl(
      MediaQuery.of(context).devicePixelRatio * constraints.maxWidth,
    );
    if (url == null)
      return new Container();
    return new ClipOval(
      child: new Image(
        image: new NetworkImage(url),
      ),
    );
  }
}
