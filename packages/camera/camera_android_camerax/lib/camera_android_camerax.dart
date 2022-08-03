
import 'camera_android_camerax_platform_interface.dart';

class CameraAndroidCamerax {
  Future<String?> getPlatformVersion() {
    return CameraAndroidCameraxPlatform.instance.getPlatformVersion();
  }
}
