# Google Maps for Flutter

[![pub package](https://img.shields.io/pub/v/google_maps_flutter.svg)](https://pub.dartlang.org/packages/google_maps_flutter)

A Flutter plugin to use [Google Maps](https://developers.google.com/maps/) in
iOS and Android apps.

## Caveat

This plugin provides an *unpublished preview* of the Flutter API for GoogleMaps:
* Dart APIs for controlling and interacting with a GoogleMap view from Flutter
  code are still being consolidated and expanded. The intention is to grow
  current coverage into a complete offering. Issues and pull requests aimed to
  help us prioritize and speed up this effort are very welcome.
* The technique currently used for compositing GoogleMap views with Flutter
  widgets is *inherently limited* and will be replaced by a fully compositional
  [Texture](https://docs.flutter.io/flutter/widgets/Texture-class.html)-based
  approach before we publish this plugin.
  
  In detail: the plugin currently relies on placing platform overlays on top of
  a bitmap snapshotting widget for creating the illusion of in-line compositing
  of GoogleMap views with Flutter widgets. This works only in very limited
  situations where
  * the widget is stationary
  * the widget is drawn on top of all other widgets within bounds
  * touch events within widget bounds can be safely ignored by Flutter
 
  The root problem with platform overlays is that they cannot be freely composed
  with other widgets. Many workarounds can be devised to address this shortcoming
  in particular situations, but the Flutter team does not intend to support such
  work, as it would not move us forward towards our goal of a fully compositional
  GoogleMaps widget.

## Usage

To use this plugin, add
```yaml
 google_maps_flutter:
   git:
     url: git://github.com/flutter/plugins
     path: packages/google_maps_flutter
```
as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

## Getting Started

See the `example` directory for a complete sample app using Google Maps.
