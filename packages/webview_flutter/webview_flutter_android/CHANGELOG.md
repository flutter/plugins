## 2.8.3

* Fixes a bug causing `debuggingEnabled` to always be set to true.
* Fixes an integration test race condition.

## 2.8.2

* Adds the `WebSettings.setAllowFileAccess()` method and ensure that file access is allowed when the `WebViewAndroidWidget.loadFile()` method is executed.

## 2.8.1

* Fixes bug where the default user agent string was being set for every rebuild. See
  https://github.com/flutter/flutter/issues/94847.

## 2.8.0

* Implements new cookie manager for setting cookies and providing initial cookies.

## 2.7.0

* Adds support for the `loadRequest` method from the platform interface.

## 2.6.0

* Adds implementation of the `loadFlutterAsset` method from the platform interface.

## 2.5.0

* Adds an option to set the background color of the webview.

## 2.4.0

* Adds support for Android's `WebView.loadData` and `WebView.loadDataWithBaseUrl` methods and implements the `loadFile` and `loadHtmlString` methods from the platform interface.
* Updates to webview_flutter_platform_interface version 1.5.2.

## 2.3.1

* Adds explanation on how to generate the pigeon communication layer and mockito mock objects.
* Updates compileSdkVersion to 31.

## 2.3.0

* Replaces platform implementation with API built with pigeon.

## 2.2.1

* Fix `NullPointerException` from a race condition when changing focus. This only affects `WebView`
when it is created without Hybrid Composition.

## 2.2.0

* Implemented new `runJavascript` and `runJavascriptReturningResult` methods in platform interface.

## 2.1.0

* Add `zoomEnabled` functionality.

## 2.0.15

* Added Overrides in  FlutterWebView.java

## 2.0.14

* Update example App so navigation menu loads immediatly but only becomes available when `WebViewController` is available (same behavior as example App in webview_flutter package).

## 2.0.13

* Extract Android implementation from `webview_flutter`.
