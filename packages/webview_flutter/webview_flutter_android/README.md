# webview\_flutter\_android

The Android implementation of [`webview_flutter`][1].

## Usage

This package is [endorsed][2], which means you can simply use `webview_flutter`
normally. This package will be automatically included in your app when you do.

## Display Mode

This plugin supports two different platform view display modes. The default display mode is subject
to change in the future, and will not be considered a breaking change, so if you want to ensure a
specific mode, you can set it explicitly.

### Texture Layer Hybrid Composition

This is the current default mode for versions >=23. This is a new display mode used by most
plugins starting with Flutter 3.0. This is more performant than Hybrid Composition, but has some
limitations from using an Android [SurfaceTexture](https://developer.android.com/reference/android/graphics/SurfaceTexture).
See:
* https://github.com/flutter/flutter/issues/104889
* https://github.com/flutter/flutter/issues/116954

### Hybrid Composition

This is the current default mode for versions <23. It ensures that the WebView will display and work
as expected, at the cost of some performance. See:
* https://flutter.dev/docs/development/platform-integration/platform-views#performance

This can be configured for versions >=23 with
`AndroidWebViewWidgetCreationParams.displayWithHybridComposition`. See https://pub.dev/packages/webview_flutter#platform-specific-features
for more details on setting platform-specific features in the main plugin.

## Contributing

This package uses [pigeon][3] to generate the communication layer between Flutter and the host
platform (Android). The communication interface is defined in the `pigeons/android_webview.dart`
file. After editing the communication interface regenerate the communication layer by running
`flutter pub run pigeon --input pigeons/android_webview.dart`.

Besides [pigeon][3] this package also uses [mockito][4] to generate mock objects for testing
purposes. To generate the mock objects run the following command:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

If you would like to contribute to the plugin, check out our [contribution guide][5].

[1]: https://pub.dev/packages/webview_flutter
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://pub.dev/packages/pigeon
[4]: https://pub.dev/packages/mockito
[5]: https://github.com/flutter/plugins/blob/main/CONTRIBUTING.md

