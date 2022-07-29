import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_android_camerax/camera_android_camerax_method_channel.dart';

void main() {
  MethodChannelCameraAndroidCamerax platform =
      MethodChannelCameraAndroidCamerax();
  const MethodChannel channel = MethodChannel('camera_android_camerax');

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
    expect(await platform.getPlatformVersion(), '42');
  });
}
