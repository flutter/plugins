// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

final MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/google_mobile_maps');

/// Controller for a single GoogleMaps instance.
///
/// Used for programmatically controlling a platform-specific
/// GoogleMaps view, once created.
class GoogleMapsController {
  /// An ID identifying the GoogleMaps instance, once created.
  final Future<int> id;

  GoogleMapsController(this.id);

  static Future<void> init() async {
    await _channel.invokeMethod('init');
  }

  Future<void> setMapOptions(GoogleMapOptions options) async {
    final int id = await this.id;
    await _channel.invokeMethod('setMapOptions', <String, dynamic>{
      'map': id,
      'options': options._toJson(),
    });
  }

  Future<GoogleMapOptions> getMapOptions() async {
    final int id = await this.id;
    final dynamic json = await _channel.invokeMethod(
      'getMapOptions',
      <String, dynamic>{'map': id},
    );
    return GoogleMapOptions._fromJson(json);
  }

  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    final int id = await this.id;
    await _channel.invokeMethod('animateCamera', <String, dynamic>{
      'map': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    final int id = await this.id;
    await _channel.invokeMethod('moveCamera', <String, dynamic>{
      'map': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<Marker> addMarker(MarkerOptions markerOptions) async {
    final int id = await this.id;
    final String markerId = await _channel.invokeMethod(
      'addMarker',
      <String, dynamic>{
        'map': id,
        'markerOptions': markerOptions._toJson(),
      },
    );
    return new Marker._(id, markerId, markerOptions);
  }
}

/// Controller for a GoogleMaps instance that is integrated as a
/// platform overlay.
///
/// *Warning*: Platform overlays cannot be freely composed with
/// other widgets. See [PlatformOverlayController] for caveats and
/// limitations.
class GoogleMapsOverlayController {
  GoogleMapsOverlayController._(this.mapsController, this.overlayController);

  /// Creates a controller for a GoogleMaps of the specified size in
  /// logical pixels.
  factory GoogleMapsOverlayController.fromSize({
    @required double width,
    @required double height,
    GoogleMapOptions options = const GoogleMapOptions(),
  }) {
    assert(width != null);
    assert(height != null);
    assert(options != null);
    final _GoogleMapsPlatformOverlay overlay =
        new _GoogleMapsPlatformOverlay(options);
    return new GoogleMapsOverlayController._(
      new GoogleMapsController(overlay._textureId.future),
      new PlatformOverlayController(width, height, overlay),
    );
  }

  /// The controller of the GoogleMaps instance.
  final GoogleMapsController mapsController;

  /// The controller of the platform overlay.
  final PlatformOverlayController overlayController;

  void dispose() {
    overlayController.dispose();
  }
}

class _GoogleMapsPlatformOverlay extends PlatformOverlay {
  _GoogleMapsPlatformOverlay(this.options);

  final GoogleMapOptions options;
  Completer<int> _textureId = new Completer<int>();

  @override
  Future<int> create(Size physicalSize) {
    _textureId.complete(_channel.invokeMethod('createMap', <String, dynamic>{
      'width': physicalSize.width,
      'height': physicalSize.height,
      'options': options._toJson(),
    }).then<int>((dynamic value) => value));
    return _textureId.future;
  }

  @override
  Future<void> show(Offset physicalOffset) async {
    final int id = await _textureId.future;
    _channel.invokeMethod('showMapOverlay', <String, dynamic>{
      'map': id,
      'x': physicalOffset.dx,
      'y': physicalOffset.dy,
    });
  }

  @override
  Future<void> hide() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('hideMapOverlay', <String, dynamic>{
      'map': id,
    });
  }

  @override
  Future<void> dispose() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('disposeMap', <String, dynamic>{
      'map': id,
    });
  }
}

/// A Widget covered by a GoogleMaps platform overlay.
class GoogleMapsOverlay extends StatefulWidget {
  final GoogleMapsOverlayController controller;

  GoogleMapsOverlay({Key key, @required this.controller}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _GoogleMapsOverlayState();
}

class _GoogleMapsOverlayState extends State<GoogleMapsOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.overlayController.attachTo(context);
  }

  @override
  void dispose() {
    widget.controller.overlayController.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      child: new FutureBuilder<int>(
        future: widget.controller.mapsController.id,
        builder: (_, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasData) {
            return new Texture(textureId: snapshot.data);
          } else {
            return new Container();
          }
        },
      ),
      width: widget.controller.overlayController.width,
      height: widget.controller.overlayController.height,
    );
  }
}
