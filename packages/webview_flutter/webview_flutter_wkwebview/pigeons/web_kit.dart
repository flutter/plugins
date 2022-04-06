// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/common/web_kit.pigeon.dart',
    dartTestOut: 'test/src/common/test_web_kit.pigeon.dart',
    dartOptions: DartOptions(isNullSafe: true, copyrightHeader: <String>[
      'Copyright 2013 The Flutter Authors. All rights reserved.',
      'Use of this source code is governed by a BSD-style license that can be',
      'found in the LICENSE file.',
    ]),
  ),
)

/// Mirror of NSKeyValueObservingOptions.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvalueobservingoptions?language=objc.
enum NSKeyValueObservingOptionsEnum {
  newValue,
  oldValue,
  initialValue,
  priorNotification,
}

class NSKeyValueObservingOptionsEnumData {
  // TODO(bparrishMines): Generated code fails when enums are marked as nonnull.
  // Change to nonnull once this is fixed: https://github.com/flutter/flutter/issues/100594
  late NSKeyValueObservingOptionsEnum? value;
}

/// Mirror of NSKeyValueChange.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechange?language=objc.
enum NSKeyValueChangeEnum {
  setting,
  insertion,
  removal,
  replacement,
}

class NSKeyValueChangeEnumData {
  late NSKeyValueChangeEnum? value;
}

/// Mirror of NSKeyValueChangeKey.
///
/// See https://developer.apple.com/documentation/foundation/nskeyvaluechangekey?language=objc.
enum NSKeyValueChangeKeyEnum {
  indexes,
  kind,
  newValue,
  notificationIsPrior,
  oldValue,
}

class NSKeyValueChangeKeyEnumData {
  late NSKeyValueChangeKeyEnum? value;
}

/// Mirror of WKUserScriptInjectionTime.
///
/// See https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime?language=objc.
enum WKUserScriptInjectionTimeEnum {
  atDocumentStart,
  atDocumentEnd,
}

class WKUserScriptInjectionTimeEnumData {
  late WKUserScriptInjectionTimeEnum? value;
}

/// Mirror of WKAudiovisualMediaTypes.
///
/// See [WKAudiovisualMediaTypes](https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes?language=objc).
enum WKAudiovisualMediaTypeEnum {
  none,
  audio,
  video,
  all,
}

class WKAudiovisualMediaTypeEnumData {
  late WKAudiovisualMediaTypeEnum? value;
}

/// Mirror of WKWebsiteDataTypes.
///
/// See https://developer.apple.com/documentation/webkit/wkwebsitedatarecord/data_store_record_types?language=objc.
enum WKWebsiteDataTypesEnum {
  cookies,
  memoryCache,
  diskCache,
  offlineWebApplicationCache,
  localStroage,
  sessionStorage,
  sqlDatabases,
  indexedDBDatabases,
}

class WKWebsiteDataTypesEnumData {
  late WKWebsiteDataTypesEnum? value;
}

/// Mirror of WKNavigationActionPolicy.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationactionpolicy?language=objc.
enum WKNavigationActionPolicyEnum {
  allow,
  cancel,
}

class WKNavigationActionPolicyEnumData {
  late WKNavigationActionPolicyEnum? value;
}

/// Mirror of NSURLRequest.
///
/// See https://developer.apple.com/documentation/foundation/nsurlrequest?language=objc.
class NSUrlRequestData {
  late String url;
  late String? httpMethod;
  late Uint8List? httpBody;
  late Map<String?, String?> allHttpHeaderFields;
}

/// Mirror of WKUserScript.
///
/// See https://developer.apple.com/documentation/webkit/wkuserscript?language=objc.
class WKUserScriptData {
  late String source;
  late WKUserScriptInjectionTimeEnumData? injectionTime;
  late bool isMainFrameOnly;
}

/// Mirror of WKNavigationAction.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationaction.
class WKNavigationActionData {
  late NSUrlRequestData request;
  late WKFrameInfoData targetFrame;
}

/// Mirror of WKFrameInfo.
///
/// See https://developer.apple.com/documentation/webkit/wkframeinfo?language=objc.
class WKFrameInfoData {
  late bool isMainFrame;
}

/// Mirror of NSError.
///
/// See https://developer.apple.com/documentation/foundation/nserror?language=objc.
class NSErrorData {
  late int code;
  late String domain;
  late String localiziedDescription;
}

/// Mirror of WKScriptMessage.
///
/// See https://developer.apple.com/documentation/webkit/wkscriptmessage?language=objc.
class WKScriptMessageData {
  late String name;
  late Object? body;
}

/// Mirror of WKWebsiteDataStore.
///
/// See https://developer.apple.com/documentation/webkit/wkwebsitedatastore?language=objc.
@HostApi(dartHostTestHandler: 'TestWKWebsiteDataStoreHostApi')
abstract class WKWebsiteDataStoreHostApi {
  void createFromWebViewConfiguration(
    int instanceId,
    int configurationInstanceId,
  );

  @async
  void removeDataOfTypes(
    int instanceId,
    List<WKWebsiteDataTypesEnumData> dataTypes,
    double secondsModifiedSinceEpoch,
  );
}

/// Mirror of UIView.
///
/// See https://developer.apple.com/documentation/uikit/uiview?language=objc.
@HostApi(dartHostTestHandler: 'TestUIViewHostApi')
abstract class UIViewHostApi {
  List<double?> getContentOffset(int instanceId);

  void setBackgroundColor(int instanceId, int? value);

  void setOpaque(int instanceId, bool opaque);
}

/// Mirror of UIScrollView.
///
/// See https://developer.apple.com/documentation/uikit/uiscrollview?language=objc.
@HostApi(dartHostTestHandler: 'TestUIScrollViewHostApi')
abstract class UIScrollViewHostApi {
  void createFromWebView(int instanceId, int webViewInstanceId);

  List<double?> getContentOffset(int instanceId);

  void scrollBy(int instanceId, double x, double y);

  void setContentOffset(int instanceId, double x, double y);
}

/// Mirror of WKWebViewConfiguration.
///
/// See https://developer.apple.com/documentation/webkit/wkwebviewconfiguration?language=objc.
@HostApi(dartHostTestHandler: 'TestWKWebViewConfigurationHostApi')
abstract class WKWebViewConfigurationHostApi {
  void create(int instanceId);

  void createFromWebView(int instanceId, int webViewInstanceId);

  void setAllowsInlineMediaPlayback(int instanceId, bool allow);

  void setMediaTypesRequiringUserActionForPlayback(
    int instanceId,
    List<WKAudiovisualMediaTypeEnumData> types,
  );
}

/// Mirror of WKUserContentController.
///
/// See https://developer.apple.com/documentation/webkit/wkusercontentcontroller?language=objc.
@HostApi(dartHostTestHandler: 'TestWKUserContentControllerHostApi')
abstract class WKUserContentControllerHostApi {
  void createFromWebViewConfiguration(
    int instanceId,
    int configurationInstanceId,
  );

  void addScriptMessageHandler(
    int instanceId,
    int handlerInstanceid,
    String name,
  );

  void removeScriptMessageHandler(int instanceId, String name);

  void removeAllScriptMessageHandlers(int instanceId);

  void addUserScript(int instanceId, WKUserScriptData userScript);

  void removeAllUserScripts(int instanceId);
}

/// Mirror of WKUserPreferences.
///
/// See https://developer.apple.com/documentation/webkit/wkpreferences?language=objc.
@HostApi(dartHostTestHandler: 'TestWKPreferencesHostApi')
abstract class WKPreferencesHostApi {
  void createFromWebViewConfiguration(
    int instanceId,
    int configurationInstanceId,
  );

  void setJavaScriptEnabled(int instanceId, bool enabled);
}

/// Mirror of WKScriptMessageHandler.
///
/// See https://developer.apple.com/documentation/webkit/wkscriptmessagehandler?language=objc.
@HostApi(dartHostTestHandler: 'TestWKScriptMessageHandlerHostApi')
abstract class WKScriptMessageHandlerHostApi {
  void create(int instanceId);
}

/// Mirror of WKNavigationDelegate.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationdelegate?language=objc.
@HostApi(dartHostTestHandler: 'TestWKNavigationDelegateHostApi')
abstract class WKNavigationDelegateHostApi {
  void create(int instanceId);
}

/// Mirror of NSObject.
///
/// See https://developer.apple.com/documentation/objectivec/nsobject.
@HostApi(dartHostTestHandler: 'TestNSObjectHostApi')
abstract class NSObjectHostApi {
  void dispose(int instanceId);

  void addObserver(
    int instanceId,
    int observerInstanceId,
    String keyPath,
    List<NSKeyValueObservingOptionsEnumData> options,
  );

  void removeObserver(int instanceId, int observerInstanceId, String keyPath);
}

/// Mirror of WKWebView.
///
/// See https://developer.apple.com/documentation/webkit/wkwebview?language=objc.
@HostApi(dartHostTestHandler: 'TestWKWebViewHostApi')
abstract class WKWebViewHostApi {
  void create(int instanceId, int configurationInstanceId);

  void setUIDelegate(int instanceId, int? uiDelegateInstanceId);

  void setNavigationDelegate(int instanceId, int? navigationDelegateInstanceId);

  String? getUrl(int instanceId);

  double getEstimatedProgress(int instanceId);

  void loadRequest(int instanceId, NSUrlRequestData request);

  void loadHtmlString(int instanceId, String string, String? baseUrl);

  void loadFileUrl(int instanceId, String url, String readAccessUrl);

  void loadFlutterAsset(int instanceId, String key);

  bool canGoBack(int instanceId);

  bool canGoForward(int instanceId);

  void goBack(int instanceId);

  void goForward(int instanceId);

  void reload(int instanceId);

  String? getTitle(int instanceId);

  void setAllowsBackForwardNavigationGestures(int instanceId, bool allow);

  void setCustomUserAgent(int instanceId, String? userAgent);

  @async
  String evaluateJavaScript(int instanceId, String javascriptString);
}

/// Mirror of WKUIDelegate.
///
/// See https://developer.apple.com/documentation/webkit/wkuidelegate?language=objc.
@HostApi(dartHostTestHandler: 'TestWKUIDelegateHostApi')
abstract class WKUIDelegateHostApi {
  void create(int instanceId);
}
