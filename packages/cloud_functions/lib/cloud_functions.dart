// Copyright 2018, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

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
  @visibleForTesting
  static const MethodChannel channel = MethodChannel('cloud_functions');

  static CloudFunctions _instance = CloudFunctions();

  static CloudFunctions get instance => _instance;

  /// Executes this Callable HTTPS trigger asynchronously.
  ///
  /// @param functionName The name of the callable function being triggered.
  /// @param parameters Parameters to be passed to the callable function.
  Future<dynamic> call(
      {@required String functionName, Map<String, dynamic> parameters}) async {
    try {
      final dynamic response =
          await channel.invokeMethod('CloudFunctions#call', <String, dynamic>{
        'functionName': functionName,
        'parameters': parameters,
      });
      return response;
    } on PlatformException catch (e) {
      if (e.code == 'functionsError') {
        final String code = e.details['code'];
        final String message = e.details['message'];
        final dynamic details = e.details['details'];
        print('throwing firebase functions exception');
        throw CloudFunctionsException._(code, message, details);
      } else {
        print('throwing generic exception');
        throw Exception('Unable to call function ' + functionName);
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
