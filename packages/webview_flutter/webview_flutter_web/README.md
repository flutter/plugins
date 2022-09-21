# webview\_flutter\_web

This is an implementation of the [`webview_flutter`](https://pub.dev/packages/webview_flutter) plugin for web.

It is currently severely limited and doesn't implement most of the available functionality.
The following functionality is currently available:

- `loadUrl` (Without headers)
- `requestUrl`
- `loadHTMLString` (Without `baseUrl`)
- Setting the `initialUrl` through `CreationParams`.

Nothing else is currently supported.

## Usage

This package is not an endorsed implementation of the `webview_flutter` plugin
yet, so it currently requires extra setup to use:

* [Add this package](https://pub.dev/packages/webview_flutter_web/install)
  as an explicit dependency of your project, in addition to depending on
  `webview_flutter`.
* Register `WebWebViewPlatform` as the `WebView.platform` before creating a
  `WebView`. See below for examples.

Once those steps below are complete, the APIs from `webview_flutter` listed
above can be used as normal on web.

### Registering the implementation

Before creating a `WebView` (for instance, at the start of `main`), you will
need to register the web implementation.

#### Web-only project example

```dart
...
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

main() {
  WebView.platform = WebWebViewPlatform();
  ...
```

#### Multi-platform project example

If your project supports platforms other than web, you will need to use a
conditional import to avoid directly including `webview_flutter_web.dart` on
non-web platforms. For example:

`register_web_webview.dart`:
```dart
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';

void registerWebViewWebImplementation() {
  WebView.platform = WebWebViewPlatform();
}
```

`register_web_webview_stub.dart`:
```dart
void registerWebViewWebImplementation() {
  // No-op.
}
```

`main.dart`:
```dart
...
import 'register_web_webview_stub.dart'
    if (dart.library.html) 'register_web.dart';

main() {
  registerWebViewWebImplementation();
  ...
```
