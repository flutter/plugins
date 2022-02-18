// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../foundation/foundation.dart';

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

/// An interface for receiving messages from JavaScript code running in a webpage.
///
/// Wraps [WKScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkscriptmessagehandler?language=objc)
class WKScriptMessageHandler {
  /// Tells the handler that a webpage sent a script message.
  ///
  /// Use this method to respond to a message sent from the webpage’s
  /// JavaScript code. Use the [message] parameter to get the message contents and
  /// to determine the originating web view.
  set didReceiveScriptMessage(
    void Function(
      WKUserContentController userContentController,
      WKScriptMessage message,
    )
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
  /// Constructs a [WKUserContentController].
  WKUserContentController();

  // A WKUserContentController that is owned by configuration.
  WKUserContentController._fromWebViewConfiguretion(
    // TODO(bparrishMines): Remove ignore once constructor is implemented.
    // ignore: avoid_unused_constructor_parameters
    WKWebViewConfiguration configuration,
  );

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
  Future<void> addUserScript(WKUserScript userScript) {
    throw UnimplementedError();
  }

  /// Removes all user scripts from the web view.
  Future<void> removeAllUserScripts() {
    throw UnimplementedError();
  }
}

/// A collection of properties that you use to initialize a web view.
///
/// Wraps [WKWebViewConfiguration](https://developer.apple.com/documentation/webkit/wkwebviewconfiguration?language=objc).
class WKWebViewConfiguration {
  /// Constructs a [WKWebViewConfiguration].
  WKWebViewConfiguration({required this.userContentController});

  // A WKWebViewConfiguration that is owned by webView.
  // TODO(bparrishMines): Remove ignore once constructor is implemented.
  // ignore: avoid_unused_constructor_parameters
  WKWebViewConfiguration._fromWebView(WKWebView webView) {
    userContentController =
        WKUserContentController._fromWebViewConfiguretion(this);
  }

  /// Coordinates interactions between your app’s code and the webpage’s scripts and other content.
  late final WKUserContentController userContentController;

  /// Indicates whether HTML5 videos play inline or use the native full-screen controller.
  set allowsInlineMediaPlayback(bool allow) {
    throw UnimplementedError();
  }

  /// The media types that require a user gesture to begin playing.
  ///
  /// Use [WKAudiovisualMediaType.none] to indicate that no user gestures are
  /// required to begin playing media.
  set mediaTypesRequiringUserActionForPlayback(
    Set<WKAudiovisualMediaType> types,
  ) {
    assert(types.isNotEmpty);
    throw UnimplementedError();
  }
}

/// The methods for presenting native user interface elements on behalf of a webpage.
///
/// Wraps [WKUIDelegate](https://developer.apple.com/documentation/webkit/wkuidelegate?language=objc).
class WKUIDelegate {
  /// Indicates a new [WebView] was requested to be created with [configuration].
  set onCreateWebView(
    void Function(
      WKWebViewConfiguration configuration,
      WKNavigationAction navigationAction,
    )
        onCreateeWebView,
  ) {
    throw UnimplementedError();
  }
}

/// Object that displays interactive web content, such as for an in-app browser.
///
/// Wraps [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview?language=objc).
class WKWebView {
  /// Constructs a [WKWebView].
  ///
  /// [configuration] contains the configuration details for the web view. This
  /// method saves a copy of your configuration object. Changes you make to your
  /// original object after calling this method have no effect on the web view’s
  /// configuration. For a list of configuration options and their default
  /// values, see [WKWebViewConfiguration]. If you didn’t create your web view
  /// using the `configuration` parameter, this value uses a default
  /// configuration object.
  // TODO(bparrishMines): Remove ignore once constructor is implemented.
  // ignore: avoid_unused_constructor_parameters
  WKWebView([WKWebViewConfiguration? configuration]) {
    throw UnimplementedError();
  }

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
      WKWebViewConfiguration._fromWebView(this);

  /// Used to integrate custom user interface elements into web view interactions.
  set uiDelegate(WKUIDelegate delegate) {
    throw UnimplementedError();
  }

  /// Loads the web content referenced by the specified URL request object and navigates to it.
  ///
  /// Use this method to load a page from a local or network-based URL. For
  /// example, you might use it to navigate to a network-based webpage.
  Future<void> loadRequest(NSUrlRequest request) {
    throw UnimplementedError();
  }
}
