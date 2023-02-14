// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:async';

// TODO(a14n): remove this import once Flutter 3.1 or later reaches stable (including flutter/flutter#104231)
// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'android_proxy.dart';
import 'android_webview.dart' as android_webview;
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

    _webView.setWebChromeClient(_webChromeClient);
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

  late final android_webview.WebChromeClient _webChromeClient =
      _androidWebViewParams.androidWebViewProxy.createAndroidWebChromeClient(
    onProgressChanged: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (android_webview.WebView webView, int progress) {
        if (weakReference.target?._currentNavigationDelegate?._onProgress !=
            null) {
          weakReference
              .target!._currentNavigationDelegate!._onProgress!(progress);
        }
      };
    }),
    onShowFileChooser: withWeakReferenceTo(this,
        (WeakReference<AndroidWebViewController> weakReference) {
      return (android_webview.WebView webView,
          android_webview.FileChooserParams params) async {
        if (weakReference.target?._onShowFileSelectorCallback != null) {
          return weakReference.target!._onShowFileSelectorCallback!(
            FileSelectorParams._fromFileChooserParams(params),
          );
        }
        return <String>[];
      };
    }),
  );

  /// The native [android_webview.FlutterAssetManager] allows managing assets.
  late final android_webview.FlutterAssetManager _flutterAssetManager =
      _androidWebViewParams.androidWebViewProxy.createFlutterAssetManager();

  final Map<String, AndroidJavaScriptChannelParams> _javaScriptChannelParams =
      <String, AndroidJavaScriptChannelParams>{};

  AndroidNavigationDelegate? _currentNavigationDelegate;

  Future<List<String>> Function(FileSelectorParams)?
      _onShowFileSelectorCallback;

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

  /// Identifier used to retrieve the underlying native `WKWebView`.
  ///
  /// This is typically used by other plugins to retrieve the native `WebView`
  /// from an `InstanceManager`.
  ///
  /// See Java method `WebViewFlutterPlugin.getWebView`.
  int get webViewIdentifier =>
      // ignore: invalid_use_of_visible_for_testing_member
      android_webview.WebView.api.instanceManager.getIdentifier(_webView)!;

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
    }
    // The enum comes from a different package, which could get a new value at
    // any time, so a fallback case is necessary. Since there is no reasonable
    // default behavior, throw to alert the client that they need an updated
    // version. This is deliberately outside the switch rather than a `default`
    // so that the linter will flag the switch as needing an update.
    // ignore: dead_code
    throw UnimplementedError(
        'This version of `AndroidWebViewController` currently has no '
        'implementation for HTTP method ${params.method.serialize()} in '
        'loadRequest.');
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

  /// Sets the callback that is invoked when the client should show a file
  /// selector.
  Future<void> setOnShowFileSelector(
    Future<List<String>> Function(FileSelectorParams params)?
        onShowFileSelector,
  ) {
    _onShowFileSelectorCallback = onShowFileSelector;
    return _webChromeClient.setSynchronousReturnValueForOnShowFileChooser(
      onShowFileSelector != null,
    );
  }
}

/// Mode of how to select files for a file chooser.
enum FileSelectorMode {
  /// Open single file and requires that the file exists before allowing the
  /// user to pick it.
  open,

  /// Similar to [open] but allows multiple files to be selected.
  openMultiple,

  /// Allows picking a nonexistent file and saving it.
  save,
}

/// Parameters received when the `WebView` should show a file selector.
@immutable
class FileSelectorParams {
  /// Constructs a [FileSelectorParams].
  const FileSelectorParams({
    required this.isCaptureEnabled,
    required this.acceptTypes,
    this.filenameHint,
    required this.mode,
  });

  factory FileSelectorParams._fromFileChooserParams(
    android_webview.FileChooserParams params,
  ) {
    final FileSelectorMode mode;
    switch (params.mode) {
      case android_webview.FileChooserMode.open:
        mode = FileSelectorMode.open;
        break;
      case android_webview.FileChooserMode.openMultiple:
        mode = FileSelectorMode.openMultiple;
        break;
      case android_webview.FileChooserMode.save:
        mode = FileSelectorMode.save;
        break;
    }

    return FileSelectorParams(
      isCaptureEnabled: params.isCaptureEnabled,
      acceptTypes: params.acceptTypes,
      mode: mode,
      filenameHint: params.filenameHint,
    );
  }

  /// Preference for a live media captured value (e.g. Camera, Microphone).
  final bool isCaptureEnabled;

  /// A list of acceptable MIME types.
  final List<String> acceptTypes;

  /// The file name of a default selection if specified, or null.
  final String? filenameHint;

  /// Mode of how to select files for a file selector.
  final FileSelectorMode mode;
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
          postMessage: withWeakReferenceTo(
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
  }) : instanceManager =
            instanceManager ?? android_webview.JavaObject.globalInstanceManager;

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

/// Signature for the `loadRequest` callback responsible for loading the [url]
/// after a navigation request has been approved.
typedef LoadRequestCallback = Future<void> Function(LoadRequestParams params);

/// Error returned in `WebView.onWebResourceError` when a web resource loading error has occurred.
@immutable
class AndroidWebResourceError extends WebResourceError {
  /// Creates a new [AndroidWebResourceError].
  AndroidWebResourceError._({
    required super.errorCode,
    required super.description,
    super.isForMainFrame,
    this.failingUrl,
  }) : super(
          errorType: _errorCodeToErrorType(errorCode),
        );

  /// Gets the URL for which the failing resource request was made.
  final String? failingUrl;

  static WebResourceErrorType? _errorCodeToErrorType(int errorCode) {
    switch (errorCode) {
      case android_webview.WebViewClient.errorAuthentication:
        return WebResourceErrorType.authentication;
      case android_webview.WebViewClient.errorBadUrl:
        return WebResourceErrorType.badUrl;
      case android_webview.WebViewClient.errorConnect:
        return WebResourceErrorType.connect;
      case android_webview.WebViewClient.errorFailedSslHandshake:
        return WebResourceErrorType.failedSslHandshake;
      case android_webview.WebViewClient.errorFile:
        return WebResourceErrorType.file;
      case android_webview.WebViewClient.errorFileNotFound:
        return WebResourceErrorType.fileNotFound;
      case android_webview.WebViewClient.errorHostLookup:
        return WebResourceErrorType.hostLookup;
      case android_webview.WebViewClient.errorIO:
        return WebResourceErrorType.io;
      case android_webview.WebViewClient.errorProxyAuthentication:
        return WebResourceErrorType.proxyAuthentication;
      case android_webview.WebViewClient.errorRedirectLoop:
        return WebResourceErrorType.redirectLoop;
      case android_webview.WebViewClient.errorTimeout:
        return WebResourceErrorType.timeout;
      case android_webview.WebViewClient.errorTooManyRequests:
        return WebResourceErrorType.tooManyRequests;
      case android_webview.WebViewClient.errorUnknown:
        return WebResourceErrorType.unknown;
      case android_webview.WebViewClient.errorUnsafeResource:
        return WebResourceErrorType.unsafeResource;
      case android_webview.WebViewClient.errorUnsupportedAuthScheme:
        return WebResourceErrorType.unsupportedAuthScheme;
      case android_webview.WebViewClient.errorUnsupportedScheme:
        return WebResourceErrorType.unsupportedScheme;
    }

    throw ArgumentError(
      'Could not find a WebResourceErrorType for errorCode: $errorCode',
    );
  }
}

/// Object specifying creation parameters for creating a [AndroidNavigationDelegate].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformNavigationDelegateCreationParams] for
/// more information.
@immutable
class AndroidNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  /// Creates a new [AndroidNavigationDelegateCreationParams] instance.
  const AndroidNavigationDelegateCreationParams._({
    @visibleForTesting this.androidWebViewProxy = const AndroidWebViewProxy(),
  }) : super();

  /// Creates a [AndroidNavigationDelegateCreationParams] instance based on [PlatformNavigationDelegateCreationParams].
  factory AndroidNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformNavigationDelegateCreationParams params, {
    @visibleForTesting
        AndroidWebViewProxy androidWebViewProxy = const AndroidWebViewProxy(),
  }) {
    return AndroidNavigationDelegateCreationParams._(
      androidWebViewProxy: androidWebViewProxy,
    );
  }

  /// Handles constructing objects and calling static methods for the Android WebView
  /// native library.
  @visibleForTesting
  final AndroidWebViewProxy androidWebViewProxy;
}

/// A place to register callback methods responsible to handle navigation events
/// triggered by the [android_webview.WebView].
class AndroidNavigationDelegate extends PlatformNavigationDelegate {
  /// Creates a new [AndroidNavigationDelegate].
  AndroidNavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params is AndroidNavigationDelegateCreationParams
            ? params
            : AndroidNavigationDelegateCreationParams
                .fromPlatformNavigationDelegateCreationParams(params)) {
    final WeakReference<AndroidNavigationDelegate> weakThis =
        WeakReference<AndroidNavigationDelegate>(this);

    _webViewClient = (this.params as AndroidNavigationDelegateCreationParams)
        .androidWebViewProxy
        .createAndroidWebViewClient(
      onPageFinished: (android_webview.WebView webView, String url) {
        if (weakThis.target?._onPageFinished != null) {
          weakThis.target!._onPageFinished!(url);
        }
      },
      onPageStarted: (android_webview.WebView webView, String url) {
        if (weakThis.target?._onPageStarted != null) {
          weakThis.target!._onPageStarted!(url);
        }
      },
      onReceivedRequestError: (
        android_webview.WebView webView,
        android_webview.WebResourceRequest request,
        android_webview.WebResourceError error,
      ) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(AndroidWebResourceError._(
            errorCode: error.errorCode,
            description: error.description,
            failingUrl: request.url,
            isForMainFrame: request.isForMainFrame,
          ));
        }
      },
      onReceivedError: (
        android_webview.WebView webView,
        int errorCode,
        String description,
        String failingUrl,
      ) {
        if (weakThis.target?._onWebResourceError != null) {
          weakThis.target!._onWebResourceError!(AndroidWebResourceError._(
            errorCode: errorCode,
            description: description,
            failingUrl: failingUrl,
            isForMainFrame: true,
          ));
        }
      },
      requestLoading: (
        android_webview.WebView webView,
        android_webview.WebResourceRequest request,
      ) {
        if (weakThis.target != null) {
          weakThis.target!._handleNavigation(
            request.url,
            headers: request.requestHeaders,
            isForMainFrame: request.isForMainFrame,
          );
        }
      },
      urlLoading: (
        android_webview.WebView webView,
        String url,
      ) {
        if (weakThis.target != null) {
          weakThis.target!._handleNavigation(url, isForMainFrame: true);
        }
      },
    );

    _downloadListener = (this.params as AndroidNavigationDelegateCreationParams)
        .androidWebViewProxy
        .createDownloadListener(
      onDownloadStart: (
        String url,
        String userAgent,
        String contentDisposition,
        String mimetype,
        int contentLength,
      ) {
        if (weakThis.target != null) {
          weakThis.target?._handleNavigation(url, isForMainFrame: true);
        }
      },
    );
  }

  AndroidNavigationDelegateCreationParams get _androidParams =>
      params as AndroidNavigationDelegateCreationParams;

  late final android_webview.WebChromeClient _webChromeClient =
      _androidParams.androidWebViewProxy.createAndroidWebChromeClient();

  /// Gets the native [android_webview.WebChromeClient] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setWebChromeClient`.
  @Deprecated(
    'This value is not used by `AndroidWebViewController` and has no effect on the `WebView`.',
  )
  android_webview.WebChromeClient get androidWebChromeClient =>
      _webChromeClient;

  late final android_webview.WebViewClient _webViewClient;

  /// Gets the native [android_webview.WebViewClient] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setWebViewClient`.
  android_webview.WebViewClient get androidWebViewClient => _webViewClient;

  late final android_webview.DownloadListener _downloadListener;

  /// Gets the native [android_webview.DownloadListener] that is bridged by this [AndroidNavigationDelegate].
  ///
  /// Used by the [AndroidWebViewController] to set the `android_webview.WebView.setDownloadListener`.
  android_webview.DownloadListener get androidDownloadListener =>
      _downloadListener;

  PageEventCallback? _onPageFinished;
  PageEventCallback? _onPageStarted;
  ProgressCallback? _onProgress;
  WebResourceErrorCallback? _onWebResourceError;
  NavigationRequestCallback? _onNavigationRequest;
  LoadRequestCallback? _onLoadRequest;

  void _handleNavigation(
    String url, {
    required bool isForMainFrame,
    Map<String, String> headers = const <String, String>{},
  }) {
    final LoadRequestCallback? onLoadRequest = _onLoadRequest;
    final NavigationRequestCallback? onNavigationRequest = _onNavigationRequest;

    if (onNavigationRequest == null || onLoadRequest == null) {
      return;
    }

    final FutureOr<NavigationDecision> returnValue = onNavigationRequest(
      NavigationRequest(
        url: url,
        isMainFrame: isForMainFrame,
      ),
    );

    if (returnValue is NavigationDecision &&
        returnValue == NavigationDecision.navigate) {
      onLoadRequest(LoadRequestParams(
        uri: Uri.parse(url),
        headers: headers,
      ));
    } else if (returnValue is Future<NavigationDecision>) {
      returnValue.then((NavigationDecision shouldLoadUrl) {
        if (shouldLoadUrl == NavigationDecision.navigate) {
          onLoadRequest(LoadRequestParams(
            uri: Uri.parse(url),
            headers: headers,
          ));
        }
      });
    }
  }

  /// Invoked when loading the url after a navigation request is approved.
  Future<void> setOnLoadRequest(
    LoadRequestCallback onLoadRequest,
  ) async {
    _onLoadRequest = onLoadRequest;
  }

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    _onNavigationRequest = onNavigationRequest;
    _webViewClient.setSynchronousReturnValueForShouldOverrideUrlLoading(true);
  }

  @override
  Future<void> setOnPageStarted(
    PageEventCallback onPageStarted,
  ) async {
    _onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnPageFinished(
    PageEventCallback onPageFinished,
  ) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnProgress(
    ProgressCallback onProgress,
  ) async {
    _onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    _onWebResourceError = onWebResourceError;
  }
}
