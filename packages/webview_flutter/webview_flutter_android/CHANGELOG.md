## 2.8.9

* Updates Gradle to 7.2.1.

## 2.8.8

* Minor fixes for new analysis options.

## 2.8.7

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.8.6

* Updates pigeon developer dependency to the latest version which adds support for null safety.

## 2.8.5

* Migrates deprecated `Scaffold.showSnackBar` to `ScaffoldMessenger` in example app.

## 2.8.4

* Fixes bug preventing `mockito` code generation for tests.
* Fixes regression where local storage wasn't cleared when `WebViewController.clearCache` was
  called.

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
