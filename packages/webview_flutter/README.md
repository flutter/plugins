# WebView for Flutter

[![pub package](https://img.shields.io/pub/v/webview_flutter.svg)](https://pub.dartlang.org/packages/webview_flutter)

A Flutter plugin that provides a WebView widget.

On iOS the WebView widget is backed by a [WKWebView](https://developer.apple.com/documentation/webkit/wkwebview);
On Android the WebView widget is backed by a [WebView](https://developer.android.com/reference/android/webkit/WebView).

**The WebView plugin has reached [1.0.0](/link-to-release-notes), and it's now *ready* for production.**

## Usage
Add `webview_flutter` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

See the [WebView](https://pub.dev/documentation/webview_flutter/latest/webview_flutter/WebView-class.html)
widget's Dartdoc for more details on how to use the widget.

### Android

There are two implementations of the underlying primitive called [Platform Views](https://flutter.dev/docs/development/platform-integration/platform-views).

Prior to 1.0.0, WebView only used an Android [VirtualDisplay](https://github.com/flutter/flutter/wiki/Android-Platform-Views#the-approach).
While this implementation provides the best average rendering performance, it introduced [keyboard and accesibility issues](https://github.com/flutter/flutter/wiki/Android-Platform-Views#associated-problems-and-workarounds)
that were hard to fix. In 1.0.0, the WebView also uses [Hybrid composition](https://github.com/flutter/flutter/wiki/Hybrid-Composition#android),
which enables the WebView to be embedded in the Android view hierarchy.

To enable hybrid composition, set `WebView.platform = SurfaceAndroidWebView();` in `initState()`. For example:

```dart
import 'dart:io';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewExample extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: 'https://flutter.dev',
    );
  }
}
```

Prior to Android 10, Hybrid composition performs a device-host-device copy of the Flutter texture. In general, reducing Flutter animations while the WebView is rendered helps improve performance. However, we recommend testing your app with the devices and Android versions typically used by your users.

`SurfaceAndroidWebView()` requires [API level 19](https://developer.android.com/studio/releases/platforms?hl=th#4.4). The plugin itself doesn't enforce the API level, so if you want to make the app available on devices running this API level or above, add the following to `<your-app>/android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        // Required by the Flutter WebView plugin.
        minSdkVersion 19
    }
  }
```
