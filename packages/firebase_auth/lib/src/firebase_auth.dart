// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth;

typedef void PhoneVerificationCompleted(FirebaseUser firebaseUser);
typedef void PhoneVerificationFailed(AuthException error);
typedef void PhoneCodeSent(String verificationId, [int forceResendingToken]);
typedef void PhoneCodeAutoRetrievalTimeout(String verificationId);

/// The entry point of the Firebase Authentication SDK.
class FirebaseAuth {
  FirebaseAuth._(this.app) {
    channel.setMethodCallHandler(_callHandler);
  }

  /// Provides an instance of this class corresponding to `app`.
  factory FirebaseAuth.fromApp(FirebaseApp app) {
    assert(app != null);
    return FirebaseAuth._(app);
  }

  /// Provides an instance of this class corresponding to the default app.
  static final FirebaseAuth instance = FirebaseAuth._(FirebaseApp.instance);

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  final Map<int, StreamController<FirebaseUser>> _authStateChangedControllers =
      <int, StreamController<FirebaseUser>>{};

  static int nextHandle = 0;
  final Map<int, Map<String, dynamic>> _phoneAuthCallbacks =
      <int, Map<String, dynamic>>{};

  final FirebaseApp app;

  /// Receive [FirebaseUser] each time the user signIn or signOut
  Stream<FirebaseUser> get onAuthStateChanged {
    Future<int> _handle;

    StreamController<FirebaseUser> controller;
    controller = StreamController<FirebaseUser>.broadcast(onListen: () {
      _handle = channel.invokeMethod('startListeningAuthState',
          <String, String>{"app": app.name}).then<int>((dynamic v) => v);
      _handle.then((int handle) {
        _authStateChangedControllers[handle] = controller;
      });
    }, onCancel: () {
      _handle.then((int handle) async {
        await channel.invokeMethod("stopListeningAuthState",
            <String, dynamic>{"id": handle, "app": app.name});
        _authStateChangedControllers.remove(handle);
      });
    });

    return controller.stream;
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
    final Map<dynamic, dynamic> data = await channel
        .invokeMethod('signInAnonymously', <String, String>{"app": app.name});
    final FirebaseUser currentUser = FirebaseUser._(data, app);
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
      <String, String>{'email': email, 'password': password, 'app': app.name},
    );
    final FirebaseUser currentUser = FirebaseUser._(data, app);
    return currentUser;
  }

  Future<List<String>> fetchProvidersForEmail({
    @required String email,
  }) async {
    assert(email != null);
    final List<dynamic> providers = await channel.invokeMethod(
      'fetchProvidersForEmail',
      <String, String>{'email': email, 'app': app.name},
    );
    return providers?.cast<String>();
  }

  Future<void> sendPasswordResetEmail({
    @required String email,
  }) async {
    assert(email != null);
    return await channel.invokeMethod(
      'sendPasswordResetEmail',
      <String, String>{'email': email, 'app': app.name},
    );
  }

  Future<FirebaseUser> signInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) {
    assert(email != null);
    assert(password != null);
    return signInAndRetrieveData(
      credential: EmailAuthProvider.getCredential(
        email: email,
        password: password,
     ),
    );
  }

  /// Asynchronously signs in to Firebase with the given 3rd-party credentials
  /// (e.g. a Facebook login Access Token, a Google ID Token/Access Token pair,
  /// etc.) and returns additional identity provider data.
  Future<FirebaseUser> signInAndRetrieveData({
    @required AuthCredential credential
  }) async {
    assert(credential != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'signInAndRetrieveData',
      Map<String, String>.from(credential._data)..addAll(
        <String, String>{ 'app': app.name },
      ),
    );
    final FirebaseUser currentUser = FirebaseUser._(data, app);
    return currentUser;
  }

  /// Associates a user account from a third-party identity provider with this
  /// user and returns additional identity provider data.
  ///
  /// throws [PlatformException] when
  /// 1. No current user provided (user has not logged in)
  /// 2. Invalid auth credential
  /// 3. Credential already linked to another [FirebaseUser]
  Future<FirebaseUser> linkAndRetrieveData({
    @required AuthCredential credential,
  }) async {
    assert(credential != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'linkAndRetrieveData',
      Map<String, String>.from(credential._data)..addAll(
        <String, String>{ 'app': app.name },
      ),
    );
    final FirebaseUser currentUser = FirebaseUser._(data, app);
    return currentUser;
  }

  Future<void> verifyPhoneNumber({
    @required String phoneNumber,
    @required Duration timeout,
    int forceResendingToken,
    @required PhoneVerificationCompleted verificationCompleted,
    @required PhoneVerificationFailed verificationFailed,
    @required PhoneCodeSent codeSent,
    @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) async {
    final Map<String, dynamic> callbacks = <String, dynamic>{
      'PhoneVerificationCompleted': verificationCompleted,
      'PhoneVerificationFailed': verificationFailed,
      'PhoneCodeSent': codeSent,
      'PhoneCodeAuthRetrievalTimeout': codeAutoRetrievalTimeout,
    };
    nextHandle += 1;
    _phoneAuthCallbacks[nextHandle] = callbacks;

    final Map<String, dynamic> params = <String, dynamic>{
      'handle': nextHandle,
      'phoneNumber': phoneNumber,
      'timeout': timeout.inMilliseconds,
      'forceResendingToken': forceResendingToken,
      'app': app.name
    };

    await channel.invokeMethod('verifyPhoneNumber', params);
  }

  Future<FirebaseUser> signInWithCustomToken({@required String token}) async {
    assert(token != null);
    final Map<dynamic, dynamic> data = await channel.invokeMethod(
      'signInWithCustomToken',
      <String, String>{'token': token, 'app': app.name},
    );
    final FirebaseUser currentUser = FirebaseUser._(data, app);
    return currentUser;
  }

  Future<void> signOut() async {
    return await channel
        .invokeMethod("signOut", <String, String>{'app': app.name});
  }

  /// Asynchronously gets current user, or `null` if there is none.
  Future<FirebaseUser> currentUser() async {
    final Map<dynamic, dynamic> data = await channel
        .invokeMethod("currentUser", <String, String>{'app': app.name});
    final FirebaseUser currentUser =
        data == null ? null : FirebaseUser._(data, app);
    return currentUser;
  }

  /// Sets the user-facing language code for auth operations that can be
  /// internationalized, such as [sendEmailVerification]. This language
  /// code should follow the conventions defined by the IETF in BCP47.
  Future<void> setLanguageCode(String language) async {
    assert(language != null);
    await FirebaseAuth.channel.invokeMethod('setLanguageCode', <String, String>{
      'language': language,
      'app': app.name,
    });
  }

  Future<dynamic> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'onAuthStateChanged':
        _onAuthStageChangedHandler(call);
        break;
      case 'phoneVerificationCompleted':
        final int handle = call.arguments['handle'];
        final PhoneVerificationCompleted verificationCompleted =
            _phoneAuthCallbacks[handle]['PhoneVerificationCompleted'];
        verificationCompleted(await currentUser());
        break;
      case 'phoneVerificationFailed':
        final int handle = call.arguments['handle'];
        final PhoneVerificationFailed verificationFailed =
            _phoneAuthCallbacks[handle]['PhoneVerificationFailed'];
        final Map<dynamic, dynamic> exception = call.arguments['exception'];
        verificationFailed(
            AuthException(exception['code'], exception['message']));
        break;
      case 'phoneCodeSent':
        final int handle = call.arguments['handle'];
        final String verificationId = call.arguments['verificationId'];
        final int forceResendingToken = call.arguments['forceResendingToken'];

        final PhoneCodeSent codeSent =
            _phoneAuthCallbacks[handle]['PhoneCodeSent'];
        if (forceResendingToken == null) {
          codeSent(verificationId);
        } else {
          codeSent(verificationId, forceResendingToken);
        }
        break;
      case 'phoneCodeAutoRetrievalTimeout':
        final int handle = call.arguments['handle'];
        final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
            _phoneAuthCallbacks[handle]['PhoneCodeAutoRetrievealTimeout'];
        final String verificationId = call.arguments['verificationId'];
        codeAutoRetrievalTimeout(verificationId);
        break;
    }
  }

  void _onAuthStageChangedHandler(MethodCall call) {
    final Map<dynamic, dynamic> data = call.arguments["user"];
    final int id = call.arguments["id"];

    final FirebaseUser currentUser =
        data != null ? FirebaseUser._(data, app) : null;
    _authStateChangedControllers[id].add(currentUser);
  }
}

