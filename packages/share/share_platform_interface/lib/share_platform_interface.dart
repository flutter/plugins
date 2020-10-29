import 'package:flutter/cupertino.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_platform_interface/method_channel_share.dart';

/// The interface that implementations of share must implement.
///
/// Platform implementations should extend this class rather than implement it as `share`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [SharePlatform] methods.
class SharePlatform extends PlatformInterface {
  /// Constructs a SharePlatform.
  SharePlatform() : super(token: _token);

  static final Object _token = Object();

  static SharePlatform _instance = MethodChannelShare();

  /// The default instance of [SharePlatform] to use.
  ///
  /// Defaults to [MethodChannelShare].
  static SharePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [SharePlatform] when they register themselves.
  static set instance(SharePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> share(
    String text, {
    @required String subject,
    @required Rect sharePositionOrigin,
  }) {
    throw UnimplementedError('share() has not been implemented.');
  }

  Future<void> shareFiles(
    List<String> paths, {
    @required List<String> mimeTypes,
    @required String subject,
    @required String text,
    @required Rect sharePositionOrigin,
  }) {
    throw UnimplementedError('shareFiles() has not been implemented.');
  }
}
