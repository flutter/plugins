# WebView for Flutter

<?code-excerpt path-base="excerpts/packages/webview_flutter_example"?>

[![pub package](https://img.shields.io/pub/v/webview_flutter.svg)](https://pub.dev/packages/webview_flutter)

A Flutter plugin that provides a WebView widget.

On iOS the WebView widget is backed by a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview).
On Android the WebView widget is backed by a [WebView](https://developer.android.com/reference/android/webkit/WebView).

|             | Android        | iOS  |
|-------------|----------------|------|
| **Support** | SDK 19+ or 20+ | 9.0+ |

## Usage
Add `webview_flutter` as a [dependency in your pubspec.yaml file](https://pub.dev/packages/webview_flutter/install).

You can now display a WebView by:

1. Instantiating a [WebViewController](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController-class.html).

<?code-excerpt "simple_example.dart (webview_controller)"?>
```dart
import 'package:webview_flutter/webview_flutter.dart';

final WebViewController controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(const Color(0x00000000))
  ..setNavigationDelegate(
    NavigationDelegate(
      onProgress: (int progress) {
        print('WebView is loading (progress : $progress%)');
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
      onWebResourceError: (WebResourceError error) {
        print('''
          Page resource error:
            code: ${error.errorCode}
            description: ${error.description}
            errorType: ${error.errorType}
            isForMainFrame: ${error.isForMainFrame}
          ''');
      },
      onNavigationRequest: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          print('blocking navigation to $request');
          return NavigationDecision.prevent;
        }
        print('allowing navigation to $request');
        return NavigationDecision.navigate;
      },
    ),
  )
  ..addJavaScriptChannel(
    'MyChannel',
    onMessageReceived: (JavaScriptMessage message) {
      print('message from MyChannel: ${message.message}');
    },
  )
  ..loadRequest(Uri.parse('https://flutter.dev'));
```

2. Passing the controller to a [WebViewWidget](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewWidget-class.html).

<?code-excerpt "simple_example.dart (webview_widget)"?>
```dart
import 'package:webview_flutter/webview_flutter.dart';

final Widget webViewWidget = WebViewWidget(controller: controller);
```

See the Dartdocs for [WebViewController](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController-class.html)
and [WebViewWidget](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewWidget-class.html)
for more details.

### Android Platform Views

This plugin uses
[Platform Views](https://flutter.dev/docs/development/platform-integration/platform-views) to embed
the Android’s WebView within the Flutter app.

You should however make sure to set the correct `minSdkVersion` in `android/app/build.gradle` if it was previously lower than 19:

```groovy
android {
    defaultConfig {
        minSdkVersion 19
    }
}
```

### Platform Specific Features

Many classes have a subclass or an underlying implementation that provides access to platform
specific features.

To access platform specific features, start by including the import for the desired platform:

<?code-excerpt "main.dart (platform_imports)"?>
```dart
// Import for Android features.
import 'package:webview_flutter/android.dart';
// Import for iOS features.
import 'package:webview_flutter/wkwebview.dart';
```

Then additional features can be accessed through the platform implementations provided by the
imports above:

<?code-excerpt "main.dart (platform_features)"?>
```dart
final WebViewController controller = WebViewController.fromPlatformCreationParams(
  WebKitWebViewControllerCreationParams(
    allowsInlineMediaPlayback: true,
  ),
);

if (controller is WebKitWebViewController) {
  controller.setAllowsBackForwardNavigationGestures(true);
} else if (controller is AndroidWebViewController) {
  AndroidWebViewController.enableDebugging(true);
}
```

See https://pub.dev/documentation/webview_flutter/latest/android/android-library.html
for more details on Android features.

See https://pub.dev/documentation/webview_flutter/latest/wkwebview/wkwebview-library.html
for more details on iOS features.

## Migrating from 3.0 to 4.0

### Instantiating WebViewController

In version 3.0 and below, `WebViewController` could only be retrieved in a callback after the
`WebView` was  added to the widget tree. Now, `WebViewController` must be instantiated and can be
used before it is added to the widget tree. See `Usage` section above for an example.

### Replacing WebView Functionality

The `WebView` class has been removed and it's functionality has been split into `WebViewController`
and `WebViewWidget`.

`WebViewController` handles all functionality that is associated with the underlying WebView
provided by each platform. (e.g. loading a url, setting the background color of the underlying
platform view, or clearing the cache).

`WebViewWidget` takes a `WebViewController` and handles all Flutter widget related functionality
(e.g. layout direction, gesture recognizers).

See the Dartdocs for [WebViewController](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewController-class.html)
and [WebViewWidget](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebViewWidget-class.html)
for more details.

### PlatformView Implementation on Android

The PlatformView implementation for Android is currently no longer configurable. It uses Texture
Layer Hybrid Composition on versions 23+ and automatically fallbacks to Hybrid Composition for
version 19-23. See https://github.com/flutter/flutter/issues/108106 for progress on manually
switching to Hybrid Composition on versions 23+.

### API Changes

Below is a non-exhaustive list of changes to the API:

* `WebViewController.clearCache` no longer clears local storage. Please use
  `WebViewController.clearLocalStorage`.
* `WebViewController.clearCache` no longer reloads the page.
* `WebViewController.loadUrl` has been removed. Please use `WebViewController.loadRequest`.
* `WebViewController.evaluateJavascript` has been removed. Please use
  `WebViewController.runJavaScript` or `WebViewController.runJavaScriptReturningResult`.
* `WebViewController.getScrollX` and `WebViewController.getScrollY` have been removed and have
* been replaced by `WebViewController.getScrollPosition`.
* The following fields from `WebView` have been moved to `NavigationDelegate`:
  * `WebView.navigationDelegate` -> `NavigationDelegate.onNavigationRequest`
  * `WebView.onPageStarted` -> `NavigationDelegate.onPageStarted`
  * `WebView.onPageFinished` -> `NavigationDelegate.onPageFinished`
  * `WebView.onProgress` -> `NavigationDelegate.onProgress`
  * `WebView.onWebResourceError` -> `NavigationDelegate.onWebResourceError`
* The following fields from `WebView` have been moved to `WebViewController`:
  * `WebView.javascriptMode` -> `WebViewController.setJavaScriptMode`
  * `WebView.javascriptChannels` ->
    `WebViewController.addJavaScriptChannel`/`WebViewController.removeJavaScriptChannel`
  * `WebView.zoomEnabled` -> `WebViewController.enableZoom`
  * `WebView.userAgent` -> `WebViewController.setUserAgent`
  * `WebView.backgroundColor` -> `WebViewController.setBackgroundColor`
* The following features have been moved to an Android implementation class. See
  `aoijfea` section to use platform specific features.
* The following features have been moved to an Android implementation class. See
  `aoijfea` section to use platform specific features.
  
## Enable Material Components for Android

To use Material Components when the user interacts with input elements in the WebView,
follow the steps described in the [Enabling Material Components instructions](https://flutter.dev/docs/deployment/android#enabling-material-components).

## Setting custom headers on POST requests

Currently, setting custom headers when making a post request with the WebViewController's `loadRequest` method is not supported on Android.
If you require this functionality, a workaround is to make the request manually, and then load the response data using `loadHTMLString` instead.
