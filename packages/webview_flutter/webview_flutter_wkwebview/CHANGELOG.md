## 2.8.0

* Raises minimum Dart version to 2.17 and Flutter version to 3.0.0.

## 2.7.5

* Minor fixes for new analysis options.

## 2.7.4

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 2.7.3

* Removes two occurrences of the compiler warning: "'RequiresUserActionForMediaPlayback' is deprecated: first deprecated in ios 10.0".

## 2.7.2

* Fixes an integration test race condition.
* Migrates deprecated `Scaffold.showSnackBar` to `ScaffoldMessenger` in example app.

## 2.7.1

* Fixes header import for cookie manager to be relative only.

## 2.7.0

* Adds implementation of the `loadFlutterAsset` method from the platform interface.

## 2.6.0

* Implements new cookie manager for setting cookies and providing initial cookies.

## 2.5.0

* Adds an option to set the background color of the webview.
* Migrates from `analysis_options_legacy.yaml` to `analysis_options.yaml`.
* Integration test fixes.
* Updates to webview_flutter_platform_interface version 1.5.2.

## 2.4.0

* Implemented new `loadFile` and `loadHtmlString` methods from the platform interface.

## 2.3.0

* Implemented new `loadRequest` method from platform interface.

## 2.2.0

* Implemented new `runJavascript` and `runJavascriptReturningResult` methods in platform interface.

## 2.1.0

* Add `zoomEnabled` functionality.

## 2.0.14

* Update example App so navigation menu loads immediatly but only becomes available when `WebViewController` is available (same behavior as example App in webview_flutter package).

## 2.0.13

* Extract WKWebView implementation from `webview_flutter`.
