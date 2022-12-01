# google_maps_places_platform_interface

A common platform interface for the google_maps_places plugin.

This interface allows platform-specific implementations of the `google_maps_places`
plugin, as well as the plugin itself, to ensure they are supporting the
same interface.

# Usage

To implement a new platform-specific implementation of `google_maps_places`, extend
[`GoogleMapsPlacesPlatform`][2] with an implementation that performs the
platform-specific behavior, and when you register your plugin, set the default
`GoogleMapsPlacesPlatform` by calling
`GoogleMapsPlacesPlatform.instance = MyGoogleMapsPlacesPlatform()`.

# Note on breaking changes

Strongly prefer non-breaking changes (such as adding a method to the interface)
over breaking changes for this package.

See https://flutter.dev/go/platform-interface-breaking-changes for a discussion
on why a less-clean interface is preferable to a breaking change.

[1]: ../google_maps_places
[2]: lib/google_maps_places_platform_interface.dart
