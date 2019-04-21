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
          // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
          // https://github.com/flutter/flutter/issues/26431
          // ignore: strong_mode_implicit_dynamic_method
          await channel.invokeMethod('CloudFunctions#call', <String, dynamic>{
        'app': _cloudFunctions._app.name,
        'region': _cloudFunctions._region,
        'functionName': _functionName,
        'parameters': parameters,
      });
      return HttpsCallableResult._(response);
    } on PlatformException catch (e) {
      if (e.code == 'functionsError') {
        final String code = e.details['code'];
        final String message = e.details['message'];
        final dynamic details = e.details['details'];
        print('throwing firebase functions exception');
        throw CloudFunctionsException._(code, message, details);
      } else {
        print('throwing generic exception');
        throw Exception('Unable to call function ' + _functionName);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Duration _timeout;

  Duration get timeout => _timeout;
  set duration(Duration value) {
    _timeout = value;
  }
}
