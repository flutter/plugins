import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('$CloudFunctions', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      CloudFunctions.channel
          .setMockMethodCallHandler((MethodCall methodCall) async {
        log.add(methodCall);
        switch (methodCall.method) {
          case 'FirebaseFunctions#call':
            return <String, dynamic>{
              'foo': 'bar',
            };
          default:
            return true;
        }
      });
      log.clear();
    });

    test('call', () async {
      await CloudFunctions.instance.call(functionName: 'baz');
      await CloudFunctions.instance
          .call(functionName: 'qux', parameters: <String, dynamic>{
        'quux': 'quuz',
      });
      expect(
        log,
        <Matcher>[
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'functionName': 'baz',
              'parameters': null,
            },
          ),
          isMethodCall(
            'FirebaseFunctions#call',
            arguments: <String, dynamic>{
              'functionName': 'qux',
              'parameters': <String, dynamic>{
                'quux': 'quuz',
              },
            },
          ),
        ],
      );
    });
  });
}
