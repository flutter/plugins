import 'package:flutter_test/flutter_test.dart';
import 'package:camera_android_camerax/camera_android_camerax.dart';
import 'package:camera_android_camerax/camera_android_camerax_platform_interface.dart';
import 'package:camera_android_camerax/camera_android_camerax_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCameraAndroidCameraxPlatform
    with MockPlatformInterfaceMixin
    implements CameraAndroidCameraxPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CameraAndroidCameraxPlatform initialPlatform = CameraAndroidCameraxPlatform.instance;

  test('$MethodChannelCameraAndroidCamerax is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCameraAndroidCamerax>());
  });

  test('getPlatformVersion', () async {
    CameraAndroidCamerax cameraAndroidCameraxPlugin = CameraAndroidCamerax();
    MockCameraAndroidCameraxPlatform fakePlatform = MockCameraAndroidCameraxPlatform();
    CameraAndroidCameraxPlatform.instance = fakePlatform;

    expect(await cameraAndroidCameraxPlugin.getPlatformVersion(), '42');
  });
}
