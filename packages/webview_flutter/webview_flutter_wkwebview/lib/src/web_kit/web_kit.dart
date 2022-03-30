// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../common/instance_manager.dart';
import '../foundation/foundation.dart';
import '../ui_kit/ui_kit.dart';
import 'web_kit_api_impls.dart';

/// Times at which to inject script content into a webpage.
///
/// Wraps [WKUserScriptInjectionTime](https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime?language=objc).
enum WKUserScriptInjectionTime {
  /// Inject the script after the creation of the webpage’s document element, but before loading any other content.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime/wkuserscriptinjectiontimeatdocumentstart?language=objc.
  atDocumentStart,

  /// Inject the script after the document finishes loading, but before loading any other subresources.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime/wkuserscriptinjectiontimeatdocumentend?language=objc.
  atDocumentEnd,
}

/// The media types that require a user gesture to begin playing.
///
/// Wraps [WKAudiovisualMediaTypes](https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes?language=objc).
enum WKAudiovisualMediaType {
  /// No media types require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypenone?language=objc.
  none,

  /// Media types that contain audio require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypeaudio?language=objc.
  audio,

  /// Media types that contain video require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypevideo?language=objc.
  video,

  /// All media types require a user gesture to begin playing.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes/wkaudiovisualmediatypeall?language=objc.
  all,
}

/// Types of data that websites store.
///
/// See https://developer.apple.com/documentation/webkit/wkwebsitedatarecord/data_store_record_types?language=objc.
enum WKWebsiteDataTypes {
  /// Cookies.
  cookies,

  /// In-memory caches.
  memoryCache,

  /// On-disk caches.
  diskCache,

  /// HTML offline web app caches.
  offlineWebApplicationCache,

  /// HTML local storage.
  localStroage,

  /// HTML session storage.
  sessionStorage,

  /// WebSQL databases.
  sqlDatabases,

  /// IndexedDB databases.
  indexedDBDatabases,
}

/// Indicate whether to allow or cancel navigation to a webpage.
///
/// Wraps [WKNavigationActionPolicy](https://developer.apple.com/documentation/webkit/wknavigationactionpolicy?language=objc).
enum WKNavigationActionPolicy {
  /// Allow navigation to continue.
  ///
  /// See https://developer.apple.com/documentation/webkit/wknavigationactionpolicy/wknavigationactionpolicyallow?language=objc.
  allow,

  /// Cancel navigation.
  ///
  /// See https://developer.apple.com/documentation/webkit/wknavigationactionpolicy/wknavigationactionpolicycancel?language=objc.
  cancel,
}

/// Possible error values that WebKit APIs can return.
///
/// See https://developer.apple.com/documentation/webkit/wkerrorcode.
class WKErrorCode {
  WKErrorCode._();

  /// Indicates an unknown issue occurred.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorunknown.
  static const int unknown = 1;

  /// Indicates the web process that contains the content is no longer running.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorwebcontentprocessterminated.
  static const int webContentProcessTerminated = 2;

  /// Indicates the web view was invalidated.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorwebviewinvalidated.
  static const int webViewInvalidated = 3;

  /// Indicates a JavaScript exception occurred.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorjavascriptexceptionoccurred.
  static const int javaScriptExceptionOccurred = 4;

  /// Indicates the result of JavaScript execution could not be returned.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkerrorcode/wkerrorjavascriptresulttypeisunsupported.
  static const int javaScriptResultTypeIsUnsupported = 5;
}

/// An object that contains information about an action that causes navigation to occur.
///
/// Wraps [WKNavigationAction](https://developer.apple.com/documentation/webkit/wknavigationaction?language=objc).
@immutable
class WKNavigationAction {
  /// Constructs a [WKNavigationAction].
  const WKNavigationAction({required this.request, required this.targetFrame});

  /// The URL request object associated with the navigation action.
  final NSUrlRequest request;

  /// The frame in which to display the new content.
  final WKFrameInfo targetFrame;
}

/// An object that contains information about a frame on a webpage.
///
/// An instance of this class is a transient, data-only object; it does not
/// uniquely identify a frame across multiple delegate method calls.
///
/// Wraps [WKFrameInfo](https://developer.apple.com/documentation/webkit/wkframeinfo?language=objc).
@immutable
class WKFrameInfo {
  /// Construct a [WKFrameInfo].
  const WKFrameInfo({required this.isMainFrame});

  /// Indicates whether the frame is the web site's main frame or a subframe.
  final bool isMainFrame;
}

/// A script that the web view injects into a webpage.
///
/// Wraps [WKUserScript](https://developer.apple.com/documentation/webkit/wkuserscript?language=objc).
@immutable
class WKUserScript {
  /// Constructs a [UserScript].
  const WKUserScript(
    this.source,
    this.injectionTime, {
    required this.isMainFrameOnly,
  });

  /// The script’s source code.
  final String source;

  /// The time at which to inject the script into the webpage.
  final WKUserScriptInjectionTime injectionTime;

  /// Indicates whether to inject the script into the main frame or all frames.
  final bool isMainFrameOnly;
}

/// An object that encapsulates a message sent by JavaScript code from a webpage.
///
/// Wraps [WKScriptMessage](https://developer.apple.com/documentation/webkit/wkscriptmessage?language=objc).
@immutable
class WKScriptMessage {
  /// Constructs a [WKScriptMessage].
  const WKScriptMessage({required this.name, this.body});

  /// The name of the message handler to which the message is sent.
  final String name;

  /// The body of the message.
  ///
  /// Allowed types are [num], [String], [List], [Map], and `null`.
  final Object? body;
}

/// Manages cookies, disk and memory caches, and other types of data for a web view.
///
/// Wraps [WKWebsiteDataStore](https://developer.apple.com/documentation/webkit/wkwebsitedatastore?language=objc).
class WKWebsiteDataStore {
  /// Constructs a [WKWebsiteDataStore] that is owned by [configuration].
  @visibleForTesting
  WKWebsiteDataStore.fromWebViewConfiguration(
    WKWebViewConfiguration configuration, {
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _websiteDataStoreHostApi = WKWebsiteDataStoreHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _websiteDataStoreHostApi.createFromWebViewConfigurationFromInstance(
      this,
      configuration,
    );
  }

  /// Pigeon Host Api implementation for [WKWebsiteDataStore].
  final WKWebsiteDataStoreHostApiImpl _websiteDataStoreHostApi;

  /// Removes website data that changed after the specified date.
  Future<void> removeDataOfTypes(
    Set<WKWebsiteDataTypes> dataTypes,
    DateTime since,
  ) {
    return _websiteDataStoreHostApi.removeDataOfTypesFromInstance(
      this,
      dataTypes,
      secondsModifiedSinceEpoch: since.millisecondsSinceEpoch / 1000,
    );
  }
}

/// An interface for receiving messages from JavaScript code running in a webpage.
///
/// Wraps [WKScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler?language=objc)
class WKScriptMessageHandler {
  /// Constructs a [WKScriptMessageHandler].
  WKScriptMessageHandler({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _scriptMessengerApi = WKScriptMessageHandlerHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _scriptMessengerApi.createFromInstance(this);
  }

  /// Pigeon Host Api implementation for [WKScriptMessageHandler].
  final WKScriptMessageHandlerHostApiImpl _scriptMessengerApi;

  /// Tells the handler that a webpage sent a script message.
  ///
  /// Use this method to respond to a message sent from the webpage’s
  /// JavaScript code. Use the [message] parameter to get the message contents and
  /// to determine the originating web view.
  Future<void> setDidReceiveScriptMessage(
    void Function(
      WKUserContentController userContentController,
      WKScriptMessage message,
    )?
        didReceiveScriptMessage,
  ) {
    throw UnimplementedError();
  }
}

/// Manages interactions between JavaScript code and your web view.
///
/// Use this object to do the following:
///
/// * Inject JavaScript code into webpages running in your web view.
/// * Install custom JavaScript functions that call through to your app’s native
///   code.
///
/// Wraps [WKUserContentController](https://developer.apple.com/documentation/webkit/wkusercontentcontroller?language=objc).
class WKUserContentController {
  /// Constructs a [WKUserContentController] that is owned by [configuration].
  @visibleForTesting
  WKUserContentController.fromWebViewConfiguretion(
    WKWebViewConfiguration configuration, {
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _userContentControllerApi = WKUserContentControllerHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _userContentControllerApi.createFromWebViewConfigurationFromInstance(
      this,
      configuration,
    );
  }

  /// Pigeon Host Api implementation for [WKUserContentController].
  final WKUserContentControllerHostApiImpl _userContentControllerApi;

  /// Installs a message handler that you can call from your JavaScript code.
  ///
  /// This name of the parameter must be unique within the user content
  /// controller and must not be an empty string. The user content controller
  /// uses this parameter to define a JavaScript function for your message
  /// handler in the page’s main content world. The name of this function is
  /// `window.webkit.messageHandlers.<name>.postMessage(<messageBody>)`, where
  /// `<name>` corresponds to the value of this parameter. For example, if you
  /// specify the string `MyFunction`, the user content controller defines the `
  /// `window.webkit.messageHandlers.MyFunction.postMessage()` function in
  /// JavaScript.
  Future<void> addScriptMessageHandler(
    WKScriptMessageHandler handler,
    String name,
  ) {
    assert(name.isNotEmpty);
    return _userContentControllerApi.addScriptMessageHandlerFromInstance(
      this,
      handler,
      name,
    );
  }

  /// Uninstalls the custom message handler with the specified name from your JavaScript code.
  ///
  /// If no message handler with this name exists in the user content
  /// controller, this method does nothing.
  ///
  /// Use this method to remove a message handler that you previously installed
  /// using the [addScriptMessageHandler] method. This method removes the
  /// message handler from the page content world. If you installed the message
  /// handler in a different content world, this method doesn’t remove it.
  Future<void> removeScriptMessageHandler(String name) {
    return _userContentControllerApi.removeScriptMessageHandlerFromInstance(
      this,
      name,
    );
  }

  /// Uninstalls all custom message handlers associated with the user content controller.
  Future<void> removeAllScriptMessageHandlers() {
    return _userContentControllerApi.removeAllScriptMessageHandlersFromInstance(
      this,
    );
  }

  /// Injects the specified script into the webpage’s content.
  Future<void> addUserScript(WKUserScript userScript) {
    return _userContentControllerApi.addUserScriptFromInstance(
        this, userScript);
  }

  /// Removes all user scripts from the web view.
  Future<void> removeAllUserScripts() {
    return _userContentControllerApi.removeAllUserScriptsFromInstance(this);
  }
}

/// A collection of properties that you use to initialize a web view.
///
/// Wraps [WKWebViewConfiguration](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration?language=objc).
class WKWebViewConfiguration {
  /// Constructs a [WKWebViewConfiguration].
  factory WKWebViewConfiguration({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) {
    final WKWebViewConfiguration configuration = WKWebViewConfiguration._(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    configuration._webViewConfigurationApi.createFromInstance(configuration);
    return configuration;
  }

  /// A WKWebViewConfiguration that is owned by webView.
  @visibleForTesting
  factory WKWebViewConfiguration.fromWebView(
    WKWebView webView, {
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) {
    final WKWebViewConfiguration configuration = WKWebViewConfiguration._(
      binaryMessenger: binaryMessenger,
      instanceManager: instanceManager,
    );
    configuration._webViewConfigurationApi.createFromWebViewFromInstance(
      configuration,
      webView,
    );
    return configuration;
  }

  WKWebViewConfiguration._({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        _instanceManager = instanceManager,
        _webViewConfigurationApi = WKWebViewConfigurationHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        );

  final BinaryMessenger? _binaryMessenger;
  final InstanceManager? _instanceManager;

  /// Pigeon Host Api implementation for [WKWebViewConfiguration].
  late final WKWebViewConfigurationHostApiImpl _webViewConfigurationApi;

  /// Coordinates interactions between your app’s code and the webpage’s scripts and other content.
  late final WKUserContentController userContentController =
      WKUserContentController.fromWebViewConfiguretion(
    this,
    binaryMessenger: _binaryMessenger,
    instanceManager: _instanceManager,
  );

  /// Used to get and set the site’s cookies and to track the cached data objects.
  ///
  /// Represents [WKWebViewConfiguration.webSiteDataStore](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1395661-websitedatastore?language=objc).
  late final WKWebsiteDataStore websiteDataStore =
      WKWebsiteDataStore.fromWebViewConfiguration(
    this,
    binaryMessenger: _binaryMessenger,
    instanceManager: _instanceManager,
  );

  /// Indicates whether HTML5 videos play inline or use the native full-screen controller.
  ///
  /// Sets [WKWebViewConfiguration.allowsInlineMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1614793-allowsinlinemediaplayback?language=objc).
  Future<void> setAllowsInlineMediaPlayback(bool allow) {
    return _webViewConfigurationApi.setAllowsInlineMediaPlaybackFromInstance(
      this,
      allow,
    );
  }

  /// The media types that require a user gesture to begin playing.
  ///
  /// Use [WKAudiovisualMediaType.none] to indicate that no user gestures are
  /// required to begin playing media.
  ///
  /// Sets [WKWebViewConfiguration.mediaTypesRequiringUserActionForPlayback](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration/1851524-mediatypesrequiringuseractionfor?language=objc).
  Future<void> setMediaTypesRequiringUserActionForPlayback(
    Set<WKAudiovisualMediaType> types,
  ) {
    assert(types.isNotEmpty);
    return _webViewConfigurationApi
        .setMediaTypesRequiringUserActionForPlaybackFromInstance(
      this,
      types,
    );
  }
}

/// The methods for presenting native user interface elements on behalf of a webpage.
///
/// Wraps [WKUIDelegate](https://developer.apple.com/documentation/webkit/wkuidelegate?language=objc).
class WKUIDelegate {
  /// Constructs a [WKUIDelegate].
  WKUIDelegate({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _uiDelegateApi = WKUIDelegateHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _uiDelegateApi.createFromInstance(this);
  }

  /// Pigeon Host Api implementation for [WKUIDelegate].
  final WKUIDelegateHostApiImpl _uiDelegateApi;

  /// Indicates a new [WKWebView] was requested to be created with [configuration].
  Future<void> setOnCreateWebView(
    void Function(
      WKWebViewConfiguration configuration,
      WKNavigationAction navigationAction,
    )?
        onCreateWebView,
  ) {
    throw UnimplementedError();
  }
}

/// Methods for handling navigation changes and tracking navigation requests.
///
/// Set the methods of the [WKNavigationDelegate] in the object you use to
/// coordinate changes in your web view’s main frame.
///
/// Wraps [WKNavigationDelegate](https://developer.apple.com/documentation/webkit/wknavigationdelegate?language=objc).
class WKNavigationDelegate {
  /// Constructs a [WKNavigationDelegate].
  WKNavigationDelegate({
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  }) : _navigationDelegateApi = WKNavigationDelegateHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _navigationDelegateApi.createFromInstance(this);
  }

  /// Pigeon Host Api implementation for [WKNavigationDelegate].
  final WKNavigationDelegateHostApiImpl _navigationDelegateApi;

  /// Called when navigation from the main frame has started.
  Future<void> setDidStartProvisionalNavigation(
    void Function(
      WKWebView webView,
      String? url,
    )?
        didStartProvisionalNavigation,
  ) {
    throw UnimplementedError();
  }

  /// Called when navigation is complete.
  Future<void> setDidFinishNavigation(
    void Function(WKWebView webView, String? url)? didFinishNavigation,
  ) {
    throw UnimplementedError();
  }

  /// Called when permission is needed to navigate to new content.
  Future<void> setDecidePolicyForNavigationAction(
      Future<WKNavigationActionPolicy> Function(
    WKWebView webView,
    WKNavigationAction navigationAction,
  )?
          decidePolicyForNavigationAction) {
    throw UnimplementedError();
  }

  /// Called when an error occurred during navigation.
  Future<void> setDidFailNavigation(
    void Function(WKWebView webView, NSError error)? didFailNavigation,
  ) {
    throw UnimplementedError();
  }

  /// Called when an error occurred during the early navigation process.
  Future<void> setDidFailProvisionalNavigation(
    void Function(WKWebView webView, NSError error)?
        didFailProvisionalNavigation,
  ) {
    throw UnimplementedError();
  }

  /// Called when the web view’s content process was terminated.
  Future<void> setWebViewWebContentProcessDidTerminate(
    void Function(WKWebView webView)? webViewWebContentProcessDidTerminate,
  ) {
    throw UnimplementedError();
  }
}

/// Object that displays interactive web content, such as for an in-app browser.
///
/// Wraps [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview?language=objc).
class WKWebView extends NSObject {
  /// Constructs a [WKWebView].
  ///
  /// [configuration] contains the configuration details for the web view. This
  /// method saves a copy of your configuration object. Changes you make to your
  /// original object after calling this method have no effect on the web view’s
  /// configuration. For a list of configuration options and their default
  /// values, see [WKWebViewConfiguration]. If you didn’t create your web view
  /// using the `configuration` parameter, this value uses a default
  /// configuration object.
  WKWebView(
    WKWebViewConfiguration configuration, {
    BinaryMessenger? binaryMessenger,
    InstanceManager? instanceManager,
  })  : _binaryMessenger = binaryMessenger,
        _instanceManager = instanceManager,
        _webviewHostApi = WKWebViewHostApiImpl(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ),
        super(
          binaryMessenger: binaryMessenger,
          instanceManager: instanceManager,
        ) {
    _webviewHostApi.createFromInstance(this, configuration);
  }

  final BinaryMessenger? _binaryMessenger;
  final InstanceManager? _instanceManager;

  /// Pigeon Host Api implementation for [WKWebView].
  final WKWebViewHostApiImpl _webviewHostApi;

  /// Contains the configuration details for the web view.
  ///
  /// Use the object in this property to obtain information about your web
  /// view’s configuration. Because this property returns a copy of the
  /// configuration object, changes you make to that object don’t affect the web
  /// view’s configuration.
  ///
  /// If you didn’t create your web view with a [WKWebViewConfiguration] this
  /// property contains a default configuration object.
  late final WKWebViewConfiguration configuration =
      WKWebViewConfiguration.fromWebView(
    this,
    binaryMessenger: _binaryMessenger,
    instanceManager: _instanceManager,
  );

  /// The scrollable view associated with the web view.
  late final UIScrollView scrollView = UIScrollView.fromWebView(
    this,
    binaryMessenger: _binaryMessenger,
    instanceManager: _instanceManager,
  );

  /// Used to integrate custom user interface elements into web view interactions.
  ///
  /// Sets [WKWebView.UIDelegate](https://developer.apple.com/documentation/webkit/wkwebview/1415009-uidelegate?language=objc).
  Future<void> setUIDelegate(WKUIDelegate? delegate) {
    return _webviewHostApi.setUIDelegateFromInstance(this, delegate);
  }

  /// The object you use to manage navigation behavior for the web view.
  ///
  /// Sets [WKWebView.navigationDelegate](https://developer.apple.com/documentation/webkit/wkwebview/1414971-navigationdelegate?language=objc).
  Future<void> setNavigationDelegate(WKNavigationDelegate? delegate) {
    return _webviewHostApi.setNavigationDelegateFromInstance(this, delegate);
  }

  /// The URL for the current webpage.
  ///
  /// Represents [WKWebView.URL](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url?language=objc).
  Future<String?> getUrl() {
    return _webviewHostApi.getUrlFromInstance(this);
  }

  /// An estimate of what fraction of the current navigation has been loaded.
  ///
  /// This value ranges from 0.0 to 1.0.
  ///
  /// Represents [WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress?language=objc).
  Future<double> getEstimatedProgress() {
    return _webviewHostApi.getEstimatedProgressFromInstance(this);
  }

  /// Loads the web content referenced by the specified URL request object and navigates to it.
  ///
  /// Use this method to load a page from a local or network-based URL. For
  /// example, you might use it to navigate to a network-based webpage.
  Future<void> loadRequest(NSUrlRequest request) {
    return _webviewHostApi.loadRequestFromInstance(this, request);
  }

  /// Loads the contents of the specified HTML string and navigates to it.
  Future<void> loadHtmlString(String string, {String? baseUrl}) {
    return _webviewHostApi.loadHtmlStringFromInstance(this, string, baseUrl);
  }

  /// Loads the web content from the specified file and navigates to it.
  Future<void> loadFileUrl(String url, {required String readAccessUrl}) {
    return _webviewHostApi.loadFileUrlFromInstance(this, url, readAccessUrl);
  }

  /// Loads the Flutter asset specified in the pubspec.yaml file.
  ///
  /// This method is not a part of WebKit and is only a Flutter specific helper
  /// method.
  Future<void> loadFlutterAsset(String key) {
    return _webviewHostApi.loadFlutterAssetFromInstance(this, key);
  }

  /// Indicates whether there is a valid back item in the back-forward list.
  Future<bool> canGoBack() {
    return _webviewHostApi.canGoBackFromInstance(this);
  }

  /// Indicates whether there is a valid forward item in the back-forward list.
  Future<bool> canGoForward() {
    return _webviewHostApi.canGoForwardFromInstance(this);
  }

  /// Navigates to the back item in the back-forward list.
  Future<void> goBack() {
    return _webviewHostApi.goBackFromInstance(this);
  }

  /// Navigates to the forward item in the back-forward list.
  Future<void> goForward() {
    return _webviewHostApi.goForwardFromInstance(this);
  }

  /// Reloads the current webpage.
  Future<void> reload() {
    return _webviewHostApi.reloadFromInstance(this);
  }

  /// The page title.
  ///
  /// Represents [WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title?language=objc).
  Future<String?> getTitle() {
    return _webviewHostApi.getTitleFromInstance(this);
  }

  /// Indicates whether horizontal swipe gestures trigger page navigation.
  ///
  /// The default value is false.
  ///
  /// Sets [WKWebView.allowsBackForwardNavigationGestures](https://developer.apple.com/documentation/webkit/wkwebview/1414995-allowsbackforwardnavigationgestu?language=objc).
  Future<void> setAllowsBackForwardNavigationGestures(bool allow) {
    return _webviewHostApi.setAllowsBackForwardNavigationGesturesFromInstance(
      this,
      allow,
    );
  }

  /// The custom user agent string.
  ///
  /// The default value of this property is null.
  ///
  /// Sets [WKWebView.customUserAgent](https://developer.apple.com/documentation/webkit/wkwebview/1414950-customuseragent?language=objc).
  Future<void> setCustomUserAgent(String? userAgent) {
    return _webviewHostApi.setCustomUserAgentFromInstance(this, userAgent);
  }

  /// Evaluates the specified JavaScript string.
  ///
  /// Throws a `PlatformException` if an error occurs or return value is not
  /// supported.
  Future<Object?> evaluateJavaScript(String javaScriptString) {
    return _webviewHostApi.evaluateJavaScriptFromInstance(
      this,
      javaScriptString,
    );
  }
}
