// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter_android/webview_surface_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate Example</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/">https://www.youtube.com/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

class WebViewExample extends StatefulWidget {
  WebViewPlatform platform = SurfaceAndroidWebView();

  @override
  _WebViewExampleState createState() => _WebViewExampleState();

  void onPageStarted(String url) {
    print('Page started loading: $url');
  }

  void onPageFinished(String url) {
    print('Page finished loading: $url');
  }

  void onProgress(int progress) {
    print("WebView is loading (progress : $progress%)");
  }

  void onWebResourceError(WebResourceError error) {
    print("Webview resource error encountered: ${error.description}");
  }
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  late final JavascriptChannelRegistry _javascriptChannelRegistry;
  late final _PlatformCallbacksHandler _platformCallbacksHandler;

  @override
  void initState() {
    super.initState();
    _javascriptChannelRegistry = JavascriptChannelRegistry({
      _toasterJavascriptChannel(),
    });
    _platformCallbacksHandler = _PlatformCallbacksHandler(widget);
  }

  @override
  void didUpdateWidget(WebViewExample oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.future.then((WebViewController controller) {
      _platformCallbacksHandler._widget = widget;
      controller._updateWidget(widget);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
          SampleMenu(_controller.future),
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return widget.platform.build(
          context: context,
          onWebViewPlatformCreated: (WebViewPlatformController? webViewPlatformController) {
            WebViewController controller = WebViewController._(
              widget,
              webViewPlatformController!,
              _platformCallbacksHandler,
              _javascriptChannelRegistry,
            );
            _controller.complete(controller);
          },
          webViewPlatformCallbacksHandler: _platformCallbacksHandler,
          creationParams: CreationParams(
            initialUrl: 'https://flutter.dev',
            webSettings: _webSettingsFromWidget(widget),
            javascriptChannelNames: _javascriptChannelRegistry.channels.keys.toSet(),
            autoMediaPlaybackPolicy: AutoMediaPlaybackPolicy.require_user_action_for_all_media_types,
          ),
          javascriptChannelRegistry: _javascriptChannelRegistry,
        );
      }),
      floatingActionButton: favoriteButton(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel() {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          if (context != null) {
            // ignore: deprecated_member_use
            Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          }
        });
  }

  Widget favoriteButton() {
    return FutureBuilder<WebViewController>(
        future: _controller.future,
        builder: (BuildContext context,
            AsyncSnapshot<WebViewController> controller) {
          if (controller.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                final String url = (await controller.data!.currentUrl())!;
                // ignore: deprecated_member_use
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Favorited $url')),
                );
              },
              child: const Icon(Icons.favorite),
            );
          }
          return Container();
        });
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}

class SampleMenu extends StatelessWidget {
  SampleMenu(this.controller);

  final Future<WebViewController> controller;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: controller,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        return PopupMenuButton<MenuOptions>(
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent(controller.data!, context);
                break;
              case MenuOptions.listCookies:
                _onListCookies(controller.data!, context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(controller.data!, context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(controller.data!, context);
                break;
              case MenuOptions.listCache:
                _onListCache(controller.data!, context);
                break;
              case MenuOptions.clearCache:
                _onClearCache(controller.data!, context);
                break;
              case MenuOptions.navigationDelegate:
                _onNavigationDelegateExample(controller.data!, context);
                break;
            }
          },
          itemBuilder: (BuildContext context) =>
          <PopupMenuItem<MenuOptions>>[
            PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: const Text('Show user agent'),
              enabled: controller.hasData,
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.navigationDelegate,
              child: Text('Navigation Delegate example'),
            ),
          ],
        );
      },
    );
  }

  void _onShowUserAgent(WebViewController controller,
      BuildContext context) async {
    // Send a message with the user agent string to the Toaster JavaScript channel we registered
    // with the WebView.
    await controller.evaluateJavascript(
        'Toaster.postMessage("User Agent: " + navigator.userAgent);');
  }

  void _onListCookies(WebViewController controller,
      BuildContext context) async {
    final String cookies =
    await controller.evaluateJavascript('document.cookie');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  void _onAddToCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript(
        'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";');
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  void _onListCache(WebViewController controller, BuildContext context) async {
    await controller.evaluateJavascript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  void _onClearCache(WebViewController controller, BuildContext context) async {
    await controller.clearCache();
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared."),
    ));
  }

  void _onClearCookies(WebViewController controller,
      BuildContext context) async {
    final bool hadCookies = await controller._widget.platform.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    // ignore: deprecated_member_use
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _onNavigationDelegateExample(WebViewController controller,
      BuildContext context) async {
    final String contentBase64 =
    base64Encode(const Utf8Encoder().convert(kNavigationExamplePage));
    await controller.loadUrl('data:text/html;base64,$contentBase64');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == null || cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
    cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data!;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoBack()) {
                  await controller.goBack();
                } else {
                  // ignore: deprecated_member_use
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(content: Text("No back history item")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                if (await controller.canGoForward()) {
                  await controller.goForward();
                } else {
                  // ignore: deprecated_member_use
                  Scaffold.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("No forward history item")),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                controller.reload();
              },
            ),
          ],
        );
      },
    );
  }
}

/// Controls a [WebView].
///
/// A [WebViewController] instance can be obtained by setting the [WebView.onWebViewCreated]
/// callback for a [WebView] widget.
class WebViewController {
  WebViewController._(this._widget,
      this._webViewPlatformController,
      this._platformCallbacksHandler,
      this._javascriptChannelRegistry,)
      : assert(_webViewPlatformController != null) {
    _settings = _webSettingsFromWidget(_widget);
  }

  final JavascriptChannelRegistry _javascriptChannelRegistry;

  final WebViewPlatformController _webViewPlatformController;

  final _PlatformCallbacksHandler _platformCallbacksHandler;

  late WebSettings _settings;

  WebViewExample _widget;

  /// Loads the specified URL.
  ///
  /// If `headers` is not null and the URL is an HTTP URL, the key value paris in `headers` will
  /// be added as key value pairs of HTTP headers for the request.
  ///
  /// `url` must not be null.
  ///
  /// Throws an ArgumentError if `url` is not a valid URL string.
  Future<void> loadUrl(String url, {
    Map<String, String>? headers,
  }) async {
    assert(url != null);
    _validateUrlString(url);
    return _webViewPlatformController.loadUrl(url, headers);
  }

  /// Accessor to the current URL that the WebView is displaying.
  ///
  /// If [WebView.initialUrl] was never specified, returns `null`.
  /// Note that this operation is asynchronous, and it is possible that the
  /// current URL changes again by the time this function returns (in other
  /// words, by the time this future completes, the WebView may be displaying a
  /// different URL).
  Future<String?> currentUrl() {
    return _webViewPlatformController.currentUrl();
  }

  /// Checks whether there's a back history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoBack" state has
  /// changed by the time the future completed.
  Future<bool> canGoBack() {
    return _webViewPlatformController.canGoBack();
  }

  /// Checks whether there's a forward history item.
  ///
  /// Note that this operation is asynchronous, and it is possible that the "canGoForward" state has
  /// changed by the time the future completed.
  Future<bool> canGoForward() {
    return _webViewPlatformController.canGoForward();
  }

  /// Goes back in the history of this WebView.
  ///
  /// If there is no back history item this is a no-op.
  Future<void> goBack() {
    return _webViewPlatformController.goBack();
  }

  /// Goes forward in the history of this WebView.
  ///
  /// If there is no forward history item this is a no-op.
  Future<void> goForward() {
    return _webViewPlatformController.goForward();
  }

  /// Reloads the current URL.
  Future<void> reload() {
    return _webViewPlatformController.reload();
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
    await _webViewPlatformController.clearCache();
    return reload();
  }

  Future<void> _updateWidget(WebViewExample widget) async {
    _widget = widget;
    await _updateSettings(_webSettingsFromWidget(widget));
    await _updateJavascriptChannels(_javascriptChannelRegistry.channels.values.toSet()); // TODO: CHECK WITH MAURITS IF POINTLESS. PROBABLY REMOVE THIS?
  }

  Future<void> _updateSettings(WebSettings newSettings) {
    final WebSettings update =
    _clearUnchangedWebSettings(_settings, newSettings);
    _settings = newSettings;
    return _webViewPlatformController.updateSettings(update);
  }

  Future<void> _updateJavascriptChannels(
      Set<JavascriptChannel>? newChannels) async {
    final Set<String> currentChannels =
    _javascriptChannelRegistry.channels.keys.toSet();
    final Set<String> newChannelNames = _extractChannelNames(newChannels);
    final Set<String> channelsToAdd =
    newChannelNames.difference(currentChannels);
    final Set<String> channelsToRemove =
    currentChannels.difference(newChannelNames);
    if (channelsToRemove.isNotEmpty) {
      await _webViewPlatformController
          .removeJavascriptChannels(channelsToRemove);
    }
    if (channelsToAdd.isNotEmpty) {
      await _webViewPlatformController.addJavascriptChannels(channelsToAdd);
    }
    _javascriptChannelRegistry.updateJavascriptChannelsFromSet(newChannels);
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
  ///
  /// When evaluating Javascript in a [WebView], it is best practice to wait for
  /// the [WebView.onPageFinished] callback. This guarantees all the Javascript
  /// embedded in the main frame HTML has been loaded.
  Future<String> evaluateJavascript(String javascriptString) {
    if (_settings.javascriptMode == JavascriptMode.disabled) {
      return Future<String>.error(FlutterError(
          'JavaScript mode must be enabled/unrestricted when calling evaluateJavascript.'));
    }
    // TODO(amirh): remove this on when the invokeMethod update makes it to stable Flutter.
    // https://github.com/flutter/flutter/issues/26431
    // ignore: strong_mode_implicit_dynamic_method
    return _webViewPlatformController.evaluateJavascript(javascriptString);
  }

  /// Returns the title of the currently loaded page.
  Future<String?> getTitle() {
    return _webViewPlatformController.getTitle();
  }

  /// Sets the WebView's content scroll position.
  ///
  /// The parameters `x` and `y` specify the scroll position in WebView pixels.
  Future<void> scrollTo(int x, int y) {
    return _webViewPlatformController.scrollTo(x, y);
  }

  /// Move the scrolled position of this view.
  ///
  /// The parameters `x` and `y` specify the amount of WebView pixels to scroll by horizontally and vertically respectively.
  Future<void> scrollBy(int x, int y) {
    return _webViewPlatformController.scrollBy(x, y);
  }

  /// Return the horizontal scroll position, in WebView pixels, of this view.
  ///
  /// Scroll position is measured from left.
  Future<int> getScrollX() {
    return _webViewPlatformController.getScrollX();
  }

  /// Return the vertical scroll position, in WebView pixels, of this view.
  ///
  /// Scroll position is measured from top.
  Future<int> getScrollY() {
    return _webViewPlatformController.getScrollY();
  }
}

WebSettings _webSettingsFromWidget(WebViewExample widget) {
  return WebSettings(
    javascriptMode: JavascriptMode.unrestricted,
    hasNavigationDelegate: false,
    hasProgressTracking: widget.onProgress != null,
    debuggingEnabled: false,
    gestureNavigationEnabled: false, // TODO: REMOVE COMMENT BEFORE MERGING, SET TO TRUE IN IOS EXAMPLE. POINTLESS FOR ANDROID.
    allowsInlineMediaPlayback: false,
    userAgent: WebSetting<String?>.of(null),
  );
}

class _PlatformCallbacksHandler implements WebViewPlatformCallbacksHandler {
  _PlatformCallbacksHandler(this._widget);

  WebViewExample _widget;

  @override
  FutureOr<bool> onNavigationRequest({
    required String url,
    required bool isForMainFrame,
  }) async {
    return true;
  }

  @override
  void onPageStarted(String url) {
    if (_widget.onPageStarted != null) {
      _widget.onPageStarted(url);
    }
  }

  @override
  void onPageFinished(String url) {
    if (_widget.onPageFinished != null) {
      _widget.onPageFinished(url);
    }
  }

  @override
  void onProgress(int progress) {
    if (_widget.onProgress != null) {
      _widget.onProgress(progress);
    }
  }

  void onWebResourceError(WebResourceError error) {
    if (_widget.onWebResourceError != null) {
      _widget.onWebResourceError(error);
    }
  }
}

/// Information about a navigation action that is about to be executed.
class NavigationRequest {
  NavigationRequest._({required this.url, required this.isForMainFrame});

  /// The URL that will be loaded if the navigation is executed.
  final String url;

  /// Whether the navigation request is to be loaded as the main frame.
  final bool isForMainFrame;

  @override
  String toString() {
    return '$runtimeType(url: $url, isForMainFrame: $isForMainFrame)';
  }
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

// This method assumes that no fields in `currentValue` are null.
WebSettings _clearUnchangedWebSettings(WebSettings currentValue,
    WebSettings newValue) {
  assert(currentValue.javascriptMode != null);
  assert(currentValue.hasNavigationDelegate != null);
  assert(currentValue.hasProgressTracking != null);
  assert(currentValue.debuggingEnabled != null);
  assert(currentValue.userAgent != null);
  assert(newValue.javascriptMode != null);
  assert(newValue.hasNavigationDelegate != null);
  assert(newValue.debuggingEnabled != null);
  assert(newValue.userAgent != null);

  JavascriptMode? javascriptMode;
  bool? hasNavigationDelegate;
  bool? hasProgressTracking;
  bool? debuggingEnabled;
  WebSetting<String?> userAgent = WebSetting.absent();
  if (currentValue.javascriptMode != newValue.javascriptMode) {
    javascriptMode = newValue.javascriptMode;
  }
  if (currentValue.hasNavigationDelegate != newValue.hasNavigationDelegate) {
    hasNavigationDelegate = newValue.hasNavigationDelegate;
  }
  if (currentValue.hasProgressTracking != newValue.hasProgressTracking) {
    hasProgressTracking = newValue.hasProgressTracking;
  }
  if (currentValue.debuggingEnabled != newValue.debuggingEnabled) {
    debuggingEnabled = newValue.debuggingEnabled;
  }
  if (currentValue.userAgent != newValue.userAgent) {
    userAgent = newValue.userAgent;
  }

  return WebSettings(
    javascriptMode: javascriptMode,
    hasNavigationDelegate: hasNavigationDelegate,
    hasProgressTracking: hasProgressTracking,
    debuggingEnabled: debuggingEnabled,
    userAgent: userAgent,
  );
}

Set<String> _extractChannelNames(Set<JavascriptChannel>? channels) {
  final Set<String> channelNames = channels == null
      ? <String>{}
      : channels.map((JavascriptChannel channel) => channel.name).toSet();
  return channelNames;
}

/// Callback type for handling messages sent from Javascript running in a web view.
typedef void JavascriptMessageHandler(JavascriptMessage message);

/// A decision on how to handle a navigation request.
enum NavigationDecision {
  /// Prevent the navigation from taking place.
  prevent,

  /// Allow the navigation to take place.
  navigate,
}

