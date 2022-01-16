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

### Depend on the package

This package is not an endorsed implementation of the `webview_flutter` plugin yet, so you'll need to
[add it explicitly](https://pub.dev/packages/webview_flutter_web/install).