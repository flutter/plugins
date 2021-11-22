## NEXT

* Updates example app Android compileSdkVersion to 31.

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

