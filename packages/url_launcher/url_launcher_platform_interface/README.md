# url_launcher_platform_interface

A common platform interface for the [`url_launcher`][1] plugin.

This interface allows platform-specific implementations of the `url_launcher`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `url_launcher`, you can
either implement the method channel calls (specified in
[`method_channel_url_launcher.dart`][2]) or you can implement your own instance
of [`UrlLauncherPlatform`][3] and register it with `package:url_launcher` by
setting `urlLauncherPlatform`.

[1]: ../url_launcher
[2]: lib/method_channel_url_launcher.dart
[3]: lib/url_launcher_platform_interface.dart
