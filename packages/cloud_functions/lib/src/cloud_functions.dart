// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_functions;

class CloudFunctionsException implements Exception {
  CloudFunctionsException._(this.code, this.message, this.details);

  final String code;
  final String message;
  final dynamic details;
}

/// The entry point for accessing a CloudFunctions.
///
/// You can get an instance by calling [CloudFunctions.instance].
class CloudFunctions {
  CloudFunctions({FirebaseApp app, String region, String origin})
      : _app = app ?? FirebaseApp.instance,
        _region = region,
        _origin = origin;

  @visibleForTesting
  static const MethodChannel channel = MethodChannel('cloud_functions');

  static CloudFunctions _instance = CloudFunctions();

  static CloudFunctions get instance => _instance;

  final FirebaseApp _app;

  final String _region;

  String _origin;

  /// Gets an instance of a Callable HTTPS trigger in Cloud Functions.
  ///
  /// Can then be executed by calling `call()` on it.
  ///
  /// @param functionName The name of the callable function.
  HttpsCallable getHttpsCallable({@required String functionName}) {
    return HttpsCallable._(this, functionName);
  }

  /// Changes this instance to point to a Cloud Functions emulator running locally.
  ///
  /// @param origin The origin of the local emulator, such as "//10.0.2.2:5005".
  CloudFunctions useFunctionsEmulator({@required String origin}) {
    _origin = origin;
    return this;
  }
}
