import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class CloudFunctionsException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  CloudFunctionsException._(this.code, this.message, this.details);
}

class CloudFunctions {
  @visibleForTesting
  static const MethodChannel channel =
  const MethodChannel('cloud_functions');

  static CloudFunctions _instance = new CloudFunctions();

  static CloudFunctions get instance => _instance;

  Future<dynamic> call({@required String functionName, Map<String, dynamic> parameters}) async {
    try {
      final dynamic response = await channel.invokeMethod('CloudFunctions#call', <String, dynamic> {
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
