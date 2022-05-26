// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.pigeon.dart';
import '../foundation/foundation.dart';
import 'web_kit.dart';

Iterable<WKWebsiteDataTypeEnumData> _toWKWebsiteDataTypeEnumData(
    Iterable<WKWebsiteDataType> types) {
  return types.map<WKWebsiteDataTypeEnumData>((WKWebsiteDataType type) {
    late final WKWebsiteDataTypeEnum value;
    switch (type) {
      case WKWebsiteDataType.cookies:
        value = WKWebsiteDataTypeEnum.cookies;
        break;
      case WKWebsiteDataType.memoryCache:
        value = WKWebsiteDataTypeEnum.memoryCache;
        break;
      case WKWebsiteDataType.diskCache:
        value = WKWebsiteDataTypeEnum.diskCache;
        break;
      case WKWebsiteDataType.offlineWebApplicationCache:
        value = WKWebsiteDataTypeEnum.offlineWebApplicationCache;
        break;
      case WKWebsiteDataType.localStorage:
        value = WKWebsiteDataTypeEnum.localStorage;
        break;
      case WKWebsiteDataType.sessionStorage:
        value = WKWebsiteDataTypeEnum.sessionStorage;
        break;
      case WKWebsiteDataType.webSQLDatabases:
        value = WKWebsiteDataTypeEnum.webSQLDatabases;
        break;
      case WKWebsiteDataType.indexedDBDatabases:
        value = WKWebsiteDataTypeEnum.indexedDBDatabases;
        break;
    }

    return WKWebsiteDataTypeEnumData(value: value);
  });
}

extension _NSHttpCookieConverter on NSHttpCookie {
  NSHttpCookieData toNSHttpCookieData() {
    final Iterable<NSHttpCookiePropertyKey> keys = properties.keys;
    return NSHttpCookieData(
      propertyKeys: keys.map<NSHttpCookiePropertyKeyEnumData>(
        (NSHttpCookiePropertyKey key) {
          return key.toNSHttpCookiePropertyKeyEnumData();
        },
      ).toList(),
      propertyValues: keys
          .map<Object>((NSHttpCookiePropertyKey key) => properties[key]!)
          .toList(),
    );
  }
}

extension _NSHttpCookiePropertyKeyConverter on NSHttpCookiePropertyKey {
  NSHttpCookiePropertyKeyEnumData toNSHttpCookiePropertyKeyEnumData() {
    late final NSHttpCookiePropertyKeyEnum value;
    switch (this) {
      case NSHttpCookiePropertyKey.comment:
        value = NSHttpCookiePropertyKeyEnum.comment;
        break;
      case NSHttpCookiePropertyKey.commentUrl:
        value = NSHttpCookiePropertyKeyEnum.commentUrl;
        break;
      case NSHttpCookiePropertyKey.discard:
        value = NSHttpCookiePropertyKeyEnum.discard;
        break;
      case NSHttpCookiePropertyKey.domain:
        value = NSHttpCookiePropertyKeyEnum.domain;
        break;
      case NSHttpCookiePropertyKey.expires:
        value = NSHttpCookiePropertyKeyEnum.expires;
        break;
      case NSHttpCookiePropertyKey.maximumAge:
        value = NSHttpCookiePropertyKeyEnum.maximumAge;
        break;
      case NSHttpCookiePropertyKey.name:
        value = NSHttpCookiePropertyKeyEnum.name;
        break;
      case NSHttpCookiePropertyKey.originUrl:
        value = NSHttpCookiePropertyKeyEnum.originUrl;
        break;
      case NSHttpCookiePropertyKey.path:
        value = NSHttpCookiePropertyKeyEnum.path;
        break;
      case NSHttpCookiePropertyKey.port:
        value = NSHttpCookiePropertyKeyEnum.port;
        break;
      case NSHttpCookiePropertyKey.sameSitePolicy:
        value = NSHttpCookiePropertyKeyEnum.sameSitePolicy;
        break;
      case NSHttpCookiePropertyKey.secure:
        value = NSHttpCookiePropertyKeyEnum.secure;
        break;
      case NSHttpCookiePropertyKey.value:
        value = NSHttpCookiePropertyKeyEnum.value;
        break;
      case NSHttpCookiePropertyKey.version:
        value = NSHttpCookiePropertyKeyEnum.version;
        break;
    }

    return NSHttpCookiePropertyKeyEnumData(value: value);
  }
}

extension _WKUserScriptInjectionTimeConverter on WKUserScriptInjectionTime {
  WKUserScriptInjectionTimeEnumData toWKUserScriptInjectionTimeEnumData() {
    late final WKUserScriptInjectionTimeEnum value;
    switch (this) {
      case WKUserScriptInjectionTime.atDocumentStart:
        value = WKUserScriptInjectionTimeEnum.atDocumentStart;
        break;
      case WKUserScriptInjectionTime.atDocumentEnd:
        value = WKUserScriptInjectionTimeEnum.atDocumentEnd;
        break;
    }

    return WKUserScriptInjectionTimeEnumData(value: value);
  }
}

Iterable<WKAudiovisualMediaTypeEnumData> _toWKAudiovisualMediaTypeEnumData(
  Iterable<WKAudiovisualMediaType> types,
) {
  return types
      .map<WKAudiovisualMediaTypeEnumData>((WKAudiovisualMediaType type) {
    late final WKAudiovisualMediaTypeEnum value;
    switch (type) {
      case WKAudiovisualMediaType.none:
        value = WKAudiovisualMediaTypeEnum.none;
        break;
      case WKAudiovisualMediaType.audio:
        value = WKAudiovisualMediaTypeEnum.audio;
        break;
      case WKAudiovisualMediaType.video:
        value = WKAudiovisualMediaTypeEnum.video;
        break;
      case WKAudiovisualMediaType.all:
        value = WKAudiovisualMediaTypeEnum.all;
        break;
    }

    return WKAudiovisualMediaTypeEnumData(value: value);
  });
}

extension _WKUserScriptConverter on WKUserScript {
  WKUserScriptData toWKUserScriptData() {
    return WKUserScriptData(
      source: source,
      injectionTime: injectionTime.toWKUserScriptInjectionTimeEnumData(),
      isMainFrameOnly: isMainFrameOnly,
    );
  }
}

extension _NSUrlRequestConverter on NSUrlRequest {
  NSUrlRequestData toNSUrlRequestData() {
    return NSUrlRequestData(
      url: url,
      httpMethod: httpMethod,
      httpBody: httpBody,
      allHttpHeaderFields: allHttpHeaderFields,
    );
  }
}

/// Handles initialization of Flutter APIs for WebKit.
class WebKitFlutterApis {
  /// Constructs a [WebKitFlutterApis].
  @visibleForTesting
  WebKitFlutterApis({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _binaryMessenger = binaryMessenger {
    navigationDelegateFlutterApi = WKNavigationDelegateFlutterApiImpl(
      instanceManager: instanceManager,
    );
  }

  static WebKitFlutterApis _instance = WebKitFlutterApis();

  /// Sets the global instance containing the Flutter Apis for the WebKit library.
  @visibleForTesting
  static set instance(WebKitFlutterApis instance) {
    _instance = instance;
  }

  /// Global instance containing the Flutter Apis for the WebKit library.
  static WebKitFlutterApis get instance {
    return _instance;
  }

  final BinaryMessenger? _binaryMessenger;
  bool _hasBeenSetUp = false;

  /// Flutter Api for [WKNavigationDelegate].
  @visibleForTesting
  late final WKNavigationDelegateFlutterApiImpl navigationDelegateFlutterApi;

  /// Ensures all the Flutter APIs have been set up to receive calls from native code.
  void ensureSetUp() {
    if (!_hasBeenSetUp) {
      WKNavigationDelegateFlutterApi.setup(
        navigationDelegateFlutterApi,
        binaryMessenger: _binaryMessenger,
      );
      _hasBeenSetUp = true;
    }
  }
}

/// Host api implementation for [WKWebSiteDataStore].
class WKWebsiteDataStoreHostApiImpl extends WKWebsiteDataStoreHostApi {
  /// Constructs a [WebsiteDataStoreHostApiImpl].
  WKWebsiteDataStoreHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebViewConfiguration] with the ids of the provided object instances.
  Future<void> createFromWebViewConfigurationForInstances(
    WKWebsiteDataStore instance,
    WKWebViewConfiguration configuration,
  ) {
    return createFromWebViewConfiguration(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [createDefaultDataStore] with the ids of the provided object instances.
  Future<void> createDefaultDataStoreForInstances(
    WKWebsiteDataStore instance,
  ) {
    return createDefaultDataStore(
        instanceManager.addDartCreatedInstance(instance));
  }

  /// Calls [removeDataOfTypes] with the ids of the provided object instances.
  Future<bool> removeDataOfTypesForInstances(
    WKWebsiteDataStore instance,
    Set<WKWebsiteDataType> dataTypes, {
    required double secondsModifiedSinceEpoch,
  }) {
    return removeDataOfTypes(
      instanceManager.getIdentifier(instance)!,
      _toWKWebsiteDataTypeEnumData(dataTypes).toList(),
      secondsModifiedSinceEpoch,
    );
  }
}

/// Host api implementation for [WKScriptMessageHandler].
class WKScriptMessageHandlerHostApiImpl extends WKScriptMessageHandlerHostApi {
  /// Constructs a [WKScriptMessageHandlerHostApiImpl].
  WKScriptMessageHandlerHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKScriptMessageHandler instance) {
    return create(instanceManager.addDartCreatedInstance(instance));
  }
}

/// Host api implementation for [WKPreferences].
class WKPreferencesHostApiImpl extends WKPreferencesHostApi {
  /// Constructs a [WKPreferencesHostApiImpl].
  WKPreferencesHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebViewConfiguration] with the ids of the provided object instances.
  Future<void> createFromWebViewConfigurationForInstances(
    WKPreferences instance,
    WKWebViewConfiguration configuration,
  ) {
    return createFromWebViewConfiguration(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [setJavaScriptEnabled] with the ids of the provided object instances.
  Future<void> setJavaScriptEnabledForInstances(
    WKPreferences instance,
    bool enabled,
  ) {
    return setJavaScriptEnabled(
      instanceManager.getIdentifier(instance)!,
      enabled,
    );
  }
}

/// Host api implementation for [WKHttpCookieStore].
class WKHttpCookieStoreHostApiImpl extends WKHttpCookieStoreHostApi {
  /// Constructs a [WKHttpCookieStoreHostApiImpl].
  WKHttpCookieStoreHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebsiteDataStore] with the ids of the provided object instances.
  Future<void> createFromWebsiteDataStoreForInstances(
    WKHttpCookieStore instance,
    WKWebsiteDataStore dataStore,
  ) {
    return createFromWebsiteDataStore(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(dataStore)!,
    );
  }

  /// Calls [setCookie] with the ids of the provided object instances.
  Future<void> setCookieForInsances(
    WKHttpCookieStore instance,
    NSHttpCookie cookie,
  ) {
    return setCookie(
      instanceManager.getIdentifier(instance)!,
      cookie.toNSHttpCookieData(),
    );
  }
}

/// Host api implementation for [WKUserContentController].
class WKUserContentControllerHostApiImpl
    extends WKUserContentControllerHostApi {
  /// Constructs a [WKUserContentControllerHostApiImpl].
  WKUserContentControllerHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [createFromWebViewConfiguration] with the ids of the provided object instances.
  Future<void> createFromWebViewConfigurationForInstances(
    WKUserContentController instance,
    WKWebViewConfiguration configuration,
  ) {
    return createFromWebViewConfiguration(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [addScriptMessageHandler] with the ids of the provided object instances.
  Future<void> addScriptMessageHandlerForInstances(
    WKUserContentController instance,
    WKScriptMessageHandler handler,
    String name,
  ) {
    return addScriptMessageHandler(
      instanceManager.getIdentifier(instance)!,
      instanceManager.getIdentifier(handler)!,
      name,
    );
  }

  /// Calls [removeScriptMessageHandler] with the ids of the provided object instances.
  Future<void> removeScriptMessageHandlerForInstances(
    WKUserContentController instance,
    String name,
  ) {
    return removeScriptMessageHandler(
      instanceManager.getIdentifier(instance)!,
      name,
    );
  }

  /// Calls [removeAllScriptMessageHandlers] with the ids of the provided object instances.
  Future<void> removeAllScriptMessageHandlersForInstances(
    WKUserContentController instance,
  ) {
    return removeAllScriptMessageHandlers(
      instanceManager.getIdentifier(instance)!,
    );
  }

  /// Calls [addUserScript] with the ids of the provided object instances.
  Future<void> addUserScriptForInstances(
    WKUserContentController instance,
    WKUserScript userScript,
  ) {
    return addUserScript(
      instanceManager.getIdentifier(instance)!,
      userScript.toWKUserScriptData(),
    );
  }

  /// Calls [removeAllUserScripts] with the ids of the provided object instances.
  Future<void> removeAllUserScriptsForInstances(
    WKUserContentController instance,
  ) {
    return removeAllUserScripts(instanceManager.getIdentifier(instance)!);
  }
}

/// Host api implementation for [WKWebViewConfiguration].
class WKWebViewConfigurationHostApiImpl extends WKWebViewConfigurationHostApi {
  /// Constructs a [WKWebViewConfigurationHostApiImpl].
  WKWebViewConfigurationHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKWebViewConfiguration instance) {
    return create(instanceManager.addDartCreatedInstance(instance));
  }

  /// Calls [createFromWebView] with the ids of the provided object instances.
  Future<void> createFromWebViewForInstances(
    WKWebViewConfiguration instance,
    WKWebView webView,
  ) {
    return createFromWebView(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(webView)!,
    );
  }

  /// Calls [setAllowsInlineMediaPlayback] with the ids of the provided object instances.
  Future<void> setAllowsInlineMediaPlaybackForInstances(
    WKWebViewConfiguration instance,
    bool allow,
  ) {
    return setAllowsInlineMediaPlayback(
      instanceManager.getIdentifier(instance)!,
      allow,
    );
  }

  /// Calls [setMediaTypesRequiringUserActionForPlayback] with the ids of the provided object instances.
  Future<void> setMediaTypesRequiringUserActionForPlaybackForInstances(
    WKWebViewConfiguration instance,
    Set<WKAudiovisualMediaType> types,
  ) {
    return setMediaTypesRequiringUserActionForPlayback(
      instanceManager.getIdentifier(instance)!,
      _toWKAudiovisualMediaTypeEnumData(types).toList(),
    );
  }
}

/// Host api implementation for [WKUIDelegate].
class WKUIDelegateHostApiImpl extends WKUIDelegateHostApi {
  /// Constructs a [WKUIDelegateHostApiImpl].
  WKUIDelegateHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKUIDelegate instance) {
    return create(instanceManager.addDartCreatedInstance(instance));
  }
}

/// Host api implementation for [WKNavigationDelegate].
class WKNavigationDelegateHostApiImpl extends WKNavigationDelegateHostApi {
  /// Constructs a [WKNavigationDelegateHostApiImpl].
  WKNavigationDelegateHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(WKNavigationDelegate instance) {
    return create(instanceManager.addDartCreatedInstance(instance));
  }

  /// Calls [setDidFinishNavigation] with the ids of the provided object instances.
  Future<void> setDidFinishNavigationFromInstance(
    WKNavigationDelegate instance,
    void Function(WKWebView, String?)? didFinishNavigation,
  ) {
    int? functionInstanceId;
    if (didFinishNavigation != null) {
      functionInstanceId = instanceManager.getIdentifier(didFinishNavigation) ??
          instanceManager.addDartCreatedInstance(didFinishNavigation);
    }
    return setDidFinishNavigation(
      instanceManager.getIdentifier(instance)!,
      functionInstanceId,
    );
  }
}

/// Flutter api implementation for [WKNavigationDelegate].
class WKNavigationDelegateFlutterApiImpl
    extends WKNavigationDelegateFlutterApi {
  /// Constructs a [WKNavigationDelegateFlutterApiImpl].
  WKNavigationDelegateFlutterApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  /// Maintains instances stored to communicate with native language objects.
  late final InstanceManager instanceManager;

  @override
  void didFinishNavigation(
    int functionIdentifier,
    int webViewIdentifier,
    String? url,
  ) {
    final void Function(
      WKWebView webView,
      String? url,
    ) function = instanceManager.getInstance(functionIdentifier)!;
    function(instanceManager.getInstance(webViewIdentifier)!, url);
  }
}

/// Host api implementation for [WKWebView].
class WKWebViewHostApiImpl extends WKWebViewHostApi {
  /// Constructs a [WKWebViewHostApiImpl].
  WKWebViewHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Calls [create] with the ids of the provided object instances.
  Future<void> createForInstances(
    WKWebView instance,
    WKWebViewConfiguration configuration,
  ) {
    return create(
      instanceManager.addDartCreatedInstance(instance),
      instanceManager.getIdentifier(configuration)!,
    );
  }

  /// Calls [loadRequest] with the ids of the provided object instances.
  Future<void> loadRequestForInstances(
      WKWebView webView, NSUrlRequest request) {
    return loadRequest(
      instanceManager.getIdentifier(webView)!,
      request.toNSUrlRequestData(),
    );
  }

  /// Calls [loadHtmlString] with the ids of the provided object instances.
  Future<void> loadHtmlStringForInstances(
    WKWebView instance,
    String string,
    String? baseUrl,
  ) {
    return loadHtmlString(
      instanceManager.getIdentifier(instance)!,
      string,
      baseUrl,
    );
  }

  /// Calls [loadFileUrl] with the ids of the provided object instances.
  Future<void> loadFileUrlForInstances(
    WKWebView instance,
    String url,
    String readAccessUrl,
  ) {
    return loadFileUrl(
      instanceManager.getIdentifier(instance)!,
      url,
      readAccessUrl,
    );
  }

  /// Calls [loadFlutterAsset] with the ids of the provided object instances.
  Future<void> loadFlutterAssetForInstances(WKWebView instance, String key) {
    return loadFlutterAsset(
      instanceManager.getIdentifier(instance)!,
      key,
    );
  }

  /// Calls [canGoBack] with the ids of the provided object instances.
  Future<bool> canGoBackForInstances(WKWebView instance) {
    return canGoBack(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [canGoForward] with the ids of the provided object instances.
  Future<bool> canGoForwardForInstances(WKWebView instance) {
    return canGoForward(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [goBack] with the ids of the provided object instances.
  Future<void> goBackForInstances(WKWebView instance) {
    return goBack(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [goForward] with the ids of the provided object instances.
  Future<void> goForwardForInstances(WKWebView instance) {
    return goForward(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [reload] with the ids of the provided object instances.
  Future<void> reloadForInstances(WKWebView instance) {
    return reload(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [getUrl] with the ids of the provided object instances.
  Future<String?> getUrlForInstances(WKWebView instance) {
    return getUrl(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [getTitle] with the ids of the provided object instances.
  Future<String?> getTitleForInstances(WKWebView instance) {
    return getTitle(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [getEstimatedProgress] with the ids of the provided object instances.
  Future<double> getEstimatedProgressForInstances(WKWebView instance) {
    return getEstimatedProgress(instanceManager.getIdentifier(instance)!);
  }

  /// Calls [setAllowsBackForwardNavigationGestures] with the ids of the provided object instances.
  Future<void> setAllowsBackForwardNavigationGesturesForInstances(
    WKWebView instance,
    bool allow,
  ) {
    return setAllowsBackForwardNavigationGestures(
      instanceManager.getIdentifier(instance)!,
      allow,
    );
  }

  /// Calls [setCustomUserAgent] with the ids of the provided object instances.
  Future<void> setCustomUserAgentForInstances(
    WKWebView instance,
    String? userAgent,
  ) {
    return setCustomUserAgent(
      instanceManager.getIdentifier(instance)!,
      userAgent,
    );
  }

  /// Calls [evaluateJavaScript] with the ids of the provided object instances.
  Future<Object?> evaluateJavaScriptForInstances(
    WKWebView instance,
    String javaScriptString,
  ) {
    return evaluateJavaScript(
      instanceManager.getIdentifier(instance)!,
      javaScriptString,
    );
  }

  /// Calls [setNavigationDelegate] with the ids of the provided object instances.
  Future<void> setNavigationDelegateForInstances(
    WKWebView instance,
    WKNavigationDelegate? delegate,
  ) {
    return setNavigationDelegate(
      instanceManager.getIdentifier(instance)!,
      delegate != null ? instanceManager.getIdentifier(delegate)! : null,
    );
  }

  /// Calls [setUIDelegate] with the ids of the provided object instances.
  Future<void> setUIDelegateForInstances(
    WKWebView instance,
    WKUIDelegate? delegate,
  ) {
    return setUIDelegate(
      instanceManager.getIdentifier(instance)!,
      delegate != null ? instanceManager.getIdentifier(delegate)! : null,
    );
  }
}
