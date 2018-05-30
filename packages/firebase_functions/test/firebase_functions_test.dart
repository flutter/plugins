import 'package:firebase_functions/firebase_functions.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  group('$FirebaseFunctions', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() async {
      FirebaseFunctions.channel
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
      await FirebaseFunctions.instance.call(functionName: 'baz');
      await FirebaseFunctions.instance.call(functionName: 'qux',
          parameters: <String, dynamic> {
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
              'parameters': <String, dynamic> {
                'quux': 'quuz',
              },
            },
          ),
        ],
      );
    });
  });
}