import 'dart:io';
import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// The linux implementation of [PathProviderPlatform]
///
/// This class implements the `package:path_provider` functionality for linux
class PathProviderLinux extends PathProviderPlatform {
  /// Registers this class as the default instance of [PathProviderPlatform]
  static void register() {
    PathProviderPlatform.instance = PathProviderLinux();
  }

  static Map<String, dynamic> getXDGDefaults() {
    final file = File("/");
  }

  @override
  Future<String> getTemporaryPath() {
    return Future.value("/tmp");
  }

  @override
  Future<String> getApplicationSupportPath() {
    throw UnimplementedError('getApplicationSupportPath() has not been implemented.');
  }

  @override
  Future<String> getApplicationDocumentsPath() {
    return Future.value(p.join(Platform.environment['HOME'], 'Documents'));
  }

  @override
  Future<String> getDownloadsPath() {
    return Future.value(p.join(Platform.environment['HOME'], 'Downloads'));
  }
}
