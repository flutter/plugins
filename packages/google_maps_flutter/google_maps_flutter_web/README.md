# google_maps_flutter_web

This is an implementation of the Google Maps Flutter plugin for web.

## Usage

### Depend on the package

This package is not an endorsed implementation of the google_maps_flutter plugin, so you'll need to modify the `pubspec.yaml` file of your app to depend on this package:

```yaml
dependencies:
  google_maps_flutter: ^0.5.28
  google_maps_flutter_web: ^0.1.0
```

### Modify web/index.html

Get an API Key for Google Maps JavaScript API. Get started [here](https://developers.google.com/maps/documentation/javascript/get-api-key).

Modify the `<head>` tag of your `web/index.html` to load the Google Maps JavaScript API, like so:

```html
<head>

  <!-- // Other stuff -->

  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
</head>
```

Now you should be able to use the Google Maps plugin normally.

## Limitations of the web version

The following map options are not available in web, because the map doesn't rotate there:

* `compassEnabled`
* `rotateGesturesEnabled`
* `tiltGesturesEnabled`

There's no "Map Toolbar" in web, so the `mapToolbarEnabled` option is unused.

There's no "My Location" widget in web (for now), so the following options are ignored:

* `myLocationButtonEnabled` ([doable](https://developers.google.com/maps/documentation/javascript/examples/control-custom))
* `myLocationEnabled` ([doable](https://api.dart.dev/stable/2.8.4/dart-html/Geolocation-class.html))

Traffic, indoor and building layers are still not available on the web.
