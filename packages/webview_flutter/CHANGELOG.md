## 0.3.7

* Fix loadUrlWithHeaders flaky test.

## 0.3.6+1

* Remove un-used method params in webview\_flutter

## 0.3.6

* Add an optional `headers` field to the controller.

## 0.3.5+5

* Fixed error in documentation of `javascriptChannels`.

## 0.3.5+4

* Fix bugs in the example app by updating it to use a `StatefulWidget`.

## 0.3.5+3

* Make sure to post javascript channel messages from the platform thread.

## 0.3.5+2

* Fix crash from `NavigationDelegate` on later versions of Android.

## 0.3.5+1

* Fix a bug where updates to onPageFinished were ignored.

## 0.3.5

* Added an onPageFinished callback.

## 0.3.4

* Support specifying navigation delegates that can prevent navigations from being executed.

## 0.3.3+2

* Exclude LongPress handler from semantics tree since it does nothing.

## 0.3.3+1

* Fixed a memory leak on Android - the WebView was not properly disposed.

## 0.3.3

* Add clearCache method to WebView controller.

## 0.3.2+1

* Log a more detailed warning at build time about the previous AndroidX
  migration.

## 0.3.2

* Added CookieManager to interface with WebView cookies. Currently has the ability to clear cookies.

## 0.3.1

* Added JavaScript channels to facilitate message passing from JavaScript code running inside
  the WebView to the Flutter app's Dart code.

## 0.3.0

* **Breaking change**. Migrate from the deprecated original Android Support
  Library to AndroidX. This shouldn't result in any functional changes, but it
  requires any Android apps using this plugin to [also
  migrate](https://developer.android.com/jetpack/androidx/migrate) if they're
  using the original support library.

## 0.2.0

* Added a evaluateJavascript method to WebView controller.
* (BREAKING CHANGE) Renamed the `JavaScriptMode` enum to `JavascriptMode`, and the WebView `javasScriptMode` parameter to `javascriptMode`.

## 0.1.2

* Added a reload method to the WebView controller.

## 0.1.1

* Added a `currentUrl` accessor for the WebView controller to look up what URL
  is being displayed.

## 0.1.0+1

* Fix null crash when initialUrl is unset on iOS.

## 0.1.0

* Add goBack, goForward, canGoBack, and canGoForward methods to the WebView controller.

## 0.0.1+1

* Fix case for "FLTWebViewFlutterPlugin" (iOS was failing to buld on case-sensitive file systems).

## 0.0.1

* Initial release.
