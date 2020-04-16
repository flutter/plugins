import 'dart:async';
import 'dart:html' as html;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'navigator.dart';

/// The web implementation of [UrlLauncherPlatform].
///
/// This class implements the `package:url_launcher` functionality for the web.
class UrlLauncherPlugin extends UrlLauncherPlatform {
  final Navigator _navigator;

  /// [UrlLauncherPlugin] constructor.
  @visibleForTesting
  UrlLauncherPlugin({Navigator navigator})
      : _navigator = navigator ?? Navigator();

  /// Registers this class as the default instance of [UrlLauncherPlatform].
  static void registerWith(Registrar registrar) {
    UrlLauncherPlatform.instance = UrlLauncherPlugin();
  }

  /// Opens the given [url].
  /// The url will be opened in a new window unless the browser is in standalone.
  /// Returns the newly created window.
  @visibleForTesting
  html.WindowBase openUrl(String url) {
    // We need to open on _top in ios browsers in standalone mode.
    // See https://github.com/flutter/flutter/issues/51461 for reference.
    final target = _navigator.standalone ? '_top' : '';
    return html.window.open(url, target);
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
    return Future<bool>.value(openUrl(url) != null);
  }
}
