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
  CloudFunctions({FirebaseApp app, String region})
      : _app = app ?? FirebaseApp.instance,
        _region = region;

  @visibleForTesting
  static const MethodChannel channel = MethodChannel('cloud_functions');

  static CloudFunctions _instance = CloudFunctions();

  static CloudFunctions get instance => _instance;

  final FirebaseApp _app;

  final String _region;

  /// Executes this Callable HTTPS trigger asynchronously.
  ///
  /// @param functionName The name of the callable function being triggered.
  /// @param parameters Parameters to be passed to the callable function.
  HttpsCallable getHttpsCallable(
      {@required String functionName, Map<String, dynamic> parameters}) {
    return HttpsCallable._(this, functionName);
  }
}
