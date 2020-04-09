# experimental_connectivity_web

A web implementation of [connectivity](https://pub.dev/connectivity/connectivity). Currently this package uses an experimental API, so not all browsers that Flutter web supports are supported.

## Usage

### Import the package

This package is a non-endorsed implementation of `connectivity` for the web platform, so you need to modify your `pubspec.yaml` to use it:

```yaml
...
dependencies:
  ...
  connectivity: ^0.4.9
  experimental_connectivity_web: ^0.1.0
  ...
...
```

## Example

Find the example wiring in the [Google sign-in example application](https://github.com/flutter/plugins/blob/master/packages/connectivity/connectivity/example/lib/main.dart).

## Limitations on the web platform

The web implementation of the `connectivity` plugin uses the Browser's [**NetworkInformation** Web API](https://developer.mozilla.org/en-US/docs/Web/API/NetworkInformation), which as of this writing (February 2020) is still "experimental".

![Data on support for the netinfo feature across the major browsers from caniuse.com](https://caniuse.bitsofco.de/image/netinfo.png)

On desktop browsers, the API only returns a very broad set of connectivity statuses (One of `'slow-2g', '2g', '3g', or '4g'`), and may *not* provide an Stream of changes. Firefox still hasn't enabled this feature by default.

Other than the approximate "downlink" speed, and due to security and privacy concerns, this Web API will not provide any specific information about the actual network your users' device is connected to, like the SSID on a Wi-Fi, or the MAC address of their device, in any web platform (mobile or desktop).

### `null` connectivity results

Because of the limitations above, unsupported browsers will return `null` connectivity results, both on the `checkConnectivity` call, and the `onConnectivityChanged` stream. You should adapt your app code to check for nulls being returned from calls to the plugin.

## Contributions and Testing

Tests are a crucial to contributions to this package. All new contributions should be reasonably tested.

In order to run tests in this package, do:

```
cd test
flutter run -d chrome
```

Contributions to this package are welcome. Read the [Contributing to Flutter Plugins](https://github.com/flutter/plugins/blob/master/CONTRIBUTING.md) guide to get started.

## Issues and feedback

Please file an [issue](https://github.com/ditman/plugins/issues/new)
to send feedback or report a bug.

**Thank you!**
