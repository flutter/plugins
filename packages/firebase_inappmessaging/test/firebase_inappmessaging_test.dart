import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_inappmessaging/firebase_inappmessaging.dart';

void main() {
  const MethodChannel channel = MethodChannel('firebase_inappmessaging');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FirebaseInappmessaging.platformVersion, '42');
  });
}
