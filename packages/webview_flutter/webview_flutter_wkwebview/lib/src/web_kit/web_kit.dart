// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import '../foundation/foundation.dart';
import '../ios_kit/ios_kit.dart';

/// Possible error values that WebKit APIs can return.
///
/// See https://developer.apple.com/documentation/webkit/wkerrorcode.
class WebKitError {
  WebKitError._();

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

/// The media types that require a user gesture to begin playing.
///
/// See https://developer.apple.com/documentation/webkit/wkaudiovisualmediatypes?language=objc.
enum AudiovisualMediaType {
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

/// Indicate whether to allow or cancel navigation to a webpage.
///
/// See https://developer.apple.com/documentation/webkit/wknavigationactionpolicy?language=objc.
enum NavigationActionPolicy {
  /// Allow navigation to continue.
  ///
  /// See https://developer.apple.com/documentation/webkit/wknavigationactionpolicy/wknavigationactionpolicyallow?language=objc.
  allow,

  /// Cancel navigation.
  ///
  /// See https://developer.apple.com/documentation/webkit/wknavigationactionpolicy/wknavigationactionpolicycancel?language=objc.
  cancel,
}

/// Times at which to inject script content into a webpage.
///
/// See https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime?language=objc.
enum UserScriptInjectionTime {
  /// Inject the script after the creation of the webpage’s document element, but before loading any other content.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime/wkuserscriptinjectiontimeatdocumentstart?language=objc.
  atDocumentStart,

  /// Inject the script after the document finishes loading, but before loading any other subresources.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkuserscriptinjectiontime/wkuserscriptinjectiontimeatdocumentend?language=objc.
  atDocumentEnd,
}

/// Types of data that websites store.
enum WebsiteDataTypes {
  /// Cookies.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypecookies?language=objc.
  cookies,

  /// In-memory caches.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypememorycache?language=objc.
  memoryCache,

  /// On-disk caches.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypediskcache?language=objc.
  diskCache,

  /// HTML offline web app caches.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypeofflinewebapplicationcache?language=objc.
  offlineWebApplicationCache,

  /// HTML local storage.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypelocalstorage?language=objc.
  localStroage,

  /// HTML session storage.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypesessionstorage?language=objc.
  sessionStorage,

  /// WebSQL databases.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypewebsqldatabases?language=objc.
  sqlDatabases,

  /// IndexedDB databases.
  ///
  /// See https://developer.apple.com/documentation/webkit/wkwebsitedatatypeindexeddbdatabases?language=objc.
  indexedDBDatabases,
}

/// A script that the web view injects into a webpage.
///
/// Create a [UserScript] object when you want to inject custom script code into
/// the pages of your web view. Use this object to specify the JavaScript code
/// to inject, and parameters relating to when and how to inject that code.
/// Before you create the web view, add this object to the
/// [UserContentController] object associated with your web view’s configuration.
class UserScript {
  /// Construct a [UserScript].
  UserScript(this.source, this.injectionTime, {required this.isMainFrameOnly});

  /// The script’s source code.
  final String source;

  /// The time at which to inject the script into the webpage.
  final UserScriptInjectionTime injectionTime;

  /// Indicates whether to inject the script into the main frame or all frames.
  final bool isMainFrameOnly;
}

/// An object that encapsulates a message sent by JavaScript code from a webpage.
class ScriptMessage {
  /// Constructs a [ScriptMessage].
  ScriptMessage({required this.name, this.body});

  /// The name of the message handler to which the message is sent.
  final String name;

  /// The body of the message.
  ///
  /// Allowed types are [num], [String], [List], [Map], [DateTime], and `null`.
  final Object? body;
}

/// An object that contains information about a frame on a webpage.
///
/// An instance of this class is a transient, data-only object; it does not
/// uniquely identify a frame across multiple delegate method calls.
class FrameInfo {
  /// Construct a [FrameInfo].
  FrameInfo({required this.isMainFrame});

  /// Indicates whether the frame is the web site's main frame or a subframe.
  final bool isMainFrame;
}

/// An object that contains information about an action that causes navigation to occur.
///
/// Use a [NavigationAction] object to make policy decisions about whether to
/// allow navigation within your app’s web view. You don’t create
/// [NavigationAction objects directly. Instead, the web view creates them and
/// delivers them to the appropriate delegate objects. Use the methods of your
/// delegate to analyze the action and determine whether to allow the resulting
/// navigation to occur.
class NavigationAction {
  /// Constructs a [NavigationAction].
  NavigationAction({required this.request, required this.targetFrame});

  /// The URL request object associated with the navigation action.
  final UrlRequest request;

  /// The frame in which to display the new content.
  final FrameInfo targetFrame;
}

/// Manages cookies, disk and memory caches, and other types of data for a web view.
///
/// Use a [WebsiteDataStore] object to configure and manage web site data.
/// Specifically, use this object to:
///
/// * Manage cookies that your web site uses
/// * Learn about the types of data that websites store
/// * Remove unwanted web site data
class WebsiteDataStore extends FoundationObject {
  WebsiteDataStore._defaultDataStore() {
    throw UnimplementedError();
  }

  /// The default data store, which stores data persistently to disk.
  ///
  /// Use this data store to retain the state of web content between browsing
  /// sessions.
  static final WebsiteDataStore defaultDataStore =
      WebsiteDataStore._defaultDataStore();

  /// Removes website data that changed after the specified date.
  ///
  /// This method removes the specified data type from all records, but only if
  /// a website modified the record’s data after the specified date.
  Future<void> removeDataOfTypes(
    Set<WebsiteDataTypes> dataTypes,
    DateTime since,
  ) {
    assert(dataTypes.isNotEmpty);
    throw UnimplementedError();
  }
}

/// A collection of properties that you use to initialize a web view.
///
/// A [WebViewConfiguration] object provides information about how to configure
/// a [WebView] object. Use your configuration object to specify:
///
/// * The initial cookies to make available to your web content
/// * Handlers for any custom URL schemes your web content uses
/// * Settings for how to handle media content
/// * Information about how to manage selections within the web view
/// * Custom scripts to inject into the webpage
/// * Custom rules that determine how to render content
///
/// You create a [WebViewConfiguration] object in your code, configure its
/// properties, and pass it to the initializer of your [WebView] object. The web
/// view incorporates your configuration settings only at creation time; you
/// cannot change those settings dynamically later.
class WebViewConfiguration extends FoundationObject {
  /// Manages the preference-related settings for the web view.
  ///
  /// Use the preferences object in this property to customize the rendering,
  /// JavaScript, and other preferences related to your web view. You can also
  /// change the preferences by assigning a new [Preferences] object to this
  /// field.
  set preferences(Preferences preferences) {
    throw UnimplementedError();
  }

  /// Coordinates interactions between native code and the webpage’s scripts and other content.
  set userContentController(UserContentController userContentController) {
    throw UnimplementedError();
  }

  /// Indicates whether HTML5 videos play inline or use the native full-screen controller.
  set allowsInlineMediaPlayback(bool allow) {
    throw UnimplementedError();
  }

  /// The media types that require a user gesture to begin playing.
  ///
  /// Use [AudiovisualMediaType.none] to indicate that no user gestures are
  /// required to begin playing media.
  set mediaTypesRequiringUserActionForPlayback(
    Set<AudiovisualMediaType> types,
  ) {
    assert(types.isNotEmpty);
    throw UnimplementedError();
  }

  /// Indicates whether HTML5 videos require the user to start playing them.
  ///
  /// Deprecated for iOS >= 10.0.
  ///
  /// Passing false indicates the videos can play automatically.
  @Deprecated(
    'Deprecated for iOS 10.0+. '
    'Please use WebViewConfiguration.mediaTypesRequiringUserActionForPlayback.',
  )
  set requiresUserActionForMediaPlayback(bool required) {
    throw UnimplementedError();
  }

  /// Deprecated for iOS >= 9.0.
  @Deprecated(
    'Deprecated for iOS 9.0+. '
    'Please use WebViewConfiguration.mediaTypesRequiringUserActionForPlayback.',
  )
  set mediaPlaybackRequiresUserAction(bool required) {
    throw UnimplementedError();
  }
}

/// An object that encapsulates the standard behaviors to apply to websites.
class Preferences extends FoundationObject {
  // TODO(bparrishMines): Replaced for iOS 14.0+. Add support for alternative.
  /// Sets whether JavaScript is enabled.
  ///
  /// The default value is true. Setting this property to false disables
  /// JavaScripts that are loaded or executed by the webpage. This setting does
  /// not affect user scripts. See [UserContentController].
  set javaScriptEnabled(bool javaScriptEnabled) {
    throw UnimplementedError();
  }
}

/// An interface for receiving messages from JavaScript code running in a webpage.
///
/// Implement the [ScriptMessageHandler] protocol when your app needs a way to
/// respond to JavaScript messages in the web view. When JavaScript code sends a
/// message that specifically targets your message handler, WebKit calls your
/// handler’s [didReceiveScriptMessage] method. Use that method to implement
/// your response. For example, you might update other parts of your app in
/// response to web content changes.
///
/// To call your message handler from JavaScript, call the function
/// `window.webkit.messageHandlers.<messageHandlerName>.postMessage(<messageBody>)`
/// in your code. You specify the value of <messageHandlerName> when you install
/// your message handler in a [UserContentController] object.
abstract class ScriptMessageHandler {
  /// Tells the handler that a webpage sent a script message.
  ///
  /// Use this method to respond to a message sent from the webpage’s
  /// JavaScript code. Use the [message] parameter to get the message contents and
  /// to determine the originating web view.
  void didReceiveScriptMessage(
    UserContentController userContentController,
    ScriptMessage message,
  );
}

/// Manages interactions between JavaScript code and your web view.
///
/// A [UserContentController] object provides a bridge between your app and the
/// JavaScript code running in the web view. Use this object to do the
/// following:
///
/// * Inject JavaScript code into webpages running in your web view.
/// * Install custom JavaScript functions that call through to your app’s native
///   code.
///
/// Create and configure a [UserContentController] object as part of your
/// overall web view setup. Assign the object to the userContentController
/// field of your [WebViewConfiguration] object before creating your web view.
class UserContentController extends FoundationObject {
  /// Installs a message handler that you can call from your JavaScript code.
  ///
  /// [handler]: The message handler object that implements your custom code.
  /// This object must extend the [ScriptMessageHandler] class.
  ///
  /// [name]: The name of the message handler. This parameter must be unique
  /// within the user content controller and must not be an empty string. The
  /// user content controller uses this parameter to define a JavaScript
  /// function for your message handler in the page’s main content world. The
  /// name of this function is
  /// `window.webkit.messageHandlers.<name>.postMessage(<messageBody>)`, where
  /// `<name>` corresponds to the value of this parameter. For example, if you
  /// specify the string `MyFunction`, the user content controller defines the `
  /// window.webkit.messageHandlers.MyFunction.postMessage()` function in
  /// JavaScript.
  Future<void> addScriptMessageHandler(
    ScriptMessageHandler handler,
    String name,
  ) {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  /// Uninstalls all custom message handlers associated with the user content controller.
  Future<void> removeAllScriptMessageHandlers() {
    throw UnimplementedError();
  }

  /// Injects the specified script into the webpage’s content.
  Future<void> addUserScript(UserScript userScript) {
    throw UnimplementedError();
  }

  /// Removes all user scripts from the web view.
  Future<void> removeAllUserScripts() {
    throw UnimplementedError();
  }
}

/// Methods for accepting or rejecting navigation changes.
///
/// Also tracks the progress of navigation requests.
///
/// Implement the methods of the [NavigationDelegate] in the object you use to
/// coordinate changes in your web view’s main frame. As the user attempts to
/// navigate web content, the web view coordinates with its navigation delegate
/// to manage any transitions. For example, you might use these methods to
/// restrict navigation from specific links within your content. You might also
/// use them to track the progress of requests, and to respond to errors and
/// authentication challenges.
abstract class NavigationDelegate {
  /// Tells the delegate that navigation from the main frame has started.
  void didStartProvisionalNavigation(WebView webView) {}

  /// Tells the delegate that navigation is complete.
  void didFinishNavigation(WebView webView) {}

  /// Asks the delegate for permission to navigate to new content.
  ///
  /// Use this method to allow or deny a navigation request that originated with
  /// the specified action. The web view calls this method after the interaction
  /// occurs but before it attempts to load any content.
  Future<NavigationActionPolicy> decidePolicyForNavigationAction(
    WebView webView,
    NavigationAction navigationAction,
  ) {
    return Future<NavigationActionPolicy>.value(NavigationActionPolicy.allow);
  }

  /// Tells the delegate that an error occurred during navigation.
  void didFailNavigation(WebView webView, FoundationError error) {}

  /// Tells the delegate that an error occurred during the early navigation process.
  void didFailProvisionalNavigation(WebView webView, FoundationError error) {}

  /// Tells the delegate that the web view’s content process was terminated.
  void webViewWebContentProcessDidTerminate(WebView webView) {}
}

/// Object that displays interactive web content, such as for an in-app browser.
///
/// A [WebView] object is a platform-native view that you use to incorporate web
/// content seamlessly into your app’s UI. A web view supports a full
/// web-browsing experience, and presents HTML, CSS, and JavaScript content
/// alongside your app’s native views. Use it when web technologies satisfy your
/// app’s layout and styling requirements more readily than native views. For
/// example, you might use it when your app’s content changes frequently.
///
/// A web view offers control over the navigation and user experience through
/// delegate objects. Use the navigation delegate to react when the user clicks
/// links in your web content, or interacts with the content in a way that
/// affects navigation. For example, you might prevent the user from navigating
/// to new content unless specific conditions are met. Use the UI delegate to
/// present native UI elements, such as alerts or contextual menus, in response
/// to interactions with your web content.
///
/// For more extensive customizations, create your web view using a
/// [WebViewConfiguration] object. For example, use a web view configuration
/// object to specify handlers for custom URL schemes, manage cookies, and
/// customize preferences for your web content.
///
/// Before your web view appears onscreen, load content from a web server using
/// a [UrlRequest] class or load content directly from a local file or HTML
/// string. The web view automatically loads embedded resources such as images
/// or videos as part of the initial load request. It then renders your content
/// and displays the results inside the view’s bounds rectangle.
///
/// A web view automatically converts telephone numbers that appear in web
/// content to Phone links. When the user taps a Phone link, the Phone app
/// launches and dials the number. Use the [WebViewConfiguration] object to
/// change the default data detector behavior.
///
/// **Managing the Navigation Through Your Web Content**
/// [WebView[ provides a complete browsing experience, including the ability to
/// navigate between different webpages using links, forward and back buttons,
/// and more. When the user clicks a link in your content, the web view acts
/// like a browser and displays the content at that link. To disallow
/// navigation, or to customize your web view’s navigation behavior,
/// provide your web view with a navigation delegate — that is, an object that
/// extends the [NavigationDelegate] class. Use your navigation delegate to
/// modify the web view’s navigation behavior, or to track the loading progress
/// of new content.
///
/// You can also use the methods of [WebView] to navigate programmatically
/// through your content, or to trigger navigation from other parts of your
/// app’s interface. For example, if your UI includes forward and back buttons,
/// connect those buttons to the [goBack] and [goForward] methods of your web
/// view to trigger the corresponding web navigation. Use the [canGoBack] and
/// [canGoForward] fields to determine when to enable or disable your buttons.
class WebView extends IosView {
  /// Construct a [WebView].
  ///
  /// [configuration] contains the configuration details for the web view. This
  /// method saves a copy of your configuration object. Changes you make to your
  /// original object after calling this method have no effect on the web view’s
  /// configuration. For a list of configuration options and their default
  /// values, see [WebViewConfiguration]. If you didn’t create your web view
  /// using the `configuration` parameter, this field contains a default
  /// configuration object.
  // TODO(bparrishMines): Remove ignore once constructor is implemented.
  // ignore: avoid_unused_constructor_parameters
  WebView([WebViewConfiguration? configuration]) {
    throw UnimplementedError();
  }

  /// The scrollable view associated with the web view.
  // TODO(bparrishMines): Replace with api method to retrieve the ScrollView.
  late final Future<ScrollView> scrollView =
      Future<ScrollView>.value(ScrollView());

  /// Loads the web content referenced by the specified URL request object and navigates to it.
  ///
  /// Use this method to load a page from a local or network-based URL. For
  /// example, you might use it to navigate to a network-based webpage.
  Future<void> loadRequest(UrlRequest request) {
    throw UnimplementedError();
  }

  /// Loads the contents of the specified HTML string and navigates to it.
  ///
  /// Use this method to navigate to a webpage that you loaded or created
  /// yourself. For example, you might use this method to load HTML content that
  /// your app generates programmatically.
  ///
  /// [string] The string to use as the contents of the webpage.
  ///
  /// [baseUrl] The base URL to use when resolving relative URLs within the HTML
  /// string.
  Future<void> loadHtmlString(String string, String? baseUrl) {
    throw UnimplementedError();
  }

  /// Loads the web content from the specified file and navigates to it.
  ///
  /// [url] The URL of a file that contains web content. This URL must be a
  /// file-based URL.
  ///
  /// [readAccessUrl] The URL from which to read the web content. This URL must
  /// be a file-based URL. Specify the same value as the URL parameter to
  /// prevent WebKit from reading any other content. Specify a directory to give
  /// WebKit permission to read additional files in the specified directory.
  Future<void> loadFileUrl(String url, String readAccessUrl) {
    throw UnimplementedError();
  }

  /// Indicates whether there is a valid back item in the back-forward list.
  Future<bool> get canGoBack {
    throw UnimplementedError();
  }

  /// Indicates whether there is a valid forward item in the back-forward list.
  Future<bool> get canGoForward {
    throw UnimplementedError();
  }

  /// Navigates to the back item in the back-forward list.
  Future<void> goBack() {
    throw UnimplementedError();
  }

  /// Navigates to the forward item in the back-forward list.
  Future<void> goForward() {
    throw UnimplementedError();
  }

  /// Reloads the current webpage.
  Future<void> reload() {
    throw UnimplementedError();
  }

  /// The URL for the current webpage.
  ///
  /// This field contains the URL for the webpage that the web view currently
  /// displays. Use this URL in places where you reflect the webpage address in
  /// your app’s user interface.
  ///
  /// [WebView] is key-value observing (KVO) compliant for this property.
  Future<String?> get url {
    throw UnimplementedError();
  }

  /// The page title.
  Future<String?> get title {
    throw UnimplementedError();
  }

  /// WKWebView is key-value observing (KVO) compliant for this property.
  Future<double> get estimatedProgress {
    throw UnimplementedError();
  }

  /// Indicates whether horizontal swipe gestures trigger page navigation.
  ///
  /// The default value is false.
  set allowsBackForwardNavigationGestures(bool allow) {
    throw UnimplementedError();
  }

  /// The custom user agent string.
  ///
  /// The default value of this property is null.
  set customUserAgent(String? userAgent) {
    throw UnimplementedError();
  }

  /// Evaluates the specified JavaScript string.
  ///
  /// Throws a `PlatformException` if an error occurs or return value is not
  /// supported.
  Future<String?> evaluateJavaScript(String javaScriptString) {
    throw UnimplementedError();
  }

  /// The object you use to manage navigation behavior for the web view.
  ///
  /// Provide a delegate object when you want to manage or restrict navigation
  /// in your web content, track the progress of navigation requests, and handle
  /// authentication challenges for any new content. The object you specify must
  /// extend the [NavigationDelegate] class.
  set navigationDelegate(NavigationDelegate delegate) {
    throw UnimplementedError();
  }

  /// Used to integrate custom user interface elements into web view interactions.
  set iosDelegate(IosDelegate delegate) {
    throw UnimplementedError();
  }
}

/// The methods for presenting native user interface elements on behalf of a webpage.
///
/// Web view user interface delegates implement this protocol to control the
/// opening of new windows, augment the behavior of default menu items displayed
/// when the user clicks elements, and perform other user interface–related
/// tasks. These methods can be invoked as a result of handling JavaScript or
/// other plug-in content. The default web view implementation assumes one
/// window per web view, so nonconventional user interfaces might implement a
/// user interface delegate.
abstract class IosDelegate {
  /// Indicates a new [WebView] was requested to be created with [configuration].
  ///
  /// The method requires no action, only indicates a new WebView was created.
  /// The platform implementation requests a new WebView to be returned but this
  /// can't be handled synchronously so it always returns null on the platform
  /// side.
  ///
  /// See [webView:createWebViewWithConfiguration:forNavigationAction:windowFeatures:](https://developer.apple.com/documentation/webkit/wkuidelegate/1536907-webview?language=objc)
  /// for more information.
  void onCreateWebView(
    WebViewConfiguration configuration,
    NavigationAction navigationAction,
  ) {}
}
