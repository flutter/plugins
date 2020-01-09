import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_platform_images/ios_platform_images.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/ios_platform_images');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('resolveURL', () async {
    expect(await IosPlatformImages.resolveURL("foobar"), '42');
  });
}
