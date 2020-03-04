# connectivity_web

The web implementation of [connectivity](https://pub.dev/connectivity/connectivity)

## Usage

### Import the package

This package is the endorsed implementation of `connectivity` for the web platform since version `0.4.9`, so it gets automatically added to your dependencies by depending on `connectivity: ^0.4.9`.

No modifications to your pubspec.yaml should be required in a recent enough version of Flutter (`>=1.12.13+hotfix.4`):

```yaml
...
dependencies:
  ...
  connectivity: ^0.4.9
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

Because of the limitations above, unsupported browsers will return `null` connectivity results, both on the `checkConnectivity` call, and the `onConnectivityChanged` stream.

## Contributions and Testing

Tests are a crucial to contributions to this package. All new contributions should be reasonably tested.

In order to run tests in this package, do:

```
cd test
flutter run -d chrome
```

Contributions to this package are welcome. Read the [Contributing to Flutter Plugins](https://github.com/flutter/plugins/blob/master/CONTRIBUTING.md) guide to get started.

## Issues and feedback

Please file [issues](https://github.com/flutter/flutter/issues/new)
to send feedback or report a bug.

**Thank you!**
