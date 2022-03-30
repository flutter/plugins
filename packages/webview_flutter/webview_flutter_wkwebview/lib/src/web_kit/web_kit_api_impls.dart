// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';

import '../common/instance_manager.dart';
import '../common/web_kit.pigeon.dart';
import 'web_kit.dart';

extension _WKWebsiteDataTypesConverter on WKWebsiteDataTypes {
  WKWebsiteDataTypesEnumData toWKWebsiteDataTypesEnumData() {
    late final WKWebsiteDataTypesEnum value;
    switch (this) {
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

extension _WKAudiovisualMediaTypeConverter on WKAudiovisualMediaType {
  WKAudiovisualMediaTypeEnumData toWKAudiovisualMediaTypeEnumData() {
    late final WKAudiovisualMediaTypeEnum value;
    switch (this) {
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
  }
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

  /// Converts objects to instances ids for [createFromWebViewConfiguration].
  Future<void> createFromWebViewConfigurationFromInstance(
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

  /// Converts objects to instances ids for [removeDataOfTypes].
  Future<void> removeDataOfTypesFromInstance(
    WKWebsiteDataStore instance,
    Set<WKWebsiteDataTypes> dataTypes, {
    required double secondsModifiedSinceEpoch,
  }) {
    return removeDataOfTypes(
      instanceManager.getInstanceId(instance)!,
      dataTypes
          .map<WKWebsiteDataTypesEnumData>(
              (WKWebsiteDataTypes type) => type.toWKWebsiteDataTypesEnumData())
          .toList(),
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

  /// Converts objects to instances ids for [create].
  Future<void> createFromInstance(WKScriptMessageHandler instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(instanceId);
    }
  }
}

/// Host api implementation for [WKUserContentController].
class WKUserContentControllerHostApiImpl
    extends WKUserContentControllerHostApi {
  /// Constructs a [UserContentControllerHostApiImpl].
  WKUserContentControllerHostApiImpl({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : instanceManager = instanceManager ?? InstanceManager.instance,
        super(binaryMessenger: binaryMessenger);

  /// Maintains instances stored to communicate with Objective-C objects.
  final InstanceManager instanceManager;

  /// Converts objects to instances ids for [createFromWebViewConfiguration].
  Future<void> createFromWebViewConfigurationFromInstance(
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

  /// Converts objects to instances ids for [addScriptMessageHandler].
  Future<void> addScriptMessageHandlerFromInstance(
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

  /// Converts objects to instances ids for [removeScriptMessageHandler].
  Future<void> removeScriptMessageHandlerFromInstance(
    WKUserContentController instance,
    String name,
  ) {
    return removeScriptMessageHandler(
      instanceManager.getInstanceId(instance)!,
      name,
    );
  }

  /// Converts objects to instances ids for [removeAllScriptMessageHandlers].
  Future<void> removeAllScriptMessageHandlersFromInstance(
    WKUserContentController instance,
  ) {
    return removeAllScriptMessageHandlers(
      instanceManager.getInstanceId(instance)!,
    );
  }

  /// Converts objects to instances ids for [addUserScript].
  Future<void> addUserScriptFromInstance(
    WKUserContentController instance,
    WKUserScript userScript,
  ) {
    return addUserScript(
      instanceManager.getInstanceId(instance)!,
      userScript.toWKUserScriptData(),
    );
  }

  /// Converts objects to instances ids for [removeAllUserScripts].
  Future<void> removeAllUserScriptsFromInstance(
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

  /// Converts objects to instances ids for [create].
  Future<void> createFromInstance(WKWebViewConfiguration instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(instanceId);
    }
  }

  /// Converts objects to instances ids for [createFromWebView].
  Future<void> createFromWebViewFromInstance(
    WKWebViewConfiguration instance,
    WKWebView webView,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await createFromWebView(
          instanceId, instanceManager.getInstanceId(webView)!,);
    }
  }

  /// Converts objects to instances ids for [setAllowsInlineMediaPlayback].
  Future<void> setAllowsInlineMediaPlaybackFromInstance(
    WKWebViewConfiguration instance,
    bool allow,
  ) {
    return setAllowsInlineMediaPlayback(
      instanceManager.getInstanceId(instance)!,
      allow,
    );
  }

  /// Converts objects to instances ids for [setMediaTypesRequiringUserActionForPlayback].
  Future<void> setMediaTypesRequiringUserActionForPlaybackFromInstance(
    WKWebViewConfiguration instance,
    Set<WKAudiovisualMediaType> types,
  ) {
    return setMediaTypesRequiringUserActionForPlayback(
      instanceManager.getInstanceId(instance)!,
      types
          .map<WKAudiovisualMediaTypeEnumData>((WKAudiovisualMediaType type) =>
              type.toWKAudiovisualMediaTypeEnumData())
          .toList(),
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

  /// Converts objects to instances ids for [create].
  Future<void> createFromInstance(WKUIDelegate instance) async {
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

  /// Converts objects to instances ids for [create].
  Future<void> createFromInstance(WKNavigationDelegate instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      await create(instanceId);
    }
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

  /// Converts objects to instances ids for [create].
  Future<void> createFromInstance(
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

  /// Converts objects to instances ids for [loadRequest].
  Future<void> loadRequestFromInstance(
      WKWebView webView, NSUrlRequest request) {
    return loadRequest(
      instanceManager.getInstanceId(webView)!,
      request.toNSUrlRequestData(),
    );
  }

  /// Converts objects to instances ids for [loadHtmlString].
  Future<void> loadHtmlStringFromInstance(
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

  /// Converts objects to instances ids for [loadFileUrl].
  Future<void> loadFileUrlFromInstance(
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

  /// Converts objects to instances ids for [loadFlutterAsset].
  Future<void> loadFlutterAssetFromInstance(WKWebView instance, String key) {
    return loadFlutterAsset(
      instanceManager.getInstanceId(instance)!,
      key,
    );
  }

  /// Converts objects to instances ids for [canGoBack].
  Future<bool> canGoBackFromInstance(WKWebView instance) {
    return canGoBack(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [canGoForward].
  Future<bool> canGoForwardFromInstance(WKWebView instance) {
    return canGoForward(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [goBack].
  Future<void> goBackFromInstance(WKWebView instance) {
    return goBack(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [goForward].
  Future<void> goForwardFromInstance(WKWebView instance) {
    return goForward(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [reload].
  Future<void> reloadFromInstance(WKWebView instance) {
    return reload(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [getUrl].
  Future<String?> getUrlFromInstance(WKWebView instance) {
    return getUrl(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [getTitle].
  Future<String?> getTitleFromInstance(WKWebView instance) {
    return getTitle(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [getEstimatedProgress].
  Future<double> getEstimatedProgressFromInstance(WKWebView instance) {
    return getEstimatedProgress(instanceManager.getInstanceId(instance)!);
  }

  /// Converts objects to instances ids for [setAllowsBackForwardNavigationGestures].
  Future<void> setAllowsBackForwardNavigationGesturesFromInstance(
    WKWebView instance,
    bool allow,
  ) {
    return setAllowsBackForwardNavigationGestures(
      instanceManager.getInstanceId(instance)!,
      allow,
    );
  }

  /// Converts objects to instances ids for [setCustomUserAgent].
  Future<void> setCustomUserAgentFromInstance(
    WKWebView instance,
    String? userAgent,
  ) {
    return setCustomUserAgent(
      instanceManager.getInstanceId(instance)!,
      userAgent,
    );
  }

  /// Converts objects to instances ids for [evaluateJavaScript].
  Future<Object?> evaluateJavaScriptFromInstance(
    WKWebView instance,
    String javaScriptString,
  ) {
    return evaluateJavaScript(
      instanceManager.getInstanceId(instance)!,
      javaScriptString,
    );
  }

  /// Converts objects to instances ids for [setNavigationDelegate].
  Future<void> setNavigationDelegateFromInstance(
    WKWebView instance,
    WKNavigationDelegate? delegate,
  ) {
    return setNavigationDelegate(
      instanceManager.getInstanceId(instance)!,
      delegate != null ? instanceManager.getInstanceId(delegate)! : null,
    );
  }

  /// Converts objects to instances ids for [setUIDelegate].
  Future<void> setUIDelegateFromInstance(
    WKWebView instance,
    WKUIDelegate? delegate,
  ) {
    return setUIDelegate(
      instanceManager.getInstanceId(instance)!,
      delegate != null ? instanceManager.getInstanceId(delegate)! : null,
    );
  }
}
