// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'foundation/foundation.dart';
import 'web_kit/web_kit.dart';

/// A [Widget] that displays a [WKWebView].
class WebKitWebViewWidget extends StatefulWidget {
  /// Constructs a [WebKitWebViewWidget].
  const WebKitWebViewWidget({
    required this.creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    required this.onBuildWidget,
    this.configuration,
    @visibleForTesting this.webViewProxy = const WebViewWidgetProxy(),
  });

  /// The initial parameters used to setup the WebView.
  final CreationParams creationParams;

  /// The handler of callbacks made made by [NavigationDelegate].
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manager of named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// A collection of properties used to initialize a web view.
  ///
  /// If null, a default configuration is used.
  final WKWebViewConfiguration? configuration;

  /// The handler for constructing [WKWebView]s and calling static methods.
  ///
  /// This should only be changed for testing purposes.
  final WebViewWidgetProxy webViewProxy;

  /// A callback to build a widget once [WKWebView] has been initialized.
  final Widget Function(WebKitWebViewPlatformController controller)
      onBuildWidget;

  @override
  State<StatefulWidget> createState() => _WebKitWebViewWidgetState();
}

class _WebKitWebViewWidgetState extends State<WebKitWebViewWidget> {
  late final WebKitWebViewPlatformController controller;

  @override
  void initState() {
    super.initState();
    controller = WebKitWebViewPlatformController(
      creationParams: widget.creationParams,
      callbacksHandler: widget.callbacksHandler,
      javascriptChannelRegistry: widget.javascriptChannelRegistry,
      configuration: widget.configuration,
      webViewProxy: widget.webViewProxy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.onBuildWidget(controller);
  }
}

/// An implementation of [WebViewPlatformController] with the WebKit api.
class WebKitWebViewPlatformController extends WebViewPlatformController {
  /// Construct a [WebKitWebViewPlatformController].
  WebKitWebViewPlatformController({
    required CreationParams creationParams,
    required this.callbacksHandler,
    required this.javascriptChannelRegistry,
    WKWebViewConfiguration? configuration,
    @visibleForTesting this.webViewProxy = const WebViewWidgetProxy(),
  }) : super(callbacksHandler) {
    _setCreationParams(
      creationParams,
      configuration: configuration ??
          WKWebViewConfiguration(
            userContentController: WKUserContentController(),
          ),
    );

    webView.setUIDelegate(uiDelegate);
    uiDelegate.setOnCreateWebView((
      WKWebViewConfiguration configuration,
      WKNavigationAction navigationAction,
    ) {
      if (!navigationAction.targetFrame.isMainFrame) {
        webView.loadRequest(navigationAction.request);
      }
    });
  }

  final Map<String, WKScriptMessageHandler> _scriptMessageHandlers =
      <String, WKScriptMessageHandler>{};

  /// Handles callbacks that are made by navigation.
  final WebViewPlatformCallbacksHandler callbacksHandler;

  /// Manages named JavaScript channels and forwarding incoming messages on the correct channel.
  final JavascriptChannelRegistry javascriptChannelRegistry;

  /// Handles constructing a [WKWebView].
  ///
  /// This should only be changed when used for testing.
  final WebViewWidgetProxy webViewProxy;

  /// Represents the WebView maintained by platform code.
  late final WKWebView webView;

  /// Used to integrate custom user interface elements into web view interactions.
  @visibleForTesting
  late final WKUIDelegate uiDelegate = webViewProxy.createUIDelgate();

  /// Methods for handling navigation changes and tracking navigation requests.
  @visibleForTesting
  late final WKNavigationDelegate navigationDelegate =
      webViewProxy.createNavigationDelegate()
        ..setDidStartProvisionalNavigation((WKWebView webView, String? url) {
          callbacksHandler.onPageStarted(url ?? '');
        })
        ..setDidFinishNavigation((WKWebView webView, String? url) {
          callbacksHandler.onPageFinished(url ?? '');
        })
        ..setDidFailNavigation((WKWebView webView, NSError error) {
          callbacksHandler.onWebResourceError(_toWebResourceError(error));
        })
        ..setDidFailProvisionalNavigation((WKWebView webView, NSError error) {
          callbacksHandler.onWebResourceError(_toWebResourceError(error));
        })
        ..setWebViewWebContentProcessDidTerminate((WKWebView webView) {
          callbacksHandler.onWebResourceError(WebResourceError(
            errorCode: WKErrorCode.webContentProcessTerminated,
            // Value from https://developer.apple.com/documentation/webkit/wkerrordomain?language=objc.
            domain: 'WKErrorDomain',
            description: '',
            errorType: WebResourceErrorType.webContentProcessTerminated,
          ));
        });

  Future<void> _setCreationParams(
    CreationParams params, {
    required WKWebViewConfiguration configuration,
  }) async {
    _setWebViewConfiguration(
      configuration,
      allowsInlineMediaPlayback: params.webSettings?.allowsInlineMediaPlayback,
      autoMediaPlaybackPolicy: params.autoMediaPlaybackPolicy,
    );

    webView = webViewProxy.createWebView(configuration);

    await addJavascriptChannels(params.javascriptChannelNames);

    webView.setNavigationDelegate(navigationDelegate);

    if (params.webSettings != null) {
      updateSettings(params.webSettings!);
    }
  }

  void _setWebViewConfiguration(
    WKWebViewConfiguration configuration, {
    required bool? allowsInlineMediaPlayback,
    required AutoMediaPlaybackPolicy autoMediaPlaybackPolicy,
  }) {
    if (allowsInlineMediaPlayback != null) {
      configuration.setAllowsInlineMediaPlayback(allowsInlineMediaPlayback);
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

    configuration
        .setMediaTypesRequiringUserActionForPlayback(<WKAudiovisualMediaType>{
      if (requiresUserAction) WKAudiovisualMediaType.all,
      if (!requiresUserAction) WKAudiovisualMediaType.none,
    });
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    return webView.loadHtmlString(html, baseUrl: baseUrl);
  }

  @override
  Future<void> loadFile(String absoluteFilePath) async {
    await webView.loadFileUrl(
      absoluteFilePath,
      readAccessUrl: path.dirname(absoluteFilePath),
    );
  }

  @override
  Future<void> clearCache() {
    return webView.configuration.webSiteDataStore.removeDataOfTypes(
      <WKWebsiteDataTypes>{
        WKWebsiteDataTypes.memoryCache,
        WKWebsiteDataTypes.diskCache,
        WKWebsiteDataTypes.offlineWebApplicationCache,
        WKWebsiteDataTypes.localStroage,
      },
      DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  @override
  Future<void> loadFlutterAsset(String key) async {
    assert(key.isNotEmpty);
    return webView.loadFlutterAsset(key);
  }

  @override
  Future<void> loadUrl(String url, Map<String, String>? headers) async {
    final NSUrlRequest request = NSUrlRequest(
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

    final NSUrlRequest urlRequest = NSUrlRequest(
      url: request.uri.toString(),
      allHttpHeaderFields: request.headers,
      httpMethod: describeEnum(request.method),
      httpBody: request.body,
    );

    return webView.loadRequest(urlRequest);
  }

  @override
  Future<bool> canGoBack() => webView.canGoBack();

  @override
  Future<bool> canGoForward() => webView.canGoForward();

  @override
  Future<void> goBack() => webView.goBack();

  @override
  Future<void> goForward() => webView.goForward();

  @override
  Future<void> reload() => webView.reload();

  @override
  Future<String> evaluateJavascript(String javascript) async {
    final Object? result = await webView.evaluateJavaScript(javascript);
    // The legacy implementation of webview_flutter_wkwebview would convert
    // objects to strings before returning them to Dart. This method attempts
    // to converts Dart objects to Strings the way it is done in Objective-C
    // to avoid breaking users expecting the same String format.
    return _asObjectiveCString(result);
  }

  @override
  Future<void> runJavascript(String javascript) async {
    try {
      await webView.evaluateJavaScript(javascript);
    } on PlatformException catch (exception) {
      // WebKit will throw an error when the type of the evaluated value is
      // unsupported. This also goes for `null` and `undefined` on iOS 14+. For
      // example, when running a void function. For ease of use, this specific
      // error is ignored when no return value is expected.
      // TODO(bparrishMines): Ensure the platform code includes the NSError in
      // the FlutterError.details.
      if (exception.details is! NSError ||
          exception.details.code !=
              WKErrorCode.javaScriptResultTypeIsUnsupported) {
        rethrow;
      }
    }
  }

  @override
  Future<String> runJavascriptReturningResult(String javascript) async {
    final Object? result = await webView.evaluateJavaScript(javascript);
    if (result == null) {
      throw ArgumentError(
        'Result of JavaScript execution returned a `null` value. '
        'Use `runJavascript` when expecting a null return value.',
      );
    }
    return result.toString();
  }

  @override
  Future<String?> getTitle() => webView.getTitle();

  @override
  Future<void> scrollTo(int x, int y) async {
    webView.scrollView.setContentOffset(Point<double>(
      x.toDouble(),
      y.toDouble(),
    ));
  }

  @override
  Future<void> scrollBy(int x, int y) async {
    await webView.scrollView.scrollBy(Point<double>(
      x.toDouble(),
      y.toDouble(),
    ));
  }

  @override
  Future<int> getScrollX() async {
    final Point<double> offset = await webView.scrollView.getContentOffset();
    return offset.x.toInt();
  }

  @override
  Future<int> getScrollY() async {
    final Point<double> offset = await webView.scrollView.getContentOffset();
    return offset.y.toInt();
  }

  @override
  Future<void> updateSettings(WebSettings setting) async {
    if (setting.hasNavigationDelegate != null) {
      _setHasNavigationDelegate(setting.hasNavigationDelegate!);
    }
    if (setting.hasProgressTracking != null) {
      _setHasProgressTracking(setting.hasProgressTracking!);
    }
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) async {
    await Future.wait<void>(
      javascriptChannelNames.where(
        (String channelName) {
          return !_scriptMessageHandlers.containsKey(channelName);
        },
      ).map<Future<void>>(
        (String channelName) {
          final WKScriptMessageHandler handler =
              webViewProxy.createScriptMessageHandler()
                ..setDidReceiveScriptMessage((
                  WKUserContentController userContentController,
                  WKScriptMessage message,
                ) {
                  javascriptChannelRegistry.onJavascriptChannelMessage(
                    message.name,
                    message.body!.toString(),
                  );
                });
          _scriptMessageHandlers[channelName] = handler;

          final String wrapperSource =
              'window.$channelName = webkit.messageHandlers.$channelName;';
          final WKUserScript wrapperScript = WKUserScript(
            wrapperSource,
            WKUserScriptInjectionTime.atDocumentStart,
            isMainFrameOnly: false,
          );
          webView.configuration.userContentController
              .addUserScript(wrapperScript);
          return webView.configuration.userContentController
              .addScriptMessageHandler(
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
  ) async {
    if (javascriptChannelNames.isEmpty) {
      return;
    }

    // WKWebView does not support removing a single user script, so this removes
    // all user scripts and all message handlers and re-registers channels that
    // shouldn't be removed. Note that this workaround could interfere with
    // exposing support for custom scripts from applications.
    webView.configuration.userContentController.removeAllUserScripts();
    webView.configuration.userContentController
        .removeAllScriptMessageHandlers();

    javascriptChannelNames.forEach(_scriptMessageHandlers.remove);
    final Set<String> remainingNames = _scriptMessageHandlers.keys.toSet();
    _scriptMessageHandlers.clear();

    await addJavascriptChannels(remainingNames);
  }

  void _setHasNavigationDelegate(bool hasNavigationDelegate) {
    if (hasNavigationDelegate) {
      navigationDelegate.setDecidePolicyForNavigationAction(
          (WKWebView webView, WKNavigationAction action) async {
        final bool allow = await callbacksHandler.onNavigationRequest(
          url: action.request.url,
          isForMainFrame: action.targetFrame.isMainFrame,
        );

        return allow
            ? WKNavigationActionPolicy.allow
            : WKNavigationActionPolicy.cancel;
      });
    } else {
      navigationDelegate.setDecidePolicyForNavigationAction(null);
    }
  }

  Future<void> _setHasProgressTracking(bool hasProgressTracking) {
    if (hasProgressTracking) {
      webView.observeValue = (
        String keyPath,
        NSObject object,
        Map<NSKeyValueChangeKey, Object?> change,
      ) {
        final double progress = change[NSKeyValueChangeKey.newValue]! as double;
        callbacksHandler.onProgress((progress * 100).round());
      };
      return webView.addObserver(
        webView,
        keyPath: 'estimatedProgress',
        options: <NSKeyValueObservingOptions>{
          NSKeyValueObservingOptions.newValue,
        },
      );
    } else {
      webView.observeValue = null;
      return webView.removeObserver(webView, keyPath: 'estimatedProgress');
    }
  }

  static WebResourceError _toWebResourceError(NSError error) {
    WebResourceErrorType? errorType;

    switch (error.code) {
      case WKErrorCode.unknown:
        errorType = WebResourceErrorType.unknown;
        break;
      case WKErrorCode.webContentProcessTerminated:
        errorType = WebResourceErrorType.webContentProcessTerminated;
        break;
      case WKErrorCode.webViewInvalidated:
        errorType = WebResourceErrorType.webViewInvalidated;
        break;
      case WKErrorCode.javaScriptExceptionOccurred:
        errorType = WebResourceErrorType.javaScriptExceptionOccurred;
        break;
      case WKErrorCode.javaScriptResultTypeIsUnsupported:
        errorType = WebResourceErrorType.javaScriptResultTypeIsUnsupported;
        break;
    }

    return WebResourceError(
      errorCode: error.code,
      domain: error.domain,
      description: error.localizedDescription,
      errorType: errorType,
    );
  }

  String _asObjectiveCString(Object? value, {bool inContainer = false}) {
    if (value == null) {
      // An NSNull inside an NSArray or NSDictionary is represented as a String
      // differently than a nil.
      if (inContainer) {
        return '"<null>"';
      }
      return '(null)';
    } else if (value is List) {
      final List<String> stringValues = <String>[];
      for (final Object? listValue in value) {
        stringValues.add(_asObjectiveCString(listValue, inContainer: true));
      }
      return '(${stringValues.join(',')})';
    } else if (value is Map) {
      final List<String> stringValues = <String>[];
      for (final MapEntry<Object?, Object?> entry in value.entries) {
        stringValues.add(
          '${_asObjectiveCString(entry.key, inContainer: true)} '
          '= '
          '${_asObjectiveCString(entry.value, inContainer: true)}',
        );
      }
      return '{${stringValues.join(';')}}';
    }

    return value.toString();
  }
}

/// Handles constructing objects and calling static methods.
///
/// This should only be used for testing purposes.
@visibleForTesting
class WebViewWidgetProxy {
  /// Constructs a [WebViewWidgetProxy].
  const WebViewWidgetProxy();

  /// Constructs a [WKWebView].
  WKWebView createWebView(WKWebViewConfiguration configuration) {
    return WKWebView(configuration);
  }

  /// Constructs a [WKScriptMessageHandler].
  WKScriptMessageHandler createScriptMessageHandler() {
    return WKScriptMessageHandler();
  }

  /// Constructs a [WKUIDelegate].
  WKUIDelegate createUIDelgate() {
    return WKUIDelegate();
  }

  /// Constructs a [WKNavigationDelegate].
  WKNavigationDelegate createNavigationDelegate() {
    return WKNavigationDelegate();
  }
}
