import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:meta/meta.dart';

class UrlLauncherPlugin {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
        'plugins.flutter.io/url_launcher',
        const StandardMethodCodec(),
        registrar.messenger);
    final UrlLauncherPlugin instance = UrlLauncherPlugin();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'canLaunch':
        final String url = call.arguments['url'];
        return _canLaunch(url);
      case 'launch':
        final String url = call.arguments['url'];
        return _launch(url);
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The url_launcher plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  bool _canLaunch(String url) {
    final Uri parsedUrl = Uri.tryParse(url);
    if (parsedUrl == null) return false;

    return parsedUrl.isScheme('http') || parsedUrl.isScheme('https');
  }

  bool _launch(String url) {
    return openNewWindow(url) != null;
  }

  @visibleForTesting
  html.WindowBase openNewWindow(String url) {
    return html.window.open(url, '');
  }
}
