import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_android_lifecycle/flutter_android_lifecycle.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_android_lifecycle');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterAndroidLifecycle.platformVersion, '42');
  });
}
