// The url_launcher_platform_interface defaults to MethodChannelUrlLauncher
// as its instance, which is all the Linux implementation needs. This file
// is here to silence warnings when publishing to pub.

/// UrlLauncherLinux provides the registerWith() method.
class UrlLauncherLinux {
  /// Binds the implementation to the interface.
  static void registerWith() {}
}
