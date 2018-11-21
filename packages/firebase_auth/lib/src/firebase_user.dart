// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Represents a user.
class FirebaseUser extends UserInfo {
  FirebaseUser._(Map<dynamic, dynamic> data, FirebaseApp app)
      : providerData = data['providerData']
            .map<UserInfo>((dynamic item) => UserInfo._(item, app))
            .toList(),
        _metadata = FirebaseUserMetadata._(data),
        super._(data, app);

  final List<UserInfo> providerData;
  final FirebaseUserMetadata _metadata;

  // Returns true if the user is anonymous; that is, the user account was
  // created with signInAnonymously() and has not been linked to another
  // account.
  FirebaseUserMetadata get metadata => _metadata;

  bool get isAnonymous => _data['isAnonymous'];

  /// Returns true if the user's email is verified.
  bool get isEmailVerified => _data['isEmailVerified'];

  /// Obtains the id token for the current user, forcing a [refresh] if desired.
  ///
  /// Completes with an error if the user is signed out.
  Future<String> getIdToken({bool refresh = false}) async {
    return await FirebaseAuth.channel
        .invokeMethod('getIdToken', <String, dynamic>{
      'refresh': refresh,
      'app': _app.name,
    });
  }

  Future<void> sendEmailVerification() async {
    await FirebaseAuth.channel.invokeMethod(
        'sendEmailVerification', <String, String>{'app': _app.name});
  }

  /// Manually refreshes the data of the current user (for example, attached providers, display name, and so on).
  Future<void> reload() async {
    await FirebaseAuth.channel
        .invokeMethod('reload', <String, String>{'app': _app.name});
  }

  /// Deletes the user record from your Firebase project's database.
  Future<void> delete() async {
    await FirebaseAuth.channel
        .invokeMethod('delete', <String, String>{'app': _app.name});
  }

  /// Updates the email address of the user.
  Future<void> updateEmail(String email) async {
    assert(email != null);
    return await FirebaseAuth.channel.invokeMethod(
      'updateEmail',
      <String, String>{'email': email, 'app': _app.name},
    );
  }

  /// Updates the password of the user.
  Future<void> updatePassword(String password) async {
    assert(password != null);
    return await FirebaseAuth.channel.invokeMethod(
      'updatePassword',
      <String, String>{'password': password, 'app': _app.name},
    );
  }

  /// Updates the user profile information.
  Future<void> updateProfile(UserUpdateInfo userUpdateInfo) async {
    assert(userUpdateInfo != null);
    final Map<String, String> data = userUpdateInfo._updateData;
    data['app'] = _app.name;
    return await FirebaseAuth.channel.invokeMethod(
      'updateProfile',
      data,
    );
  }

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}
