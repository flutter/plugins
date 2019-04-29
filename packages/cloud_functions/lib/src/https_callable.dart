// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of cloud_functions;

/// A reference to a particular Callable HTTPS trigger in Cloud Functions.
///
/// You can get an instance by calling [CloudFunctions.instance.getHTTPSCallable].
class HttpsCallable {
  HttpsCallable._(this._cloudFunctions, this._functionName);

  final CloudFunctions _cloudFunctions;
  final String _functionName;

  Future<HttpsCallableResult> call([dynamic parameters]) async {
    try {
      final MethodChannel channel = CloudFunctions.channel;
      final dynamic response =
          await channel.invokeMethod<dynamic>('CloudFunctions#call', <String, dynamic>{
        'app': _cloudFunctions._app.name,
        'region': _cloudFunctions._region,
        'timeoutMicroseconds': _timeout?.inMicroseconds,
        'functionName': _functionName,
        'parameters': parameters,
      });
      return HttpsCallableResult._(response);
    } on PlatformException catch (e) {
      if (e.code == 'functionsError') {
        final String code = e.details['code'];
        final String message = e.details['message'];
        final dynamic details = e.details['details'];
        throw CloudFunctionsException._(code, message, details);
      } else {
        throw Exception('Unable to call function ' + _functionName);
      }
    } catch (e) {
      rethrow;
    }
  }

  Duration _timeout;

  /// The timeout to use when calling the function. Defaults to 60 seconds.
  Duration get timeout => _timeout;
  set timeout(Duration value) {
    _timeout = value;
  }
}
