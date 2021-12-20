// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'foundation/foundation.dart';
import 'ios_kit/ios_kit.dart' as ios_kit;
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
    this.applicationDocumentsDirectory,
    this.userContentController,
    this.preferences,
    this.dataStore,
    @visibleForTesting this.webViewProxy = const WebViewProxy(),
  });

  /// The initial parameters used to setup the WebView.
  final CreationParams creationParams;

  /// The handler of callbacks made made by [web_kit.NavigationDelegate].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manager of named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// The handler for constructing [web_kit.WebView]s.
  ///
  /// This should only be changed for testing purposes.
  final WebViewProxy webViewProxy;

  /// A collection of properties that you use to initialize a web view.
  ///
  /// If null, a default configuration is used.
  final web_kit.WebViewConfiguration? configuration;

  /// The system version of the iOS device.
  ///
  /// If null, this value is retrieved asynchronously.
  final FutureOr<double>? systemVersion;

  /// The directory where Flutter assets are stored for this application.
  ///
  /// If null, this value is retrieved asynchronously.
  final FutureOr<Directory>? applicationDocumentsDirectory;

  /// Encapsulates the standard behaviors to apply to websites.
  final web_kit.Preferences? preferences;

  /// Manages interactions between JavaScript code and your web view.
  final web_kit.UserContentController? userContentController;

  /// Manages cookies, disk and memory caches, and other types of data for a web view.
  final web_kit.WebsiteDataStore? dataStore;

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
      webViewProxy: widget.webViewProxy,
      configuration: widget.configuration,
      preferences: widget.preferences,
      systemVersion: widget.systemVersion,
      userContentController: widget.userContentController,
      applicationDocumentsDirectory: widget.applicationDocumentsDirectory,
      dataStore: widget.dataStore,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: controller._initializationCompleter.future,
      builder: (_, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == material.ConnectionState.done) {
          return widget.onBuildWidget(controller);
        } else {
          return Container();
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
    web_kit.Preferences? preferences,
    web_kit.UserContentController? userContentController,
    web_kit.WebsiteDataStore? dataStore,
    FutureOr<double>? systemVersion,
    FutureOr<Directory>? applicationDocumentsDirectory,
    @visibleForTesting this.webViewProxy = const WebViewProxy(),
  }) : super(callbacksHandler) {
    this.preferences = preferences ?? web_kit.Preferences();
    this.userContentController =
        userContentController ?? web_kit.UserContentController();
    this.systemVersion = systemVersion ?? _defaultSystemVersion;
    this.applicationDocumentsDirectory =
        applicationDocumentsDirectory ?? _defaultApplicationDocumentsDirectory;
    this.dataStore = dataStore ?? web_kit.WebsiteDataStore.defaultDataStore;
    _setCreationParams(
      creationParams,
      configuration: configuration ?? web_kit.WebViewConfiguration(),
    ).then((_) => _initializationCompleter.complete());
  }

  static final Future<IosDeviceInfo> _defaultDeviceInfo =
      DeviceInfoPlugin().iosInfo;

  static Future<double> get _defaultSystemVersion async {
    return double.parse((await _defaultDeviceInfo).systemVersion!);
  }

  static final FutureOr<Directory> _defaultApplicationDocumentsDirectory =
      path_provider.getApplicationDocumentsDirectory();

  /// Manages cookies, disk and memory caches, and other types of data for a web view.
  late final web_kit.WebsiteDataStore dataStore;

  /// The system version of the iOS device.
  ///
  /// If null, this value is retrieved asynchronously.
  late final FutureOr<double> systemVersion;

  /// The directory where Flutter assets are stored for this application.
  ///
  /// If null, this value is retrieved asynchronously.
  late final FutureOr<Directory> applicationDocumentsDirectory;

  final Map<String, WebViewCupertinoScriptMessageHandler>
      _scriptMessageHandlers = <String, WebViewCupertinoScriptMessageHandler>{};

  /// Handles navigation requests, callbacks and errors.
  @visibleForTesting
  late final WebViewCupertinoNavigationDelegate navigationDelegate =
      WebViewCupertinoNavigationDelegate(
    onPageStartedCallback: callbacksHandler.onPageStarted,
    onPageFinishedCallback: callbacksHandler.onPageFinished,
    onWebResourceErrorCallback: callbacksHandler.onWebResourceError,
    onNavigationRequestCallback: null,
  );

  /// Handles user interface elements for a webpage.
  @visibleForTesting
  late final WebViewCupertinoIosDelegate iosDelegate;

  /// Manages interactions between JavaScript code and your web view.
  late final web_kit.UserContentController userContentController;

  /// Encapsulates the standard behaviors to apply to websites.
  late final web_kit.Preferences preferences;

  /// Observes progress while a webpage is loading.
  final EstimatedProgressObserver progressObserver =
      EstimatedProgressObserver();

  final Completer<void> _initializationCompleter = Completer<void>();

  late bool _zoomEnabled = true;

  /// Represents the WebView maintained by platform code.
  late final web_kit.WebView webView;

  /// Handles callbacks that are made by [android_webview.WebViewClient], [android_webview.DownloadListener], and [android_webview.WebChromeClient].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// Handles constructing [android_webview.WebView]s and calling static methods.
  ///
  /// This should only be changed for testing purposes.
  final WebViewProxy webViewProxy;

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    return webView.loadHtmlString(html, baseUrl);
  }

  @override
  Future<void> loadFile(String absoluteFilePath) async {
    await webView.loadFileUrl(
      absoluteFilePath,
      path.dirname(absoluteFilePath),
    );
  }

  @override
  Future<void> loadFlutterAsset(String key) async {
    assert(key.isNotEmpty);
    return loadFile(path.join(
      (await applicationDocumentsDirectory).path,
      key,
    ));
  }

  @override
  Future<void> loadUrl(String url, Map<String, String>? headers) async {
    final UrlRequest request = UrlRequest(
      url: url,
      allHttpHeaderFields: headers ?? <String, String>{},
    );
    return webView.loadRequest(request);
  }

  @override
  Future<void> loadRequest(WebViewRequest request) async {
    if (!request.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }

    final UrlRequest urlRequest = UrlRequest(
      url: request.uri.toString(),
      allHttpHeaderFields: request.headers,
      httpMethod: describeEnum(request.method),
      httpBody: request.body,
    );

    return webView.loadRequest(urlRequest);
  }

  @override
  Future<String?> currentUrl() => webView.url;

  @override
  Future<bool> canGoBack() => webView.canGoBack;

  @override
  Future<bool> canGoForward() => webView.canGoForward;

  @override
  Future<void> goBack() => webView.goBack();

  @override
  Future<void> goForward() => webView.goForward();

  @override
  Future<void> reload() => webView.reload();

  @override
  Future<void> clearCache() {
    return dataStore.removeDataOfTypes(
      <web_kit.WebsiteDataTypes>{
        web_kit.WebsiteDataTypes.memoryCache,
        web_kit.WebsiteDataTypes.diskCache,
        web_kit.WebsiteDataTypes.offlineWebApplicationCache,
      },
      DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> updateSettings(WebSettings setting) async {
    _setUserAgent(setting.userAgent);
    if (setting.hasProgressTracking != null) {
      _setHasProgressTracking(setting.hasProgressTracking!);
    }
    if (setting.javascriptMode != null) {
      _setJavaScriptMode(setting.javascriptMode!);
    }
    if (setting.hasNavigationDelegate != null) {
      _setHasNavigationDelegate(setting.hasNavigationDelegate!);
    }
    if (setting.zoomEnabled != null) {
      return _setZoomEnabled(setting.zoomEnabled!);
    }
  }

  @override
  Future<String> evaluateJavascript(String javascript) async {
    return runJavascriptReturningResult(javascript);
  }

  @override
  Future<void> runJavascript(String javascript) async {
    await webView.evaluateJavaScript(javascript);
  }

  @override
  Future<String> runJavascriptReturningResult(String javascript) async {
    return await webView.evaluateJavaScript(javascript) ?? '';
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    return Future.wait(
      javascriptChannelNames.where(
        (String channelName) {
          return !_scriptMessageHandlers.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) {
          final WebViewCupertinoScriptMessageHandler handler =
              WebViewCupertinoScriptMessageHandler(javascriptChannelRegistry);
          _scriptMessageHandlers[channelName] = handler;
          final String wrapperSource =
              'window.$channelName = webkit.messageHandlers.$channelName;';
          final web_kit.UserScript wrapperScript = web_kit.UserScript(
            wrapperSource,
            web_kit.UserScriptInjectionTime.atDocumentStart,
            isMainFrameOnly: false,
          );
          userContentController.addUserScript(wrapperScript);
          return userContentController.addScriptMessageHandler(
            handler,
            channelName,
          );
        },
      ),
    );
  }

  @override
  Future<void> removeJavascriptChannels(
    Set<String> javascriptChannelNames,
  ) {
    // WkWebView does not support removing a single user script, so instead we remove all
    // user scripts, all message handlers. And re-register channels that shouldn't be removed.
    userContentController.removeAllUserScripts();
    userContentController.removeAllScriptMessageHandlers();

    javascriptChannelNames.forEach(_scriptMessageHandlers.remove);
    final Set<String> remainingNames = _scriptMessageHandlers.keys.toSet();
    _scriptMessageHandlers.clear();

    if (!_zoomEnabled) {
      _disableZoom();
    }

    return addJavascriptChannels(remainingNames);
  }

  @override
  Future<String?> getTitle() => webView.title;

  @override
  Future<void> scrollTo(int x, int y) async {
    final ios_kit.ScrollView scrollView = await webView.scrollView;
    scrollView.contentOffset = Point<double>(x.toDouble(), y.toDouble());
  }

  @override
  Future<void> scrollBy(int x, int y) async {
    final ios_kit.ScrollView scrollView = await webView.scrollView;
    final Point<double> offset = await scrollView.contentOffset;
    scrollView.contentOffset = Point<double>(
      offset.x + x.toDouble(),
      offset.y + y.toDouble(),
    );
  }

  @override
  Future<int> getScrollX() async {
    final ios_kit.ScrollView scrollView = await webView.scrollView;
    final Point<double> offset = await scrollView.contentOffset;
    return offset.x.toInt();
  }

  @override
  Future<int> getScrollY() async {
    final ios_kit.ScrollView scrollView = await webView.scrollView;
    final Point<double> offset = await scrollView.contentOffset;
    return offset.y.toInt();
  }

  void _setHasProgressTracking(bool hasProgressTracking) {
    if (hasProgressTracking) {
      progressObserver._onProgress = callbacksHandler.onProgress;
    } else {
      progressObserver._onProgress = null;
    }
  }

  void _setHasNavigationDelegate(bool hasNavigationDelegate) {
    if (hasNavigationDelegate) {
      navigationDelegate.onNavigationRequestCallback =
          callbacksHandler.onNavigationRequest;
      iosDelegate.onNavigationRequestCallback =
          callbacksHandler.onNavigationRequest;
    } else {
      navigationDelegate.onNavigationRequestCallback = null;
      iosDelegate.onNavigationRequestCallback = null;
    }
  }

  void _setJavaScriptMode(JavascriptMode mode) {
    switch (mode) {
      case JavascriptMode.disabled:
        preferences.javaScriptEnabled = false;
        break;
      case JavascriptMode.unrestricted:
        preferences.javaScriptEnabled = true;
        break;
    }
  }

  void _setUserAgent(WebSetting<String?> userAgent) {
    if (userAgent.isPresent) {
      webView.customUserAgent = userAgent.value;
    }
  }

  Future<void> _setZoomEnabled(bool zoomEnabled) async {
    if (_zoomEnabled == zoomEnabled) {
      return;
    }

    _zoomEnabled = zoomEnabled;
    if (!zoomEnabled) {
      return _disableZoom();
    } else {
      // WkWebView does not support removing a single user script, so instead we remove all
      // user scripts, all message handlers, and re-register channels that shouldn't be removed.
      return removeJavascriptChannels(<String>{});
    }
  }

  Future<void> _disableZoom() {
    final web_kit.UserScript userScript = web_kit.UserScript(
      "var meta = document.createElement('meta');"
      "meta.name = 'viewport';"
      "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0,"
      "user-scalable=no';"
      "var head = document.getElementsByTagName('head')[0];head.appendChild(meta);",
      web_kit.UserScriptInjectionTime.atDocumentEnd,
      isMainFrameOnly: true,
    );
    return userContentController.addUserScript(userScript);
  }

  Future<void> _setCreationParams(
    CreationParams params, {
    required web_kit.WebViewConfiguration configuration,
  }) async {
    addJavascriptChannels(params.javascriptChannelNames);

    await _setWebViewConfiguration(
      configuration,
      allowsInlineMediaPlayback: params.webSettings?.allowsInlineMediaPlayback,
      autoMediaPlaybackPolicy: params.autoMediaPlaybackPolicy,
    );

    webView = webViewProxy.createWebView(configuration);

    iosDelegate = WebViewCupertinoIosDelegate(
      onNavigationRequestCallback: null,
      loadRequest: webView.loadRequest,
    );
    webView.iosDelegate = iosDelegate;

    if (params.backgroundColor != null) {
      webView.opaque = false;
      webView.backgroundColor = material.Colors.transparent;
      webView.backgroundColor = params.backgroundColor!;
    }

    webView.customUserAgent = params.userAgent;
    webView.navigationDelegate = navigationDelegate;
    webView.iosDelegate = iosDelegate;
    webView.addObserver(
      progressObserver,
      EstimatedProgressObserver._keyPath,
      <KeyValueObservingOptions>{KeyValueObservingOptions.new_},
    );

    if (params.webSettings != null) {
      updateSettings(params.webSettings!);
    }

    if (params.initialUrl != null) {
      await loadUrl(params.initialUrl!, <String, String>{});
    }
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

    if (await systemVersion >= 10.0) {
      configuration.mediaTypesRequiringUserActionForPlayback =
          <web_kit.AudiovisualMediaType>{
        if (requiresUserAction) web_kit.AudiovisualMediaType.all,
        if (!requiresUserAction) web_kit.AudiovisualMediaType.none
      };
    } else if (await systemVersion >= 9.0) {
      configuration.requiresUserActionForMediaPlayback = requiresUserAction;
    } else {
      configuration.mediaPlaybackRequiresUserAction = requiresUserAction;
    }

    configuration.userContentController = userContentController;
    configuration.preferences = preferences;
  }
}

/// Observes changes to the `WebView.estimatedProgress` property.
class EstimatedProgressObserver extends FoundationObject {
  static const String _keyPath = 'estimatedProgress';

  // Changed by WebViewCupertinoPlatformController.
  void Function(int progress)? _onProgress;

  @override
  void observeValue(
    String keyPath,
    FoundationObject object,
    Map<KeyValueChangeKey, Object?> change,
  ) {
    assert(keyPath == _keyPath);
    if (_onProgress != null) {
      // Value between 0.0 and 1.0.
      final double progress = (change[KeyValueChangeKey.new_] as double?)!;
      _onProgress!((progress * 100).round());
    }
  }
}

/// Exposes a channel to receive calls from javaScript.
class WebViewCupertinoScriptMessageHandler
    extends web_kit.ScriptMessageHandler {
  /// Creates a [WebViewCupertinoScriptMessageHandler].
  WebViewCupertinoScriptMessageHandler(this.javascriptChannelRegistry);

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  @override
  void didReceiveScriptMessage(
    web_kit.UserContentController userContentController,
    web_kit.ScriptMessage message,
  ) {
    javascriptChannelRegistry.onJavascriptChannelMessage(
      message.name,
      message.body!.toString(),
    );
  }
}

/// Receives various navigation requests and errors for [WebViewCupertinoPlatformController].
///
/// When handling navigation requests, this calls [onNavigationRequestCallback]
/// when a [web_kit.WebView] attempts to navigate to a new page.
class WebViewCupertinoNavigationDelegate extends web_kit.NavigationDelegate {
  /// Creates a [WebViewCupertinoNavigationDelegate] that handles navigation requests.
  WebViewCupertinoNavigationDelegate({
    required this.onPageStartedCallback,
    required this.onPageFinishedCallback,
    required this.onWebResourceErrorCallback,
    required this.onNavigationRequestCallback,
  });

  /// Callback from [web_kit.NavigationDelegate].didStartProvisionalNavigation.
  final void Function(String url) onPageStartedCallback;

  /// Callback from [web_kit.NavigationDelegate].didFinishNavigation.
  final void Function(String url) onPageFinishedCallback;

  /// When [web_kit.NavigationDelegate] receives an error callback.
  void Function(WebResourceError error) onWebResourceErrorCallback;

  /// Checks whether a navigation request should be approved or disaproved.
  FutureOr<bool> Function({
    required String url,
    required bool isForMainFrame,
  })? onNavigationRequestCallback;

  static WebResourceErrorType? _toErrorType(int errorCode) {
    switch (errorCode) {
      case web_kit.WebKitError.unknown:
        return WebResourceErrorType.unknown;
      case web_kit.WebKitError.webContentProcessTerminated:
        return WebResourceErrorType.webContentProcessTerminated;
      case web_kit.WebKitError.webViewInvalidated:
        return WebResourceErrorType.webViewInvalidated;
      case web_kit.WebKitError.javaScriptExceptionOccurred:
        return WebResourceErrorType.javaScriptExceptionOccurred;
      case web_kit.WebKitError.javaScriptResultTypeIsUnsupported:
        return WebResourceErrorType.javaScriptResultTypeIsUnsupported;
    }

    return null;
  }

  @override
  void didStartProvisionalNavigation(web_kit.WebView webView) {
    webView.url.then((String? url) => onPageStartedCallback(url ?? ''));
  }

  @override
  void didFinishNavigation(web_kit.WebView webView) {
    webView.url.then((String? url) => onPageFinishedCallback(url ?? ''));
  }

  @override
  void didFailNavigation(web_kit.WebView webView, FoundationError error) {
    onWebResourceErrorCallback(WebResourceError(
      errorCode: error.code,
      domain: error.domain,
      description: error.localizedDescription,
      errorType: _toErrorType(error.code),
    ));
  }

  @override
  void didFailProvisionalNavigation(
    web_kit.WebView webView,
    FoundationError error,
  ) {
    onWebResourceErrorCallback(WebResourceError(
      errorCode: error.code,
      domain: error.domain,
      description: error.localizedDescription,
      errorType: _toErrorType(error.code),
    ));
  }

  @override
  void webViewWebContentProcessDidTerminate(web_kit.WebView webView) {
    onWebResourceErrorCallback(WebResourceError(
      errorCode: web_kit.WebKitError.webContentProcessTerminated,
      // Value from https://developer.apple.com/documentation/web_kit/wkerrordomain?language=objc
      domain: 'WKErrorDomain',
      description: '',
      errorType: WebResourceErrorType.webContentProcessTerminated,
    ));
  }

  @override
  Future<web_kit.NavigationActionPolicy> decidePolicyForNavigationAction(
    web_kit.WebView webView,
    web_kit.NavigationAction navigationAction,
  ) async {
    if (onNavigationRequestCallback == null) {
      return web_kit.NavigationActionPolicy.allow;
    }

    final bool allow = await onNavigationRequestCallback!(
      url: navigationAction.request.url,
      isForMainFrame: navigationAction.targetFrame.isMainFrame,
    );

    if (allow) {
      return web_kit.NavigationActionPolicy.allow;
    } else {
      return web_kit.NavigationActionPolicy.cancel;
    }
  }
}

/// The methods for presenting native user interface elements on behalf of a webpage.
///
/// When handling navigation requests, this calls [onNavigationRequestCallback]
/// when a [web_kit.WebView] attempts to navigate to a new page.
class WebViewCupertinoIosDelegate extends web_kit.IosDelegate {
  /// Creates a [WebViewCupertinoIosDelegate] that handles navigation requests.
  WebViewCupertinoIosDelegate({
    required Future<void> Function(UrlRequest request) loadRequest,
    this.onNavigationRequestCallback,
  }) : _loadRequest = loadRequest;

  final Future<void> Function(UrlRequest request) _loadRequest;

  /// Checks whether a navigation request should be approved or disaproved.
  FutureOr<bool> Function({
    required String url,
    required bool isForMainFrame,
  })? onNavigationRequestCallback;

  @override
  void onCreateWebView(
    web_kit.WebViewConfiguration configuration,
    web_kit.NavigationAction navigationAction,
  ) {
    if (!navigationAction.targetFrame.isMainFrame) {
      _loadRequest(navigationAction.request);
    }
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
