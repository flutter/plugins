import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'wrapper_example_method_channel.dart';

abstract class WrapperExamplePlatform extends PlatformInterface {
  /// Constructs a WrapperExamplePlatform.
  WrapperExamplePlatform() : super(token: _token);

  static final Object _token = Object();

  static WrapperExamplePlatform _instance = MethodChannelWrapperExample();

  /// The default instance of [WrapperExamplePlatform] to use.
  ///
  /// Defaults to [MethodChannelWrapperExample].
  static WrapperExamplePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WrapperExamplePlatform] when
  /// they register themselves.
  static set instance(WrapperExamplePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
