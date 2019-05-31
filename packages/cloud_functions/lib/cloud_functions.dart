// Copyright 2019, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library cloud_functions;

<<<<<<< HEAD
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class CloudFunctionsException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  CloudFunctionsException._(this.code, this.message, this.details);
}

/// The entry point for accessing a CloudFunctions.
///
/// You can get an instance by calling [CloudFunctions.instance].
class CloudFunctions {
  @visibleForTesting
  static const MethodChannel channel = MethodChannel('cloud_functions');

  static CloudFunctions _instance = new CloudFunctions();

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
=======
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

part 'src/cloud_functions.dart';
part 'src/https_callable.dart';
part 'src/https_callable_result.dart';
>>>>>>> 0f80e7380086ceed3c61c05dc431a41d2c32253a
