import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class UrlLauncherPlugin extends UrlLauncherPlatform {
  static void registerWith(Registrar registrar) {
    UrlLauncherPlatform.instance = UrlLauncherPlugin();
  }

  @visibleForTesting
  html.WindowBase openNewWindow(String url) {
    return html.window.open(url, '');
  }

  @override
  Future<bool> canLaunch(String url) {
    final Uri parsedUrl = Uri.tryParse(url);
    if (parsedUrl == null) return Future<bool>.value(false);

    return Future<bool>.value(
        parsedUrl.isScheme('http') || parsedUrl.isScheme('https'));
  }

  /// Returns `true` if the given [url] was successfully launched.
  ///
  /// For documentation on the other arguments, see the `launch` documentation
  /// in `package:url_launcher/url_launcher.dart`.
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
