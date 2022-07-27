import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'wrapper_example_platform_interface.dart';

/// An implementation of [WrapperExamplePlatform] that uses method channels.
class MethodChannelWrapperExample extends WrapperExamplePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('wrapper_example');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
