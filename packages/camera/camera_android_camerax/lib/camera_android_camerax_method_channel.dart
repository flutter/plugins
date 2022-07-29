import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'camera_android_camerax_platform_interface.dart';

/// An implementation of [CameraAndroidCameraxPlatform] that uses method channels.
class MethodChannelCameraAndroidCamerax extends CameraAndroidCameraxPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('camera_android_camerax');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
