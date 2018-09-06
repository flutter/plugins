// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter;

typedef void MapCreatedCallback(GoogleMapController controller);

class GoogleMap extends StatefulWidget {
  GoogleMap({
    @required this.onMapCreated,
    GoogleMapOptions options,
    this.gestureRecognizers = const <OneSequenceGestureRecognizer>[],
  })  : assert(gestureRecognizers != null),
        this.options = GoogleMapOptions.defaultOptions.copyWith(options);

  final MapCreatedCallback onMapCreated;

  final GoogleMapOptions options;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this list is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final List<OneSequenceGestureRecognizer> gestureRecognizers;

  @override
  State createState() => new _GoogleMapState();
}

class _GoogleMapState extends State<GoogleMap> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.flutter.io/google_maps',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: widget.gestureRecognizers,
        creationParams: widget.options._toJson(),
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return new Text(
        '$defaultTargetPlatform is not yet supported by the maps plugin');
  }

  Future<void> onPlatformViewCreated(int id) async {
    final GoogleMapController controller =
        await GoogleMapController.init(id, widget.options);
    widget.onMapCreated(controller);
  }
}
