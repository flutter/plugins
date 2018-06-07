// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

/// Represents user data returned from an identity provider.
class UserInfo {
  final Map<dynamic, dynamic> _data;

  UserInfo._(this._data);

  /// The provider identifier.
  String get providerId => _data['providerId'];

  /// The provider’s user ID for the user.
  String get uid => _data['uid'];

  /// The name of the user.
  String get displayName => _data['displayName'];

  /// The URL of the user’s profile photo.
  String get photoUrl => _data['photoUrl'];

  /// The user’s email address.
  String get email => _data['email'];

  /// The user's phone number.
  String get phoneNumber => _data['phoneNumber'];

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}

/// Represents user profile data that can be updated by [updateProfile]
/// The purpose of having separate class with a map is to give possibility
/// to check if value was set to null or not provided
class UserUpdateInfo {
  /// Container of data that will be send in update request
  final Map<String, String> _updateData = <String, String>{};

  set displayName(String displayName) =>
      _updateData["displayName"] = displayName;

  String get displayName => _updateData["displayName"];

  set photoUrl(String photoUri) => _updateData["photoUrl"] = photoUri;

  String get photoUrl => _updateData["photoUrl"];
}

/// Represents a user.
class FirebaseUser extends UserInfo {
  final List<UserInfo> providerData;

  FirebaseUser._(Map<dynamic, dynamic> data)
      : providerData = data['providerData']
            .map<UserInfo>((dynamic item) => new UserInfo._(item))
            .toList(),
        super._(data);

  // Returns true if the user is anonymous; that is, the user account was
  // created with signInAnonymously() and has not been linked to another
  // account.
  bool get isAnonymous => _data['isAnonymous'];

  /// Returns true if the user's email is verified.
  bool get isEmailVerified => _data['isEmailVerified'];

  /// Obtains the id token for the current user, forcing a [refresh] if desired.
  ///
  /// Completes with an error if the user is signed out.
  Future<String> getIdToken({bool refresh: false}) async {
    return await FirebaseAuth.channel.invokeMethod('getIdToken', <String, bool>{
      'refresh': refresh,
    });
  }

  Future<void> sendEmailVerification() async {
    await FirebaseAuth.channel.invokeMethod('sendEmailVerification');
  }

  /// Manually refreshes the data of the current user (for example, attached providers, display name, and so on).
  Future<void> reload() async {
    await FirebaseAuth.channel.invokeMethod('reload');
  }

  @override
  String toString() {
    return '$runtimeType($_data)';
  }
}

enum PhoneSignInError {
  INVALID_REQUEST,
  SMS_QUOTA_EXCEEDED,
  UNAUTHORIZED,
  API_NOT_AVAILABLE,
  NO_FOREGROUND_ACTIVITY
}

enum PhoneSignInEvent {
  /// Triggers when an SMS has been sent to the user's phone.
  CODE_SENT,

  /// Triggers when SMS auto-retrieval times out.
  ///
  /// Auto-verification by Google Play services could not be completed
  /// in the provided timeout.
  CODE_AUTO_RETRIEVAL_TIMEOUT
}

PhoneSignInEvent stringToPhoneSignInEventEnum(String event) {
  switch (event) {
    case 'CODE_SENT':
      return PhoneSignInEvent.CODE_SENT;
    case 'CODE_AUTO_RETRIEVAL_TIMEOUT':
      return PhoneSignInEvent.CODE_AUTO_RETRIEVAL_TIMEOUT;
    default:
      throw new ArgumentError('$event is not a valid PhoneSignInEventType.');
  }
}

PhoneSignInError stringToPhoneSignInErrorEnum(String error) {
  switch (error) {
    case "exception":
    case 'INVALID_REQUEST':
      return PhoneSignInError.INVALID_REQUEST;
    case 'SMS_QUOTA_EXCEEDED':
      return PhoneSignInError.SMS_QUOTA_EXCEEDED;
    case "UNAUTHORIZED":
      return PhoneSignInError.UNAUTHORIZED;
    case "API_NOT_AVAILABLE":
      return PhoneSignInError.API_NOT_AVAILABLE;
    case "NO_FOREGROUND_ACTIVITY":
      return PhoneSignInError.NO_FOREGROUND_ACTIVITY;
    default:
      throw new ArgumentError('$error is not a valid PhoneSignInError.');
  }
}

class FirebaseAuth {
  @visibleForTesting
  static const MethodChannel channel = const MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  static const EventChannel phoneSignInEventChannel =
      const EventChannel('plugins.flutter.io/firebase_auth_phone_sign_in');

  final Map<int, StreamController<FirebaseUser>> _authStateChangedControllers =
      <int, StreamController<FirebaseUser>>{};

  Stream<PhoneSignInEvent> _phoneSignInEventStream;

  /// Provides an instance of this class corresponding to the default app.
  ///
  /// TODO(jackson): Support for non-default apps.
  static FirebaseAuth instance = new FirebaseAuth._();

  FirebaseAuth._() {
    channel.setMethodCallHandler(_callHandler);
  }

  /// Receive [FirebaseUser] each time the user signIn or signOut
  Stream<FirebaseUser> get onAuthStateChanged {
    Future<int> _handle;

    StreamController<FirebaseUser> controller;
    controller = new StreamController<FirebaseUser>.broadcast(onListen: () {
      _handle = channel
          .invokeMethod('startListeningAuthState')
          .then<int>((dynamic v) => v);
      _handle.then((int handle) {
        _authStateChangedControllers[handle] = controller;
      });
    }, onCancel: () {
      _handle.then((int handle) async {
        await channel.invokeMethod(
            "stopListeningAuthState", <String, int>{"id": handle});
        _authStateChangedControllers.remove(handle);
      });
    });

    return controller.stream;
  }

  Stream<PhoneSignInEvent> get onPhoneSignInEvents {
    if (_phoneSignInEventStream == null) {
      _phoneSignInEventStream = phoneSignInEventChannel
          .receiveBroadcastStream()
          .map((dynamic event) => stringToPhoneSignInEventEnum(event));
    }
    return _phoneSignInEventStream;
  }

  /// Asynchronously creates and becomes an anonymous user.
  ///
  /// If there is already an anonymous user signed in, that user will be
  /// returned instead. If there is any other existing user signed in, that
  /// user will be signed out.
  ///
  /// Will throw a PlatformException if
  /// FIRAuthErrorCodeOperationNotAllowed - Indicates that anonymous accounts are not enabled. Enable them in the Auth section of the Firebase console.
  /// See FIRAuthErrors for a list of error codes that are common to all API methods.
  Future<FirebaseUser> signInAnonymously() async {
    final Map<dynamic, dynamic> data =
        await channel.invokeMethod('signInAnonymously');
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<FirebaseUser> createUserWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    assert(email != null);
    assert(password != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'createUserWithEmailAndPassword',
      <String, String>{
        'email': email,
        'password': password,
      },
    );
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<List<String>> fetchProvidersForEmail({
    @required String email,
  }) async {
    assert(email != null);
    final List<dynamic> providers = await channel.invokeMethod(
      'fetchProvidersForEmail',
      <String, String>{
        'email': email,
      },
    );
    return providers?.cast<String>();
  }

  Future<void> sendPasswordResetEmail({
    @required String email,
  }) async {
    assert(email != null);
    return await channel.invokeMethod(
      'sendPasswordResetEmail',
      <String, String>{
        'email': email,
      },
    );
  }

  Future<FirebaseUser> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    assert(email != null);
    assert(password != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'signInWithEmailAndPassword',
      <String, String>{
        'email': email,
        'password': password,
      },
    );
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<FirebaseUser> signInWithFacebook(
      {@required String accessToken}) async {
    assert(accessToken != null);
    final Map<dynamic, dynamic> data =
        await channel.invokeMethod('signInWithFacebook', <String, String>{
      'accessToken': accessToken,
    });
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  /// Signs in with a Twitter account using the specified credentials.
  ///
  /// The returned future completes with the signed-in user or a [PlatformException], if sign in failed.
  Future<FirebaseUser> signInWithTwitter({
    @required String authToken,
    @required String authTokenSecret,
  }) async {
    assert(authToken != null);
    assert(authTokenSecret != null);
    final Map<dynamic, dynamic> data =
        await channel.invokeMethod('signInWithTwitter', <String, String>{
      'authToken': authToken,
      'authTokenSecret': authTokenSecret,
    });
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<FirebaseUser> signInWithGoogle({
    @required String idToken,
    @required String accessToken,
  }) async {
    assert(idToken != null);
    assert(accessToken != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'signInWithGoogle',
      <String, String>{
        'idToken': idToken,
        'accessToken': accessToken,
      },
    );
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<FirebaseUser> signInWithCustomToken({@required String token}) async {
    assert(token != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'signInWithCustomToken',
      <String, String>{
        'token': token,
      },
    );
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  /// Signs in a user by sending a verification code to the user's [phoneNumber].
  ///
  /// The [timeout] is the maximum amount of time in seconds you are willing
  /// to wait for SMS auto-retrieval to be completed.
  /// Maximum allowed value is 2 minutes. Use 0 to disable SMS-auto-retrieval.
  /// If you specify a positive value less than 30 seconds,
  /// it'll default to 30 seconds.
  ///
  /// To start the authentication process call [signInWithPhoneNumber].
  /// The call only returns when the user has been successfully authenticated or
  /// when an error occurs.
  ///
  /// Successful authentication can happen using different means:
  /// - Instant verification. In some cases the phone number can be instantly
  ///   verified without needing to send or enter a verification code.
  /// - Auto-retrieval. On some devices Google Play services can automatically
  ///   detect the incoming verification SMS and perform verification without
  ///   user action.
  /// - User entered verification code. Call [verifyPhoneNumber] to validate the
  /// user's phone number using the verification code.
  /// If the verification code needs to be resent call [resendVerificationCode].
  ///
  /// When the code sent to the user is automatically verified by
  /// Google Play services, the call to [signInWithPhoneNumber] returns
  /// successfully and the user doesn't need to manually enter it.
  /// (the view to enter the verification code should be hidden from the user)
  ///
  /// If the authentication requires sending a verification code, you must
  /// subscribe to an event stream: `StreamSubscription<PhoneSignInEvent>` to be
  /// notified when the code has been sent to allow the user to enter it.
  /// (if not already verified by Google Play services in the meantime)
  ///
  /// For example:
  /// ```dart
  /// class PhoneNumberSignInPage extends StatefulWidget {
  ///   const PhoneNumberSignInPage({Key key}) : super(key: key);
  ///
  ///   @override
  ///   _PhoneNumberSignInPageState createState() =>
  ///     new _PhoneNumberSignInPageState();
  ///   }
  /// }
  ///
  /// class _PhoneNumberSignInPageState extends State<PhoneNumberSignInPage> {
  ///   StreamSubscription<PhoneSignInEvent> _phoneSignInEventSubscription;
  ///
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     _phoneSignInEventSubscription =
  ///       _auth.onPhoneSignInEvents.listen((PhoneSignInEvent phoneSignInEvent) {
  ///         switch (phoneSignInEvent) {
  ///           case PhoneSignInEvent.CODE_SENT:
  ///             print("[UI] Code sent event - Display view to let the user enter it");
  ///             break;
  ///
  ///           case PhoneSignInEvent.CODE_AUTO_RETRIEVAL_TIMEOUT:
  ///             print("[UI] Code auto retrieval timeout event");
  ///             break;
  ///         }
  ///       });
  ///   }
  ///
  ///   @override
  ///   void dispose() {
  ///     super.dispose();
  ///     if (_phoneSignInEventSubscription != null) {
  ///       _phoneSignInEventSubscription.cancel();
  ///     }
  ///  }
  /// ```
  ///
  /// Throws [PlatformException] when
  /// 1. There is no foreground activity.
  /// 2. When the phone number or the verification code is invalid.
  /// 3. The SMS quota for the project has been exceeded.
  /// 4. The app is not authorized to use Firebase Authentication.
  /// 5. No Google Play Services installed on the device.
  Future<FirebaseUser> signInWithPhoneNumber(
      {@required String phoneNumber, int timeout = 60}) async {
    assert(phoneNumber != null && phoneNumber.isNotEmpty);
    assert(timeout >= 0);
    final Map<String, dynamic> data = await channel.invokeMethod(
        'signInWithPhoneNumber',
        <String, dynamic>{'phoneNumber': phoneNumber, 'timeout': timeout});
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  /// Verify the authenticity of the phone number using the provided [code].
  Future<FirebaseUser> verifyPhoneNumber({@required String code}) async {
    assert(code != null && code.isNotEmpty);
    final Map<String, dynamic> data = await channel
        .invokeMethod('verifyPhoneNumber', <String, String>{'code': code});
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  /// Resend the verification code for the provided [phoneNumber].
  Future<FirebaseUser> resendVerificationCode(
      {@required String phoneNumber, int timeout = 60}) async {
    assert(phoneNumber != null && phoneNumber.isNotEmpty);
    assert(timeout >= 0);
    final Map<String, dynamic> data = await channel.invokeMethod(
        'resendVerificationCode',
        <String, dynamic>{'phoneNumber': phoneNumber, 'timeout': timeout});
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<Null> signOut() async {
    return await channel.invokeMethod("signOut");
  }

  /// Asynchronously gets current user, or `null` if there is none.
  Future<FirebaseUser> currentUser() async {
    final Map<dynamic, dynamic> data =
        await channel.invokeMethod("currentUser");
    final FirebaseUser currentUser =
        data == null ? null : new FirebaseUser._(data);
    return currentUser;
  }

  /// Links email account with current user and returns [Future<FirebaseUser>]
  /// basically current user with additional email information
  ///
  /// throws [PlatformException] when
  /// 1. email address is already used
  /// 2. wrong email and password provided
  Future<FirebaseUser> linkWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    assert(email != null);
    assert(password != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'linkWithEmailAndPassword',
      <String, String>{
        'email': email,
        'password': password,
      },
    );
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<void> updateProfile(UserUpdateInfo userUpdateInfo) async {
    assert(userUpdateInfo != null);
    return await channel.invokeMethod(
      'updateProfile',
      userUpdateInfo._updateData,
    );
  }

  /// Links google account with current user and returns [Future<FirebaseUser>]
  ///
  /// throws [PlatformException] when
  /// 1. No current user provided (user has not logged in)
  /// 2. No google credentials were found for given [idToken] and [accessToken]
  /// 3. Google account already linked with another [FirebaseUser]
  /// Detailed documentation on possible error causes can be found in [Android docs](https://firebase.google.com/docs/reference/android/com/google/firebase/auth/FirebaseUser#exceptions_4) and [iOS docs](https://firebase.google.com/docs/reference/ios/firebaseauth/api/reference/Classes/FIRUser#/c:objc(cs)FIRUser(im)linkWithCredential:completion:)
  /// TODO: Throw custom exceptions with error codes indicating cause of exception
  Future<FirebaseUser> linkWithGoogleCredential({
    @required String idToken,
    @required String accessToken,
  }) async {
    assert(idToken != null);
    assert(accessToken != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'linkWithGoogleCredential',
      <String, String>{
        'idToken': idToken,
        'accessToken': accessToken,
      },
    );
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<FirebaseUser> linkWithFacebookCredential({
    @required String accessToken,
  }) async {
    assert(accessToken != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'linkWithFacebookCredential',
      <String, String>{
        'accessToken': accessToken,
      },
    );
    final FirebaseUser currentUser = new FirebaseUser._(data);
    return currentUser;
  }

  Future<Null> _callHandler(MethodCall call) async {
    switch (call.method) {
      case "onAuthStateChanged":
        _onAuthStageChangedHandler(call);
        break;
    }
    return null;
  }

  void _onAuthStageChangedHandler(MethodCall call) {
    final Map<dynamic, dynamic> data = call.arguments["user"];
    final int id = call.arguments["id"];

    final FirebaseUser currentUser =
        data != null ? new FirebaseUser._(data) : null;
    _authStateChangedControllers[id].add(currentUser);
  }
}
