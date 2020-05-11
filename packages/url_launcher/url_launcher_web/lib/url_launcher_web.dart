import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

/// The web implementation of [UrlLauncherPlatform].
///
/// This class implements the `package:url_launcher` functionality for the web.
class UrlLauncherPlugin extends UrlLauncherPlatform {
  static final _iosPlatforms = RegExp(r'iPad|iPhone|iPod');
  html.Window _window;

  /// A constructor that allows tests to override the window object used by the plugin.
  UrlLauncherPlugin({@visibleForTesting html.Window window})
      : _window = window ?? html.window;

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith(Registrar registrar) {
    UrlLauncherPlatform.instance = UrlLauncherPlugin();
  }

  bool get _isIos => _iosPlatforms.hasMatch(_window.navigator.platform);

  bool _isMailTo(String url) {
    return Uri.tryParse(url)?.isScheme('mailto') ?? false;
  }

  /// Opens the given [url] in a new window.
  ///
  /// Returns the newly created window.
  @visibleForTesting
  html.WindowBase openNewWindow(String url) {
    final target = _isIos && _isMailTo(url) ? '_top' : '';
    return _window.open(url, target);
  }

  @override
  Future<bool> canLaunch(String url) {
    final Uri parsedUrl = Uri.tryParse(url);
    if (parsedUrl == null) return Future<bool>.value(false);

    return Future<bool>.value(parsedUrl.isScheme('http') ||
        parsedUrl.isScheme('https') ||
        parsedUrl.isScheme('mailto'));
  }

  @override
  Future<bool> launch(
    String url, {
    @required bool useSafariVC,
    @required bool useWebView,
    @required bool enableJavaScript,
    @required bool enableDomStorage,
    @required bool universalLinksOnly,
    @required Map<String, String> headers,
  }) {
    return Future<bool>.value(openNewWindow(url) != null);
  }
}
