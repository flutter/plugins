// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'web_kit/web_kit.dart' as web_kit;

/// A [Widget] that displays a [web_kit.WebView].
class WebViewCupertinoWidget extends StatefulWidget {
  /// Constructs a [WebViewCupertinoWidget].
  const WebViewCupertinoWidget({
    required this.creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    required this.onBuildWidget,
    this.configuration,
    this.systemVersion,
    @visibleForTesting this.webViewProxy = const WebViewProxy(),
  });

  /// The initial parameters used to setup the WebView.
  final CreationParams creationParams;

  /// The handler of callbacks made made by [web_kit.NavigationDelegate].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manager of named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// A collection of properties that you use to initialize a web view.
  ///
  /// If null, a default configuration is used.
  final web_kit.WebViewConfiguration? configuration;

  /// The system version of the iOS device.
  ///
  /// If null, this value is retrieved asynchronously.
  final FutureOr<String>? systemVersion;

  /// The handler for constructing [web_kit.WebView]s.
  ///
  /// This should only be changed for testing purposes.
  final WebViewProxy webViewProxy;

  /// A callback to build a widget once [web_kit.WebView] has been initialized.
  final Widget Function(WebViewCupertinoPlatformController controller)
      onBuildWidget;

  @override
  State<StatefulWidget> createState() => _WebViewCupertinoWidgetState();
}

class _WebViewCupertinoWidgetState extends State<WebViewCupertinoWidget> {
  late final WebViewCupertinoPlatformController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewCupertinoPlatformController(
      creationParams: widget.creationParams,
      callbacksHandler: widget.callbacksHandler,
      javascriptChannelRegistry: widget.javascriptChannelRegistry,
      configuration: widget.configuration,
      systemVersion: widget.systemVersion,
      webViewProxy: widget.webViewProxy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: controller._initialize(),
      builder: (_, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState != material.ConnectionState.done) {
          return Container();
        } else if (snapshot.hasError) {
          throw Exception(
              'Initialization of WebView failed: ${snapshot.error}');
        } else {
          return widget.onBuildWidget(controller);
        }
      },
    );
  }
}

/// An implementation of [WebViewPlatformController] with the WebKit api.
class WebViewCupertinoPlatformController extends WebViewPlatformController {
  /// Construct a [WebViewCupertinoPlatformController].
  WebViewCupertinoPlatformController({
    required CreationParams creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    web_kit.WebViewConfiguration? configuration,
    FutureOr<String>? systemVersion,
    @visibleForTesting this.webViewProxy = const WebViewProxy(),
  }) : super(callbacksHandler) {
    this.systemVersion = systemVersion ?? _defaultSystemVersion;
    _setCreationParams(
      creationParams,
      configuration: configuration ?? web_kit.WebViewConfiguration(),
    ).then((_) => _initializationCompleter.complete());
  }

  // Since the version of iOS won't change once an app is started, this only
  // needs to retrieved for the first WebView.
  static final Future<IosDeviceInfo> _defaultDeviceInfo =
      DeviceInfoPlugin().iosInfo;

  static Future<String> get _defaultSystemVersion async {
    final String? systemVersion = (await _defaultDeviceInfo).systemVersion;
    assert(
      systemVersion != null,
      'Unable to retrieve the system version of this device.',
    );
    return systemVersion!;
  }

  final Completer<void> _initializationCompleter = Completer<void>();

  /// Handles callbacks that are made by navigation.
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// Handles constructing a [web_kit.WebView].
  ///
  /// This should only be changed when used for testing.
  final WebViewProxy webViewProxy;

  /// Represents the WebView maintained by platform code.
  late final web_kit.WebView webView;

  /// The system version of the iOS device.
  late final FutureOr<String> systemVersion;

  Future<void> _initialize() => _initializationCompleter.future;

  Future<void> _setCreationParams(
    CreationParams params, {
    required web_kit.WebViewConfiguration configuration,
  }) async {
    await _setWebViewConfiguration(
      configuration,
      allowsInlineMediaPlayback: params.webSettings?.allowsInlineMediaPlayback,
      autoMediaPlaybackPolicy: params.autoMediaPlaybackPolicy,
    );

    webView = webViewProxy.createWebView(configuration);
  }

  Future<void> _setWebViewConfiguration(
    web_kit.WebViewConfiguration configuration, {
    required bool? allowsInlineMediaPlayback,
    required AutoMediaPlaybackPolicy autoMediaPlaybackPolicy,
  }) async {
    if (allowsInlineMediaPlayback != null) {
      configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback;
    }

    late final bool requiresUserAction;
    switch (autoMediaPlaybackPolicy) {
      case AutoMediaPlaybackPolicy.require_user_action_for_all_media_types:
        requiresUserAction = true;
        break;
      case AutoMediaPlaybackPolicy.always_allow:
        requiresUserAction = false;
        break;
    }

    if (_isGreaterOrEqualVersion(await systemVersion, '10.0')) {
      configuration.mediaTypesRequiringUserActionForPlayback =
          <web_kit.AudiovisualMediaType>{
        if (requiresUserAction) web_kit.AudiovisualMediaType.all,
        if (!requiresUserAction) web_kit.AudiovisualMediaType.none
      };
    } else if (_isGreaterOrEqualVersion(await systemVersion, '9.0')) {
      configuration.requiresUserActionForMediaPlayback = requiresUserAction;
    } else {
      configuration.mediaPlaybackRequiresUserAction = requiresUserAction;
    }
  }

  bool _isGreaterOrEqualVersion(String first, String second) {
    return _parseVersion(first).compareTo(_parseVersion(second)) >= 0;
  }

  Version _parseVersion(String versionStr) {
    Version version;
    try {
      version = Version.parse(versionStr);
    } on FormatException {
      final List<String> parts = versionStr.split('.');
      final int major = int.parse(parts.first);
      final int minor = parts.length >= 2 ? int.parse(parts[1]) : 0;
      final int patch = parts.length >= 3 ? int.parse(parts[2]) : 0;
      version = Version(major, minor, patch);
    } catch(e) {
      rethrow;
    }

    return version;
  }
}

/// Handles constructing [web_kit.WebView]s and calling static methods.
///
/// This should only be used for testing purposes.
@visibleForTesting
class WebViewProxy {
  /// Creates a [WebViewProxy].
  const WebViewProxy();

  /// Constructs a [web_kit.WebView].
  web_kit.WebView createWebView(web_kit.WebViewConfiguration configuration) {
    return web_kit.WebView(configuration);
  }
}
