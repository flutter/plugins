
import 'wrapper_example_platform_interface.dart';

class WrapperExample {
  Future<String?> getPlatformVersion() {
    return WrapperExamplePlatform.instance.getPlatformVersion();
  }
}
