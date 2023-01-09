// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_navigation_delegate.dart';
import 'android_proxy.dart';
import 'android_webview.dart' as android_webview;
import 'android_webview.dart';
import 'instance_manager.dart';
import 'platform_views_service_proxy.dart';
import 'weak_reference_utils.dart';

/// Object specifying creation parameters for creating a [AndroidWebViewController].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewControllerCreationParams] for
/// more information.
@immutable
class AndroidWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Creates a new [AndroidWebViewControllerCreationParams] instance.
  AndroidWebViewControllerCreationParams({
    @visibleForTesting this.androidWebViewProxy = const AndroidWebViewProxy(),
    @visibleForTesting android_webview.WebStorage? androidWebStorage,
  })  : androidWebStorage =
            androidWebStorage ?? android_webview.WebStorage.instance,
        super();

  /// Creates a [AndroidWebViewControllerCreationParams] instance based on [PlatformWebViewControllerCreationParams].
  factory AndroidWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting
        AndroidWebViewProxy androidWebViewProxy = const AndroidWebViewProxy(),
    @visibleForTesting android_webview.WebStorage? androidWebStorage,
  }) {
    return AndroidWebViewControllerCreationParams(
      androidWebViewProxy: androidWebViewProxy,
      androidWebStorage:
          androidWebStorage ?? android_webview.WebStorage.instance,
    );
  }

  /// Handles constructing objects and calling static methods for the Android WebView
  /// native library.
  @visibleForTesting
  final AndroidWebViewProxy androidWebViewProxy;

  /// Manages the JavaScript storage APIs provided by the [android_webview.WebView].
  @visibleForTesting
  final android_webview.WebStorage androidWebStorage;
}

/// Implementation of the [PlatformWebViewController] with the Android WebView API.
class AndroidWebViewController extends PlatformWebViewController {
  /// Creates a new [AndroidWebViewCookieManager].
  AndroidWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params is AndroidWebViewControllerCreationParams
            ? params
            : AndroidWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(params)) {
    _webView.settings.setDomStorageEnabled(true);
    _webView.settings.setJavaScriptCanOpenWindowsAutomatically(true);
    _webView.settings.setSupportMultipleWindows(true);
    _webView.settings.setLoadWithOverviewMode(true);
    _webView.settings.setUseWideViewPort(true);
    _webView.settings.setDisplayZoomControls(false);
    _webView.settings.setBuiltInZoomControls(true);
  }

  AndroidWebViewControllerCreationParams get _androidWebViewParams =>
      params as AndroidWebViewControllerCreationParams;

  /// The native [android_webview.WebView] being controlled.
  late final android_webview.WebView _webView =
      _androidWebViewParams.androidWebViewProxy.createAndroidWebView(
    // Due to changes in Flutter 3.0 the `useHybridComposition` doesn't have
    // any effect and is purposefully not exposed publicly by the
    // [AndroidWebViewController]. More info here:
    // https://github.com/flutter/flutter/issues/108106
    useHybridComposition: true,
  );

  /// The native [android_webview.FlutterAssetManager] allows managing assets.
  late final android_webview.FlutterAssetManager _flutterAssetManager =
      _androidWebViewParams.androidWebViewProxy.createFlutterAssetManager();

  final Map<String, AndroidJavaScriptChannelParams> _javaScriptChannelParams =
      <String, AndroidJavaScriptChannelParams>{};

  // The keeps a reference to the current NavigationDelegate so that the
  // callback methods remain reachable.
  // ignore: unused_field
  late AndroidNavigationDelegate _currentNavigationDelegate;

  /// Whether to enable the platform's webview content debugging tools.
  ///
  /// Defaults to false.
  static Future<void> enableDebugging(
    bool enabled, {
    @visibleForTesting
        AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  }) {
    return webViewProxy.setWebContentsDebuggingEnabled(enabled);
  }

  @override
  Future<void> loadFile(
    String absoluteFilePath,
  ) {
    final String url = absoluteFilePath.startsWith('file://')
        ? absoluteFilePath
        : Uri.file(absoluteFilePath).toString();

    _webView.settings.setAllowFileAccess(true);
    return _webView.loadUrl(url, <String, String>{});
  }

  @override
  Future<void> loadFlutterAsset(
    String key,
  ) async {
    final String assetFilePath =
        await _flutterAssetManager.getAssetFilePathByName(key);
    final List<String> pathElements = assetFilePath.split('/');
    final String fileName = pathElements.removeLast();
    final List<String?> paths =
        await _flutterAssetManager.list(pathElements.join('/'));

    if (!paths.contains(fileName)) {
      throw ArgumentError(
        'Asset for key "$key" not found.',
        'key',
      );
    }

    return _webView.loadUrl(
      Uri.file('/android_asset/$assetFilePath').toString(),
      <String, String>{},
    );
  }

  @override
  Future<void> loadHtmlString(
    String html, {
    String? baseUrl,
  }) {
    return _webView.loadDataWithBaseUrl(
      baseUrl: baseUrl,
      data: html,
      mimeType: 'text/html',
    );
  }

  @override
  Future<void> loadRequest(
    LoadRequestParams params,
  ) {
    if (!params.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    switch (params.method) {
      case LoadRequestMethod.get:
        return _webView.loadUrl(params.uri.toString(), params.headers);
      case LoadRequestMethod.post:
        return _webView.postUrl(
            params.uri.toString(), params.body ?? Uint8List(0));
      default:
        throw UnimplementedError(
          'This version of `AndroidWebViewController` currently has no implementation for HTTP method ${params.method.serialize()} in loadRequest.',
        );
    }
  }

  @override
  Future<String?> currentUrl() => _webView.getUrl();

  @override
  Future<bool> canGoBack() => _webView.canGoBack();

  @override
  Future<bool> canGoForward() => _webView.canGoForward();

  @override
  Future<void> goBack() => _webView.goBack();

  @override
  Future<void> goForward() => _webView.goForward();

  @override
  Future<void> reload() => _webView.reload();

  @override
  Future<void> clearCache() => _webView.clearCache(true);

  @override
  Future<void> clearLocalStorage() =>
      _androidWebViewParams.androidWebStorage.deleteAllData();

  @override
  Future<void> setPlatformNavigationDelegate(
      covariant AndroidNavigationDelegate handler) async {
    _currentNavigationDelegate = handler;
    handler.setOnLoadRequest(loadRequest);
    _webView.setWebViewClient(handler.androidWebViewClient);
    _webView.setWebChromeClient(handler.androidWebChromeClient);
    _webView.setDownloadListener(handler.androidDownloadListener);
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    return _webView.evaluateJavascript(javaScript);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    final String? result = await _webView.evaluateJavascript(javaScript);

    if (result == null) {
      return '';
    } else if (result == 'true') {
      return true;
    } else if (result == 'false') {
      return false;
    }

    return num.tryParse(result) ?? result;
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) {
    final AndroidJavaScriptChannelParams androidJavaScriptParams =
        javaScriptChannelParams is AndroidJavaScriptChannelParams
            ? javaScriptChannelParams
            : AndroidJavaScriptChannelParams.fromJavaScriptChannelParams(
                javaScriptChannelParams);

    // When JavaScript channel with the same name exists make sure to remove it
    // before registering the new channel.
    if (_javaScriptChannelParams.containsKey(androidJavaScriptParams.name)) {
      _webView
          .removeJavaScriptChannel(androidJavaScriptParams._javaScriptChannel);
    }

    _javaScriptChannelParams[androidJavaScriptParams.name] =
        androidJavaScriptParams;

    return _webView
        .addJavaScriptChannel(androidJavaScriptParams._javaScriptChannel);
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    final AndroidJavaScriptChannelParams? javaScriptChannelParams =
        _javaScriptChannelParams[javaScriptChannelName];
    if (javaScriptChannelParams == null) {
      return;
    }

    _javaScriptChannelParams.remove(javaScriptChannelName);
    return _webView
        .removeJavaScriptChannel(javaScriptChannelParams._javaScriptChannel);
  }

  @override
  Future<String?> getTitle() => _webView.getTitle();

  @override
  Future<void> scrollTo(int x, int y) => _webView.scrollTo(x, y);

  @override
  Future<void> scrollBy(int x, int y) => _webView.scrollBy(x, y);

  @override
  Future<Offset> getScrollPosition() {
    return _webView.getScrollPosition();
  }

  @override
  Future<void> enableZoom(bool enabled) =>
      _webView.settings.setSupportZoom(enabled);

  @override
  Future<void> setBackgroundColor(Color color) =>
      _webView.setBackgroundColor(color);

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) =>
      _webView.settings
          .setJavaScriptEnabled(javaScriptMode == JavaScriptMode.unrestricted);

  @override
  Future<void> setUserAgent(String? userAgent) =>
      _webView.settings.setUserAgentString(userAgent);

  /// Sets the restrictions that apply on automatic media playback.
  Future<void> setMediaPlaybackRequiresUserGesture(bool require) {
    return _webView.settings.setMediaPlaybackRequiresUserGesture(require);
  }
}

/// An implementation of [JavaScriptChannelParams] with the Android WebView API.
///
/// See [AndroidWebViewController.addJavaScriptChannel].
@immutable
class AndroidJavaScriptChannelParams extends JavaScriptChannelParams {
  /// Constructs a [AndroidJavaScriptChannelParams].
  AndroidJavaScriptChannelParams({
    required super.name,
    required super.onMessageReceived,
    @visibleForTesting
        AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  })  : assert(name.isNotEmpty),
        _javaScriptChannel = webViewProxy.createJavaScriptChannel(
          name,
          postMessage: withWeakRefenceTo(
            onMessageReceived,
            (WeakReference<void Function(JavaScriptMessage)> weakReference) {
              return (
                String message,
              ) {
                if (weakReference.target != null) {
                  weakReference.target!(
                    JavaScriptMessage(message: message),
                  );
                }
              };
            },
          ),
        );

  /// Constructs a [AndroidJavaScriptChannelParams] using a
  /// [JavaScriptChannelParams].
  AndroidJavaScriptChannelParams.fromJavaScriptChannelParams(
    JavaScriptChannelParams params, {
    @visibleForTesting
        AndroidWebViewProxy webViewProxy = const AndroidWebViewProxy(),
  }) : this(
          name: params.name,
          onMessageReceived: params.onMessageReceived,
          webViewProxy: webViewProxy,
        );

  final android_webview.JavaScriptChannel _javaScriptChannel;
}

/// Object specifying creation parameters for creating a [AndroidWebViewWidget].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebViewWidgetCreationParams] for
/// more information.
@immutable
class AndroidWebViewWidgetCreationParams
    extends PlatformWebViewWidgetCreationParams {
  /// Creates [AndroidWebWidgetCreationParams].
  AndroidWebViewWidgetCreationParams({
    super.key,
    required super.controller,
    super.layoutDirection,
    super.gestureRecognizers,
    this.displayWithHybridComposition = false,
    @visibleForTesting InstanceManager? instanceManager,
    @visibleForTesting
        this.platformViewsServiceProxy = const PlatformViewsServiceProxy(),
  }) : instanceManager = instanceManager ?? JavaObject.globalInstanceManager;

  /// Constructs a [WebKitWebViewWidgetCreationParams] using a
  /// [PlatformWebViewWidgetCreationParams].
  AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
    PlatformWebViewWidgetCreationParams params, {
    bool displayWithHybridComposition = false,
    @visibleForTesting InstanceManager? instanceManager,
    @visibleForTesting PlatformViewsServiceProxy platformViewsServiceProxy =
        const PlatformViewsServiceProxy(),
  }) : this(
          key: params.key,
          controller: params.controller,
          layoutDirection: params.layoutDirection,
          gestureRecognizers: params.gestureRecognizers,
          displayWithHybridComposition: displayWithHybridComposition,
          instanceManager: instanceManager,
          platformViewsServiceProxy: platformViewsServiceProxy,
        );

  /// Maintains instances used to communicate with the native objects they
  /// represent.
  ///
  /// This field is exposed for testing purposes only and should not be used
  /// outside of tests.
  @visibleForTesting
  final InstanceManager instanceManager;

  /// Proxy that provides access to the platform views service.
  ///
  /// This service allows creating and controlling platform-specific views.
  @visibleForTesting
  final PlatformViewsServiceProxy platformViewsServiceProxy;

  /// Whether the [WebView] will be displayed using the Hybrid Composition
  /// PlatformView implementation.
  ///
  /// For most use cases, this flag should be set to false. Hybrid Composition
  /// can have performance costs but doesn't have the limitation of rendering to
  /// an Android SurfaceTexture. See
  /// * https://flutter.dev/docs/development/platform-integration/platform-views#performance
  /// * https://github.com/flutter/flutter/issues/104889
  /// * https://github.com/flutter/flutter/issues/116954
  ///
  /// Defaults to false.
  final bool displayWithHybridComposition;
}

/// An implementation of [PlatformWebViewWidget] with the Android WebView API.
class AndroidWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebKitWebViewWidget].
  AndroidWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(
          params is AndroidWebViewWidgetCreationParams
              ? params
              : AndroidWebViewWidgetCreationParams
                  .fromPlatformWebViewWidgetCreationParams(params),
        );

  AndroidWebViewWidgetCreationParams get _androidParams =>
      params as AndroidWebViewWidgetCreationParams;

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      key: _androidParams.key,
      viewType: 'plugins.flutter.io/webview',
      surfaceFactory: (
        BuildContext context,
        PlatformViewController controller,
      ) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: _androidParams.gestureRecognizers,
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return _initAndroidView(
          params,
          displayWithHybridComposition:
              _androidParams.displayWithHybridComposition,
        )
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..create();
      },
    );
  }

  AndroidViewController _initAndroidView(
    PlatformViewCreationParams params, {
    required bool displayWithHybridComposition,
  }) {
    if (displayWithHybridComposition) {
      return _androidParams.platformViewsServiceProxy.initExpensiveAndroidView(
        id: params.id,
        viewType: 'plugins.flutter.io/webview',
        layoutDirection: _androidParams.layoutDirection,
        creationParams: _androidParams.instanceManager.getIdentifier(
            (_androidParams.controller as AndroidWebViewController)._webView),
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return _androidParams.platformViewsServiceProxy.initSurfaceAndroidView(
        id: params.id,
        viewType: 'plugins.flutter.io/webview',
        layoutDirection: _androidParams.layoutDirection,
        creationParams: _androidParams.instanceManager.getIdentifier(
            (_androidParams.controller as AndroidWebViewController)._webView),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }
}
