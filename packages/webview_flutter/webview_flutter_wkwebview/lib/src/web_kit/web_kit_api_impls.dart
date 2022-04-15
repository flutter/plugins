// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.pigeon.dart';
import '../foundation/foundation.dart';
import 'web_kit.dart';

Iterable<WKWebsiteDataTypesEnumData> _toWKWebsiteDataTypesEnumData(
    Iterable<WKWebsiteDataTypes> types) {
  return types.map<WKWebsiteDataTypesEnumData>((WKWebsiteDataTypes type) {
    late final WKWebsiteDataTypesEnum value;
    switch (type) {
      case WKWebsiteDataTypes.cookies:
        value = WKWebsiteDataTypesEnum.cookies;
        break;
      case WKWebsiteDataTypes.memoryCache:
        value = WKWebsiteDataTypesEnum.memoryCache;
        break;
      case WKWebsiteDataTypes.diskCache:
        value = WKWebsiteDataTypesEnum.diskCache;
        break;
      case WKWebsiteDataTypes.offlineWebApplicationCache:
        value = WKWebsiteDataTypesEnum.offlineWebApplicationCache;
        break;
      case WKWebsiteDataTypes.localStroage:
        value = WKWebsiteDataTypesEnum.localStroage;
        break;
      case WKWebsiteDataTypes.sessionStorage:
        value = WKWebsiteDataTypesEnum.sessionStorage;
        break;
      case WKWebsiteDataTypes.sqlDatabases:
        value = WKWebsiteDataTypesEnum.sqlDatabases;
        break;
      case WKWebsiteDataTypes.indexedDBDatabases:
        value = WKWebsiteDataTypesEnum.indexedDBDatabases;
        break;
    }

    return WKWebsiteDataTypesEnumData(value: value);
  });
}

extension _NSHttpCookieConverter on NSHttpCookie {
  NSHttpCookieData toNSHttpCookieData() {
    return NSHttpCookieData(
      properties: properties.map<NSHttpCookiePropertyKeyEnumData, String>(
        (NSHttpCookiePropertyKey key, Object value) {
          return MapEntry<NSHttpCookiePropertyKeyEnumData, String>(
            key.toNSHttpCookiePropertyKeyEnumData(),
            value.toString(),
          );
        },
      ),
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
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createFromWebViewConfiguration(
        instanceId,
        instanceManager.getInstanceId(configuration)!,
      );
    }
  }

  /// Calls [createDefaultDataStore] with the ids of the provided object instances.
  Future<void> createDefaultDataStoreForInstances(
    WKWebsiteDataStore instance,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createDefaultDataStore(instanceId);
    }
  }

  /// Calls [removeDataOfTypes] with the ids of the provided object instances.
  Future<bool> removeDataOfTypesForInstances(
    WKWebsiteDataStore instance,
    Set<WKWebsiteDataTypes> dataTypes, {
    required double secondsModifiedSinceEpoch,
  }) {
    return removeDataOfTypes(
      instanceManager.getInstanceId(instance)!,
      _toWKWebsiteDataTypesEnumData(dataTypes).toList(),
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
  Future<void> createForInstances(WKScriptMessageHandler instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(instanceId);
    }
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
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createFromWebViewConfiguration(
        instanceId,
        instanceManager.getInstanceId(configuration)!,
      );
    }
  }

  /// Calls [setJavaScriptEnabled] with the ids of the provided object instances.
  Future<void> setJavaScriptEnabledForInstances(
    WKPreferences instance,
    bool enabled,
  ) {
    return setJavaScriptEnabled(
      instanceManager.getInstanceId(instance)!,
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
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createFromWebsiteDataStore(
        instanceId,
        instanceManager.getInstanceId(dataStore)!,
      );
    }
  }

  /// Calls [setCookie] with the ids of the provided object instances.
  Future<void> setCookieForInsances(
    WKHttpCookieStore instance,
    NSHttpCookie cookie,
  ) {
    return setCookie(
      instanceManager.getInstanceId(instance)!,
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
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createFromWebViewConfiguration(
        instanceId,
        instanceManager.getInstanceId(configuration)!,
      );
    }
  }

  /// Calls [addScriptMessageHandler] with the ids of the provided object instances.
  Future<void> addScriptMessageHandlerForInstances(
    WKUserContentController instance,
    WKScriptMessageHandler handler,
    String name,
  ) {
    return addScriptMessageHandler(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(handler)!,
      name,
    );
  }

  /// Calls [removeScriptMessageHandler] with the ids of the provided object instances.
  Future<void> removeScriptMessageHandlerForInstances(
    WKUserContentController instance,
    String name,
  ) {
    return removeScriptMessageHandler(
      instanceManager.getInstanceId(instance)!,
      name,
    );
  }

  /// Calls [removeAllScriptMessageHandlers] with the ids of the provided object instances.
  Future<void> removeAllScriptMessageHandlersForInstances(
    WKUserContentController instance,
  ) {
    return removeAllScriptMessageHandlers(
      instanceManager.getInstanceId(instance)!,
    );
  }

  /// Calls [addUserScript] with the ids of the provided object instances.
  Future<void> addUserScriptForInstances(
    WKUserContentController instance,
    WKUserScript userScript,
  ) {
    return addUserScript(
      instanceManager.getInstanceId(instance)!,
      userScript.toWKUserScriptData(),
    );
  }

  /// Calls [removeAllUserScripts] with the ids of the provided object instances.
  Future<void> removeAllUserScriptsForInstances(
    WKUserContentController instance,
  ) {
    return removeAllUserScripts(instanceManager.getInstanceId(instance)!);
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
  Future<void> createForInstances(WKWebViewConfiguration instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(instanceId);
    }
  }

  /// Calls [createFromWebView] with the ids of the provided object instances.
  Future<void> createFromWebViewForInstances(
    WKWebViewConfiguration instance,
    WKWebView webView,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createFromWebView(
        instanceId,
        instanceManager.getInstanceId(webView)!,
      );
    }
  }

  /// Calls [setAllowsInlineMediaPlayback] with the ids of the provided object instances.
  Future<void> setAllowsInlineMediaPlaybackForInstances(
    WKWebViewConfiguration instance,
    bool allow,
  ) {
    return setAllowsInlineMediaPlayback(
      instanceManager.getInstanceId(instance)!,
      allow,
    );
  }

  /// Calls [setMediaTypesRequiringUserActionForPlayback] with the ids of the provided object instances.
  Future<void> setMediaTypesRequiringUserActionForPlaybackForInstances(
    WKWebViewConfiguration instance,
    Set<WKAudiovisualMediaType> types,
  ) {
    return setMediaTypesRequiringUserActionForPlayback(
      instanceManager.getInstanceId(instance)!,
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
  Future<void> createForInstances(WKUIDelegate instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(instanceId);
    }
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
  Future<void> createForInstances(WKNavigationDelegate instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(instanceId);
    }
  }

  /// Calls [setDidFinishNavigation] with the ids of the provided object instances.
  Future<void> setDidFinishNavigationFromInstance(
    WKNavigationDelegate instance,
    void Function(WKWebView, String?)? didFinishNavigation,
  ) {
    int? functionInstanceId;
    if (didFinishNavigation != null) {
      functionInstanceId = instanceManager.getInstanceId(didFinishNavigation) ??
          instanceManager.tryAddInstance(didFinishNavigation)!;
    }
    return setDidFinishNavigation(
      instanceManager.getInstanceId(instance)!,
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
    int functionInstanceId,
    int webViewInstanceId,
    String? url,
  ) {
    final void Function(
      WKWebView webView,
      String? url,
    ) function = instanceManager.getInstance(functionInstanceId)!;
    function(instanceManager.getInstance(webViewInstanceId)!, url);
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
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(
        instanceId,
        instanceManager.getInstanceId(configuration)!,
      );
    }
  }

  /// Calls [loadRequest] with the ids of the provided object instances.
  Future<void> loadRequestForInstances(
      WKWebView webView, NSUrlRequest request) {
    return loadRequest(
      instanceManager.getInstanceId(webView)!,
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
      instanceManager.getInstanceId(instance)!,
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
      instanceManager.getInstanceId(instance)!,
      url,
      readAccessUrl,
    );
  }

  /// Calls [loadFlutterAsset] with the ids of the provided object instances.
  Future<void> loadFlutterAssetForInstances(WKWebView instance, String key) {
    return loadFlutterAsset(
      instanceManager.getInstanceId(instance)!,
      key,
    );
  }

  /// Calls [canGoBack] with the ids of the provided object instances.
  Future<bool> canGoBackForInstances(WKWebView instance) {
    return canGoBack(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [canGoForward] with the ids of the provided object instances.
  Future<bool> canGoForwardForInstances(WKWebView instance) {
    return canGoForward(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [goBack] with the ids of the provided object instances.
  Future<void> goBackForInstances(WKWebView instance) {
    return goBack(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [goForward] with the ids of the provided object instances.
  Future<void> goForwardForInstances(WKWebView instance) {
    return goForward(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [reload] with the ids of the provided object instances.
  Future<void> reloadForInstances(WKWebView instance) {
    return reload(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [getUrl] with the ids of the provided object instances.
  Future<String?> getUrlForInstances(WKWebView instance) {
    return getUrl(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [getTitle] with the ids of the provided object instances.
  Future<String?> getTitleForInstances(WKWebView instance) {
    return getTitle(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [getEstimatedProgress] with the ids of the provided object instances.
  Future<double> getEstimatedProgressForInstances(WKWebView instance) {
    return getEstimatedProgress(instanceManager.getInstanceId(instance)!);
  }

  /// Calls [setAllowsBackForwardNavigationGestures] with the ids of the provided object instances.
  Future<void> setAllowsBackForwardNavigationGesturesForInstances(
    WKWebView instance,
    bool allow,
  ) {
    return setAllowsBackForwardNavigationGestures(
      instanceManager.getInstanceId(instance)!,
      allow,
    );
  }

  /// Calls [setCustomUserAgent] with the ids of the provided object instances.
  Future<void> setCustomUserAgentForInstances(
    WKWebView instance,
    String? userAgent,
  ) {
    return setCustomUserAgent(
      instanceManager.getInstanceId(instance)!,
      userAgent,
    );
  }

  /// Calls [evaluateJavaScript] with the ids of the provided object instances.
  Future<Object?> evaluateJavaScriptForInstances(
    WKWebView instance,
    String javaScriptString,
  ) {
    return evaluateJavaScript(
      instanceManager.getInstanceId(instance)!,
      javaScriptString,
    );
  }

  /// Calls [setNavigationDelegate] with the ids of the provided object instances.
  Future<void> setNavigationDelegateForInstances(
    WKWebView instance,
    WKNavigationDelegate? delegate,
  ) {
    return setNavigationDelegate(
      instanceManager.getInstanceId(instance)!,
      delegate != null ? instanceManager.getInstanceId(delegate)! : null,
    );
  }

  /// Calls [setUIDelegate] with the ids of the provided object instances.
  Future<void> setUIDelegateForInstances(
    WKWebView instance,
    WKUIDelegate? delegate,
  ) {
    return setUIDelegate(
      instanceManager.getInstanceId(instance)!,
      delegate != null ? instanceManager.getInstanceId(delegate)! : null,
    );
  }
}
