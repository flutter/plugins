# google\_maps\_flutter\_android

<?code-excerpt path-base="excerpts/packages/google_maps_flutter_example"?>

The Android implementation of [`google_maps_flutter`][1].

## Usage

This package is [endorsed][2], which means you can simply use
`google_maps_flutter` normally. This package will be automatically included in
your app when you do.

## Display Mode

This plugin supports two different [platform view display modes][3]. The default
display mode is subject to change in the future, and will not be considered a
breaking change, so if you want to ensure a specific mode you can set it
explicitly:

<?code-excerpt "readme_excerpts.dart (DisplayMode)"?>
```dart
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  // Require Hybrid Composition mode on Android.
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  // ···
}
```

### Hybrid Composition

This is the current default mode, and corresponds to
`useAndroidViewSurface = true`. It ensures that the map display will work as
expected, at the cost of some performance.

### Texture Layer Hybrid Composition

This is a new display mode used by most plugins starting with Flutter 3.0, and
corresponds to `useAndroidViewSurface = false`. This is more performant than
Hybrid Composition, but currently [misses certain map updates][4].

This mode will likely become the default in future versions if/when the
missed updates issue can be resolved.

## Map renderer

This plugin supports the option to request a specific [map renderer][5].

The renderer must be requested before creating GoogleMap instances, as the renderer can be initialized only once per application context.

<?code-excerpt "readme_excerpts.dart (MapRenderer)"?>
```dart
AndroidMapRenderer mapRenderer = AndroidMapRenderer.platformDefault;
// ···
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    mapRenderer = await mapsImplementation
        .initializeWithRenderer(AndroidMapRenderer.latest);
  }
```

Available values are `AndroidMapRenderer.latest`, `AndroidMapRenderer.legacy`, `AndroidMapRenderer.platformDefault`.
Note that getting the requested renderer as a response is not guaranteed.

[1]: https://pub.dev/packages/google_maps_flutter
[2]: https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin
[3]: https://docs.flutter.dev/development/platform-integration/android/platform-views
[4]: https://github.com/flutter/flutter/issues/103686
[5]: https://developers.google.com/maps/documentation/android-sdk/renderer
