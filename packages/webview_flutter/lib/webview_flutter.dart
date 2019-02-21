// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef void WebViewCreatedCallback(WebViewController controller);

enum JavascriptMode {
  /// JavaScript execution is disabled.
  disabled,

  /// JavaScript execution is not restricted.
  unrestricted,
}

/// A message that was sent by JavaScript code running in a [WebView].
class JavascriptMessage {
  /// Constructs a JavaScript message object.
  ///
  /// The `message` parameter must not be null.
  const JavascriptMessage(this.message) : assert(message != null);

  /// The contents of the message that was sent by the JavaScript code.
  final String message;
}

/// Callback type for handling messages sent from Javascript running in a web view.
typedef void JavascriptMessageHandler(JavascriptMessage message);

final RegExp _validChannelNames = RegExp('^[a-zA-Z_][a-zA-Z0-9]*\$');

/// A named channel for receiving messaged from JavaScript code running inside a web view.
class JavascriptChannel {
  /// Constructs a Javascript channel.
  ///
  /// The parameters `name` and `onMessageReceived` must not be null.
  JavascriptChannel({
    @required this.name,
    @required this.onMessageReceived,
  })  : assert(name != null),
        assert(onMessageReceived != null),
        assert(_validChannelNames.hasMatch(name));

  /// The channel's name.
  ///
  /// Passing this channel object as part of a [WebView.javascriptChannels] adds a channel object to
  /// the Javascript window object's property named `name`.
  ///
  /// The name must start with a letter or underscore(_), followed by any combination of those
  /// characters plus digits.
  ///
  /// Note that any JavaScript existing `window` property with this name will be overriden.
  ///
  /// See also [WebView.javascriptChannels] for more details on the channel registration mechanism.
  final String name;

  /// A callback that's invoked when a message is received through the channel.
  final JavascriptMessageHandler onMessageReceived;
}

/// A web view widget for showing html content.
class WebView extends StatefulWidget {
  /// Creates a new web view.
  ///
  /// The web view can be controlled using a `WebViewController` that is passed to the
  /// `onWebViewCreated` callback once the web view is created.
  ///
  /// The `javascriptMode` parameter must not be null.
  const WebView({
    Key key,
    this.onWebViewCreated,
    this.initialUrl,
    this.javascriptMode = JavascriptMode.disabled,
    this.javascriptChannels,
    this.gestureRecognizers,
    this.zoom = false,
  })  : assert(javascriptMode != null),
        super(key: key);

  /// If not null invoked once the web view is created.
  final WebViewCreatedCallback onWebViewCreated;

  /// Which gestures should be consumed by the web view.
  ///
  /// It is possible for other gesture recognizers to be competing with the web view on pointer
  /// events, e.g if the web view is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The web view will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty or null, the web view will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  /// The initial URL to load.
  final String initialUrl;

  /// Whether Javascript execution is enabled.
  final JavascriptMode javascriptMode;

  /// The set of [JavascriptChannel]s available to JavaScript code running in the web view.
  ///
  /// For each [JavascriptChannel] in the set, a channel object is made available for the
  /// JavaScript code in a window property named [JavascriptChannel.name].
  /// The JavaScript code can then call `postMessage` on that object to send a message that will be
  /// passed to [JavascriptChannel.onMessageReceived].
  ///
  /// For example for the following JavascriptChannel:
  ///
  /// ```dart
  /// JavascriptChannel(name: 'Print', onMessageReceived: (String message) { print(message); });
  /// ```
  ///
  /// JavaScript code can call:
  ///
  /// ```javascript
  /// Print.postMessage('Hello');
  /// ```
  ///
  /// To asynchronously invoke the message handler which will print the message to standard output.
  ///
  /// Adding a new JavaScript channel only takes affect after the next page is loaded.
  ///
  /// Set values must not be null. A [JavascriptChannel.name] cannot be the same for multiple
  /// channels in the list.
  ///
  /// A null value is equivalent to an empty set.
  final Set<JavascriptChannel> javascriptChannels;
  
  /// Enable/Disable zoom.
  final bool zoom;
  
  @override
  State<StatefulWidget> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  _WebSettings _settings;

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return GestureDetector(
        // We prevent text selection by intercepting the long press event.
        // This is a temporary stop gap due to issues with text selection on Android:
        // https://github.com/flutter/flutter/issues/24585 - the text selection
        // dialog is not responding to touch events.
        // https://github.com/flutter/flutter/issues/24584 - the text selection
        // handles are not showing.
        // TODO(amirh): remove this when the issues above are fixed.
        onLongPress: () {},
        child: AndroidView(
          viewType: 'plugins.flutter.io/webview',
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
          // WebView content is not affected by the Android view's layout direction,
          // we explicitly set it here so that the widget doesn't require an ambient
          // directionality.
          layoutDirection: TextDirection.rtl,
          creationParams: _CreationParams.fromWidget(widget).toMap(),
          creationParamsCodec: const StandardMessageCodec(),
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins.flutter.io/webview',
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: _CreationParams.fromWidget(widget).toMap(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the webview_flutter plugin');
  }

  @override
  void initState() {
    super.initState();
    _assertJavascriptChannelNamesAreUnique();
  }

  @override
  void didUpdateWidget(WebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _assertJavascriptChannelNamesAreUnique();
    _updateConfiguration(_WebSettings.fromWidget(widget));
  }

  Future<void> _updateConfiguration(_WebSettings settings) async {
    _settings = settings;
    final WebViewController controller = await _controller.future;
    controller._updateSettings(settings);
    controller._updateJavascriptChannels(widget.javascriptChannels);
  }

  void _onPlatformViewCreated(int id) {
    final WebViewController controller = WebViewController._(
      id,
      _WebSettings.fromWidget(widget),
      widget.javascriptChannels,
    );
    _controller.complete(controller);
    if (widget.onWebViewCreated != null) {
      widget.onWebViewCreated(controller);
    }
  }

  void _assertJavascriptChannelNamesAreUnique() {
    if (widget.javascriptChannels == null ||
        widget.javascriptChannels.isEmpty) {
      return;
    }
    assert(_extractChannelNames(widget.javascriptChannels).length ==
        widget.javascriptChannels.length);
  }
}

Set<String> _extractChannelNames(Set<JavascriptChannel> channels) {
  final Set<String> channelNames = channels == null
      ? Set<String>()
      : channels.map((JavascriptChannel channel) => channel.name).toSet();
  return channelNames;
}

class _CreationParams {
  _CreationParams(
      {this.initialUrl, this.settings, this.javascriptChannelNames});

  static _CreationParams fromWidget(WebView widget) {
    return _CreationParams(
      initialUrl: widget.initialUrl,
      settings: _WebSettings.fromWidget(widget),
      javascriptChannelNames:
          _extractChannelNames(widget.javascriptChannels).toList(),
    );
  }

  final String initialUrl;

  final _WebSettings settings;

  final List<String> javascriptChannelNames;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'initialUrl': initialUrl,
      'settings': settings.toMap(),
      'javascriptChannelNames': javascriptChannelNames,
    };
  }
}

class _WebSettings {
  _WebSettings({
    this.javascriptMode,
    this.zoom
  });

  static _WebSettings fromWidget(WebView widget) {
    return _WebSettings(javascriptMode: widget.javascriptMode, zoom: widget.zoom);
  }

  final JavascriptMode javascriptMode;
  final bool zoom;
  
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'jsMode': javascriptMode.index,
      'zoom': zoom,
    };
  }

  Map<String, dynamic> updatesMap(_WebSettings newSettings) {
    if (javascriptMode == newSettings.javascriptMode) {
      return null;
    }
    return <String, dynamic>{
      'jsMode': newSettings.javascriptMode.index,
      'zoom': newSettings.zoom,
    };
  }
}

/// Controls a [WebView].
///
/// A [WebViewController] instance can be obtained by setting the [WebView.onWebViewCreated]
/// callback for a [WebView] widget.
class WebViewController {
  WebViewController._(
      int id, this._settings, Set<JavascriptChannel> javascriptChannels)
      : _channel = MethodChannel('plugins.flutter.io/webview_$id') {
    _updateJavascriptChannelsFromSet(javascriptChannels);
    _channel.setMethodCallHandler(_onMethodCall);
  }

  final MethodChannel _channel;

  _WebSettings _settings;

  // Maps a channel name to a channel.
  Map<String, JavascriptChannel> _javascriptChannels =
      <String, JavascriptChannel>{};

  Future<void> _onMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'javascriptChannelMessage':
        final String channel = call.arguments['channel'];
        final String message = call.arguments['message'];
        _javascriptChannels[channel]
            .onMessageReceived(JavascriptMessage(message));
        break;
    }
  }

  /// Loads the specified URL.
  ///
  /// `url` must not be null.
  ///
  /// Throws an ArgumentError if `url` is not a valid URL string.
  Future<void> loadUrl(String url) async {
    assert(url != null);
    _validateUrlString(url);
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod('loadUrl', url);
  }

  /// Accessor to the current URL that the WebView is displaying.
  ///
  /// If [WebView.initialUrl] was never specified, returns `null`.
  /// Note that this operation is asynchronous, and it is possible that the
  /// current URL changes again by the time this function returns (in other
  /// words, by the time this future completes, the WebView may be displaying a
  /// different URL).
  Future<String> currentUrl() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final String url = await _channel.invokeMethod('currentUrl');
    return url;
  }

  /// Checks whether there's a back history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoBack" state has
  /// changed by the time the future completed.
  Future<bool> canGoBack() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final bool canGoBack = await _channel.invokeMethod("canGoBack");
    return canGoBack;
  }

  /// Checks whether there's a forward history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoForward" state has
  /// changed by the time the future completed.
  Future<bool> canGoForward() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final bool canGoForward = await _channel.invokeMethod("canGoForward");
    return canGoForward;
  }

  /// Goes back in the history of this WebView.
  ///
  /// If there is no back history item this is a no-op.
  Future<void> goBack() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod("goBack");
  }

  /// Goes forward in the history of this WebView.
  ///
  /// If there is no forward history item this is a no-op.
  Future<void> goForward() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod("goForward");
  }

  /// Reloads the current URL.
  Future<void> reload() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod("reload");
  }

  /// Clears all caches used by the [WebView].
  ///
  /// The following caches are cleared:
  ///	1. Browser HTTP Cache.
  ///	2. [Cache API](https://developers.google.com/web/fundamentals/instant-and-offline/web-storage/cache-api) caches.
  ///    These are not yet supported in iOS WkWebView. Service workers tend to use this cache.
  ///	3. Application cache.
  ///	4. Local Storage.
  ///
  /// Note: Calling this method also triggers a reload.
  Future<void> clearCache() async {
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    await _channel.invokeMethod("clearCache");
    return reload();
  }

  Future<void> _updateSettings(_WebSettings setting) async {
    final Map<String, dynamic> updateMap = _settings.updatesMap(setting);
    if (updateMap == null) {
      return null;
    }
    _settings = setting;
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _channel.invokeMethod('updateSettings', updateMap);
  }

  Future<void> _updateJavascriptChannels(
      Set<JavascriptChannel> newChannels) async {
    final Set<String> currentChannels = _javascriptChannels.keys.toSet();
    final Set<String> newChannelNames = _extractChannelNames(newChannels);
    final Set<String> channelsToAdd =
        newChannelNames.difference(currentChannels);
    final Set<String> channelsToRemove =
        currentChannels.difference(newChannelNames);
    if (channelsToRemove.isNotEmpty) {
      // TODO(amirh): remove this when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      _channel.invokeMethod(
          'removeJavascriptChannels', channelsToRemove.toList());
    }
    if (channelsToAdd.isNotEmpty) {
      // TODO(amirh): remove this when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      _channel.invokeMethod('addJavascriptChannels', channelsToAdd.toList());
    }
    _updateJavascriptChannelsFromSet(newChannels);
  }

  void _updateJavascriptChannelsFromSet(Set<JavascriptChannel> channels) {
    _javascriptChannels.clear();
    if (channels == null) {
      return;
    }
    for (JavascriptChannel channel in channels) {
      _javascriptChannels[channel.name] = channel;
    }
  }

  /// Evaluates a JavaScript expression in the context of the current page.
  ///
  /// On Android returns the evaluation result as a JSON formatted string.
  ///
  /// On iOS depending on the value type the return value would be one of:
  ///
  ///  - For primitive JavaScript types: the value string formatted (e.g JavaScript 100 returns '100').
  ///  - For JavaScript arrays of supported types: a string formatted NSArray(e.g '(1,2,3), note that the string for NSArray is formatted and might contain newlines and extra spaces.').
  ///  - Other non-primitive types are not supported on iOS and will complete the Future with an error.
  ///
  /// The Future completes with an error if a JavaScript error occurred, or on iOS, if the type of the
  /// evaluated expression is not supported as described above.
  Future<String> evaluateJavascript(String javascriptString) async {
    if (_settings.javascriptMode == JavascriptMode.disabled) {
      throw FlutterError(
          'JavaScript mode must be enabled/unrestricted when calling evaluateJavascript.');
    }
    if (javascriptString == null) {
      throw ArgumentError('The argument javascriptString must not be null. ');
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    final String result =
        await _channel.invokeMethod('evaluateJavascript', javascriptString);
    return result;
  }
}

/// Manages cookies pertaining to all [WebView]s.
class CookieManager {
  /// Creates a [CookieManager] -- returns the instance if it's already been called.
  factory CookieManager() {
    return _instance ??= CookieManager._();
  }

  CookieManager._();

  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/cookie_manager');
  static CookieManager _instance;

  /// Clears all cookies.
  ///
  /// This is supported for >= IOS 9.
  ///
  /// Returns true if cookies were present before clearing, else false.
  Future<bool> clearCookies() => _channel
      // TODO(amirh): remove this when the invokeMethod update makes it to stable Flutter.
      // https://github.com/flutter/flutter/issues/26431
      // ignore: strong_mode_implicit_dynamic_method
      .invokeMethod('clearCookies')
      .then<bool>((dynamic result) => result);
}

// Throws an ArgumentError if `url` is not a valid URL string.
void _validateUrlString(String url) {
  try {
    final Uri uri = Uri.parse(url);
    if (uri.scheme.isEmpty) {
      throw ArgumentError('Missing scheme in URL string: "$url"');
    }
  } on FormatException catch (e) {
    throw ArgumentError(e);
  }
}
