import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:platform_detect/platform_detect.dart' show browser;

const _mailtoScheme = 'mailto';

/// The web implementation of [UrlLauncherPlatform].
///
/// This class implements the `package:url_launcher` functionality for the web.
class UrlLauncherPlugin extends UrlLauncherPlatform {
  html.Window _window;

  // The set of schemes that can be handled by the plugin
  static final _supportedSchemes = {'http', 'https', _mailtoScheme};

  /// A constructor that allows tests to override the window object used by the plugin.
  UrlLauncherPlugin({@visibleForTesting html.Window window})
      : _window = window ?? html.window;

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith(Registrar registrar) {
    UrlLauncherPlatform.instance = UrlLauncherPlugin();
  }

  String _getUrlScheme(String url) => Uri.tryParse(url)?.scheme;

  bool _isMailtoScheme(String url) => _getUrlScheme(url) == _mailtoScheme;

  /// Opens the given [url] in a new window.
  ///
  /// Returns the newly created window.
  @visibleForTesting
  html.WindowBase openNewWindow(String url) {
    // We need to open mailto urls on the _top window context on safari browsers.
    // See https://github.com/flutter/flutter/issues/51461 for reference.
    final target = browser.isSafari && _isMailtoScheme(url) ? '_top' : '';
    return _window.open(url, target);
  }

  @override
  Future<bool> canLaunch(String url) {
    return Future<bool>.value(_supportedSchemes.contains(_getUrlScheme(url)));
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
