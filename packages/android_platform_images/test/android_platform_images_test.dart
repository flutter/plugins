import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_platform_images/android_platform_images.dart';

void main() {
  const MethodChannel channel = MethodChannel('android_platform_images');

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
    expect(await AndroidPlatformImages.platformVersion, '42');
  });
}
