// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'shims/dart_ui.dart' as ui;

/// Builds an iframe based WebView.
///
/// This is used as the default implementation for [WebView.platform] on web.
class WebWebViewPlatform implements WebViewPlatform {
  /// Constructs a new instance of [WebWebViewPlatform].
  WebWebViewPlatform() {
    ui.platformViewRegistry.registerViewFactory(
        'webview-iframe',
        (int viewId) => IFrameElement()
          ..id = 'webview-$viewId'
          ..width = '100%'
          ..height = '100%'
          ..style.border = 'none');
  }

  @override
  Widget build({
    required BuildContext context,
    required CreationParams creationParams,
    required WebViewPlatformCallbacksHandler webViewPlatformCallbacksHandler,
    required JavascriptChannelRegistry? javascriptChannelRegistry,
    WebViewPlatformCreatedCallback? onWebViewPlatformCreated,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return HtmlElementView(
      viewType: 'webview-iframe',
      onPlatformViewCreated: (int viewId) {
        if (onWebViewPlatformCreated == null) {
          return;
        }
        final IFrameElement element =
            document.getElementById('webview-$viewId')! as IFrameElement;
        if (creationParams.initialUrl != null) {
          // ignore: unsafe_html
          element.src = creationParams.initialUrl;
        }
        onWebViewPlatformCreated(WebWebViewPlatformController(
          element,
        ));
      },
    );
  }

  @override
  Future<bool> clearCookies() async => false;

  /// Gets called when the plugin is registered.
  static void registerWith(Registrar registrar) {}
}

/// Implementation of [WebViewPlatformController] for web.
class WebWebViewPlatformController implements WebViewPlatformController {
  /// Constructs a [WebWebViewPlatformController].
  WebWebViewPlatformController(this._element);

  final IFrameElement _element;
  HttpRequestFactory _httpRequestFactory = HttpRequestFactory();

  /// Setter for setting the HttpRequestFactory, for testing purposes.
  @visibleForTesting
  // ignore: avoid_setters_without_getters
  set httpRequestFactory(HttpRequestFactory factory) {
    _httpRequestFactory = factory;
  }

  @override
  Future<void> addJavascriptChannels(Set<String> javascriptChannelNames) {
    throw UnimplementedError();
  }

  @override
  Future<bool> canGoBack() {
    throw UnimplementedError();
  }

  @override
  Future<bool> canGoForward() {
    throw UnimplementedError();
  }

  @override
  Future<void> clearCache() {
    throw UnimplementedError();
  }

  @override
  Future<String?> currentUrl() {
    throw UnimplementedError();
  }

  @override
  Future<String> evaluateJavascript(String javascript) {
    throw UnimplementedError();
  }

  @override
  Future<int> getScrollX() {
    throw UnimplementedError();
  }

  @override
  Future<int> getScrollY() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getTitle() {
    throw UnimplementedError();
  }

  @override
  Future<void> goBack() {
    throw UnimplementedError();
  }

  @override
  Future<void> goForward() {
    throw UnimplementedError();
  }

  @override
  Future<void> loadUrl(String url, Map<String, String>? headers) async {
    // ignore: unsafe_html
    _element.src = url;
  }

  @override
  Future<void> reload() {
    throw UnimplementedError();
  }

  @override
  Future<void> removeJavascriptChannels(Set<String> javascriptChannelNames) {
    throw UnimplementedError();
  }

  @override
  Future<void> runJavascript(String javascript) {
    throw UnimplementedError();
  }

  @override
  Future<String> runJavascriptReturningResult(String javascript) {
    throw UnimplementedError();
  }

  @override
  Future<void> scrollBy(int x, int y) {
    throw UnimplementedError();
  }

  @override
  Future<void> scrollTo(int x, int y) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateSettings(WebSettings setting) {
    throw UnimplementedError();
  }

  @override
  Future<void> loadFile(String absoluteFilePath) {
    throw UnimplementedError();
  }

  @override
  Future<void> loadHtmlString(
    String html, {
    String? baseUrl,
  }) async {
    // ignore: unsafe_html
    _element.src = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: utf8,
    ).toString();
  }

  @override
  Future<void> loadRequest(WebViewRequest request) async {
    if (!request.uri.hasScheme) {
      throw ArgumentError('WebViewRequest#uri is required to have a scheme.');
    }
    final HttpRequest httpReq = await _httpRequestFactory.request(
        request.uri.toString(),
        method: request.method.serialize(),
        requestHeaders: request.headers,
        sendData: request.body);
    final String contentType =
        httpReq.getResponseHeader('content-type') ?? 'text/html';
    // ignore: unsafe_html
    _element.src = Uri.dataFromString(
      httpReq.responseText ?? '',
      mimeType: contentType,
      encoding: utf8,
    ).toString();
  }

  @override
  Future<void> loadFlutterAsset(String key) {
    throw UnimplementedError();
  }
}

/// Factory class for creating [HttpRequest] instances.
class HttpRequestFactory {
  /// Creates and sends a URL request for the specified [url].
  ///
  /// By default `request` will perform an HTTP GET request, but a different
  /// method (`POST`, `PUT`, `DELETE`, etc) can be used by specifying the
  /// [method] parameter. (See also [HttpRequest.postFormData] for `POST`
  /// requests only.
  ///
  /// The Future is completed when the response is available.
  ///
  /// If specified, `sendData` will send data in the form of a [ByteBuffer],
  /// [Blob], [Document], [String], or [FormData] along with the HttpRequest.
  ///
  /// If specified, [responseType] sets the desired response format for the
  /// request. By default it is [String], but can also be 'arraybuffer', 'blob',
  /// 'document', 'json', or 'text'. See also [HttpRequest.responseType]
  /// for more information.
  ///
  /// The [withCredentials] parameter specified that credentials such as a cookie
  /// (already) set in the header or
  /// [authorization headers](http://tools.ietf.org/html/rfc1945#section-10.2)
  /// should be specified for the request. Details to keep in mind when using
  /// credentials:
  ///
  /// /// Using credentials is only useful for cross-origin requests.
  /// /// The `Access-Control-Allow-Origin` header of `url` cannot contain a wildcard (///).
  /// /// The `Access-Control-Allow-Credentials` header of `url` must be set to true.
  /// /// If `Access-Control-Expose-Headers` has not been set to true, only a subset of all the response headers will be returned when calling [getAllResponseHeaders].
  ///
  /// The following is equivalent to the [getString] sample above:
  ///
  ///     var name = Uri.encodeQueryComponent('John');
  ///     var id = Uri.encodeQueryComponent('42');
  ///     HttpRequest.request('users.json?name=$name&id=$id')
  ///       .then((HttpRequest resp) {
  ///         // Do something with the response.
  ///     });
  ///
  /// Here's an example of submitting an entire form with [FormData].
  ///
  ///     var myForm = querySelector('form#myForm');
  ///     var data = new FormData(myForm);
  ///     HttpRequest.request('/submit', method: 'POST', sendData: data)
  ///       .then((HttpRequest resp) {
  ///         // Do something with the response.
  ///     });
  ///
  /// Note that requests for file:// URIs are only supported by Chrome extensions
  /// with appropriate permissions in their manifest. Requests to file:// URIs
  /// will also never fail- the Future will always complete successfully, even
  /// when the file cannot be found.
  ///
  /// See also: [authorization headers](http://en.wikipedia.org/wiki/Basic_access_authentication).
  Future<HttpRequest> request(String url,
      {String? method,
      bool? withCredentials,
      String? responseType,
      String? mimeType,
      Map<String, String>? requestHeaders,
      dynamic sendData,
      void Function(ProgressEvent e)? onProgress}) {
    return HttpRequest.request(url,
        method: method,
        withCredentials: withCredentials,
        responseType: responseType,
        mimeType: mimeType,
        requestHeaders: requestHeaders,
        sendData: sendData,
        onProgress: onProgress);
  }
}
