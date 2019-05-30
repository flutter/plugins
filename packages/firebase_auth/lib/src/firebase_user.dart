// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

/// Represents a user.
class FirebaseUser extends UserInfo {
  FirebaseUser._(Map<String, dynamic> data, FirebaseApp app)
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
  /// Useful when authenticating against your own backend. Use our server
  /// SDKs or follow the official documentation to securely verify the
  /// integrity and validity of this token.
  ///
  /// Completes with an error if the user is signed out.
  Future<String> getIdToken({bool refresh = false}) async {
    return await FirebaseAuth.channel
        .invokeMethod<String>('getIdToken', <String, dynamic>{
      'refresh': refresh,
      'app': _app.name,
    });
  }

  /// Associates a user account from a third-party identity provider with this
  /// user and returns additional identity provider data.
  ///
  /// This allows the user to sign in to this account in the future with
  /// the given account.
  ///
  /// Errors:
  ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///   • `ERROR_INVALID_CREDENTIAL` - If the credential is malformed or has expired.
  ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  ///   • `ERROR_CREDENTIAL_ALREADY_IN_USE` - If the account is already in use by a different account, e.g. with phone auth.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///   • `ERROR_PROVIDER_ALREADY_LINKED` - If the current user already has an account of this type linked.
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that this type of account is not enabled.
  ///   • `ERROR_INVALID_ACTION_CODE` - If the action code in the link is malformed, expired, or has already been used.
  ///       This can only occur when using [EmailAuthProvider.getCredentialWithLink] to obtain the credential.
  Future<FirebaseUser> linkWithCredential(AuthCredential credential) async {
    assert(credential != null);
    final Map<String, dynamic> data =
        await FirebaseAuth.channel.invokeMapMethod<String, dynamic>(
      'linkWithCredential',
      <String, dynamic>{
        'app': _app.name,
        'provider': credential._provider,
        'data': credential._data,
      },
    );
    final FirebaseUser currentUser = FirebaseUser._(data, _app);
    return currentUser;
  }

  /// Initiates email verification for the user.
  Future<void> sendEmailVerification() async {
    await FirebaseAuth.channel.invokeMethod<void>(
        'sendEmailVerification', <String, String>{'app': _app.name});
  }

  /// Manually refreshes the data of the current user (for example,
  /// attached providers, display name, and so on).
  Future<void> reload() async {
    await FirebaseAuth.channel
        .invokeMethod<void>('reload', <String, String>{'app': _app.name});
  }

  /// Deletes the user record from your Firebase project's database.
  Future<void> delete() async {
    await FirebaseAuth.channel
        .invokeMethod<void>('delete', <String, String>{'app': _app.name});
  }

  /// Updates the email address of the user.
  ///
  /// The original email address recipient will receive an email that allows
  /// them to revoke the email address change, in order to protect them
  /// from account hijacking.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_CREDENTIAL` - If the email address is malformed.
  ///   • `ERROR_EMAIL_ALREADY_IN_USE` - If the email is already in use by a different account.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<void> updateEmail(String email) async {
    assert(email != null);
    return await FirebaseAuth.channel.invokeMethod<void>(
      'updateEmail',
      <String, String>{'email': email, 'app': _app.name},
    );
  }

  /// Updates the phone number of the user.
  ///
  /// The new phone number credential corresponding to the phone number
  /// to be added to the Firebase account, if a phone number is already linked to the account.
  /// this new phone number will replace it.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  Future<void> updatePhoneNumberCredential(AuthCredential credential) async {
    assert(credential != null);
    await FirebaseAuth.channel.invokeMethod<void>(
      'updatePhoneNumberCredential',
      <String, dynamic>{
        'app': _app.name,
        'provider': credential._provider,
        'data': credential._data,
      },
    );
  }

  /// Updates the password of the user.
  ///
  /// Anonymous users who update both their email and password will no
  /// longer be anonymous. They will be able to log in with these credentials.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Errors:
  ///   • `ERROR_WEAK_PASSWORD` - If the password is not strong enough.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<void> updatePassword(String password) async {
    assert(password != null);
    return await FirebaseAuth.channel.invokeMethod<void>(
      'updatePassword',
      <String, String>{'password': password, 'app': _app.name},
    );
  }

  /// Updates the user profile information.
  ///
  /// Errors:
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  Future<void> updateProfile(UserUpdateInfo userUpdateInfo) async {
    assert(userUpdateInfo != null);
    final Map<String, String> data = userUpdateInfo._updateData;
    data['app'] = _app.name;
    return await FirebaseAuth.channel.invokeMethod<void>(
      'updateProfile',
      data,
    );
  }

  /// Renews the user’s authentication tokens by validating a fresh set of
  /// [credential]s supplied by the user and returns additional identity provider
  /// data.
  ///
  /// This is used to prevent or resolve `ERROR_REQUIRES_RECENT_LOGIN`
  /// response to operations that require a recent sign-in.
  ///
  /// If the user associated with the supplied credential is different from the
  /// current user, or if the validation of the supplied credentials fails; an
  /// error is returned and the current user remains signed in.
  ///
  /// Errors:
  ///   • `ERROR_INVALID_CREDENTIAL` - If the [authToken] or [authTokenSecret] is malformed or has expired.
  ///   • `ERROR_USER_DISABLED` - If the user has been disabled (for example, in the Firebase console)
  ///   • `ERROR_USER_NOT_FOUND` - If the user has been deleted (for example, in the Firebase console)
  ///   • `ERROR_OPERATION_NOT_ALLOWED` - Indicates that Email & Password accounts are not enabled.
  Future<FirebaseUser> reauthenticateWithCredential(
      AuthCredential credential) async {
    assert(credential != null);
    await FirebaseAuth.channel.invokeMethod<void>(
      'reauthenticateWithCredential',
      <String, dynamic>{
        'app': _app.name,
        'provider': credential._provider,
        'data': credential._data,
      },
    );
    return this;
  }

  /// Detaches the [provider] account from the current user.
  ///
  /// This will prevent the user from signing in to this account with those
  /// credentials.
  ///
  /// **Important**: This is a security sensitive operation that requires
  /// the user to have recently signed in.
  ///
  /// Use the `providerId` method of an auth provider for [provider].
  ///
  /// Errors:
  ///   • `ERROR_NO_SUCH_PROVIDER` - If the user does not have a Github Account linked to their account.
  ///   • `ERROR_REQUIRES_RECENT_LOGIN` - If the user's last sign-in time does not meet the security threshold. Use reauthenticate methods to resolve.
  Future<void> unlinkFromProvider(String provider) async {
    assert(provider != null);
    return await FirebaseAuth.channel.invokeMethod<void>(
      'unlinkFromProvider',
      <String, String>{'provider': provider, 'app': _app.name},
    );
  }

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}
