## 0.3.19+8

* Make the pedantic dev_dependency explicit.

## 0.3.19+7

* Remove the Flutter SDK constraint upper bound.

## 0.3.19+6

* Enable opening links that target the "_blank" window (links open in same window).

## 0.3.19+5

* On iOS, always keep contentInsets of the WebView to be 0.
* Fix XCTest case to follow XCTest naming convention.

## 0.3.19+4

* On iOS, fix the scroll view content inset is automatically adjusted. After the fix, the content position of the WebView is customizable by Flutter.
* Fix an iOS 13 bug where the scroll indicator shows at random location.

## 0.3.19+3

* Setup XCTests.

## 0.3.19+2

* Migrate from deprecated BinaryMessages to ServicesBinding.instance.defaultBinaryMessenger.

## 0.3.19+1

* Raise min Flutter SDK requirement to the latest stable. v2 embedding apps no
  longer need to special case their Flutter SDK requirement like they have
  since v0.3.15+3.

## 0.3.19

* Add setting for iOS to allow gesture based navigation.

## 0.3.18+1

* Be explicit that keyboard is not ready for production in README.md.

## 0.3.18

* Add support for onPageStarted event.
* Remove the deprecated `author:` field from pubspec.yaml
* Migrate to the new pubspec platforms manifest.
* Require Flutter SDK 1.10.0 or greater.

## 0.3.17

* Fix pedantic lint errors. Added missing documentation and awaited some futures
  in tests and the example app.

## 0.3.16

* Add support for async NavigationDelegates. Synchronous NavigationDelegates
  should still continue to function without any change in behavior.

## 0.3.15+3

* Re-land support for the v2 Android embedding. This correctly sets the minimum
  SDK to the latest stable and avoid any compile errors. *WARNING:* the V2
  embedding itself still requires the current Flutter master channel
  (flutter/flutter@1d4d63a) for text input to work properly on all Android
  versions.

## 0.3.15+2

* Remove AndroidX warnings.

## 0.3.15+1

* Revert the prior embedding support add since it requires an API that hasn't
  rolled to stable.

## 0.3.15

* Add support for the v2 Android embedding. This shouldn't affect existing
  functionality. Plugin authors who use the V2 embedding can now register the
  plugin and expect that it correctly responds to app lifecycle changes.

## 0.3.14+2

* Define clang module for iOS.

## 0.3.14+1

* Allow underscores anywhere for Javascript Channel name.

## 0.3.14

* Added a getTitle getter to WebViewController.

## 0.3.13

* Add an optional `userAgent` property to set a custom User Agent.

## 0.3.12+1

* Temporarily revert getTitle (doing this as a patch bump shortly after publishing).

## 0.3.12

* Added a getTitle getter to WebViewController.

## 0.3.11+6

* Calling destroy on Android webview when flutter webview is getting disposed.

## 0.3.11+5

* Reduce compiler warnings regarding iOS9 compatibility by moving a single
  method back into a `@available` block.

## 0.3.11+4

* Removed noisy log messages on iOS.

## 0.3.11+3

* Apply the display listeners workaround that was shipped in 0.3.11+1 on
  all Android versions prior to P.

## 0.3.11+2

* Add fix for input connection being dropped after a screen resize on certain
  Android devices.

## 0.3.11+1

* Work around a bug in old Android WebView versions that was causing a crash
  when resizing the webview on old devices.

## 0.3.11

* Add an initialAutoMediaPlaybackPolicy setting for controlling how auto media
  playback is restricted.

## 0.3.10+5

* Add dependency on `androidx.annotation:annotation:1.0.0`.

## 0.3.10+4

* Add keyboard text to README.

## 0.3.10+3

* Don't log an unknown setting key error for 'debuggingEnabled' on iOS.

## 0.3.10+2

* Fix InputConnection being lost when combined with route transitions.

## 0.3.10+1

* Add support for simultaenous Flutter `TextInput` and WebView text fields.

## 0.3.10

* Add partial WebView keyboard support for Android versions prior to N. Support
  for UIs that also have Flutter `TextInput` fields is still pending. This basic
  support currently only works with Flutter `master`. The keyboard will still
  appear when it previously did not when run with older versions of Flutter. But
  if the WebView is resized while showing the keyboard the text field will need
  to be focused multiple times for any input to be registered.

## 0.3.9+2

* Update Dart code to conform to current Dart formatter.

## 0.3.9+1

* Add missing template type parameter to `invokeMethod` calls.
* Bump minimum Flutter version to 1.5.0.
* Replace invokeMethod with invokeMapMethod wherever necessary.

## 0.3.9

* Allow external packages to provide webview implementations for new platforms.

## 0.3.8+1

* Suppress deprecation warning for BinaryMessages. See: https://github.com/flutter/flutter/issues/33446

## 0.3.8

* Add `debuggingEnabled` property.

## 0.3.7+1

* Fix an issue where JavaScriptChannel messages weren't sent from the platform thread on Android.

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
