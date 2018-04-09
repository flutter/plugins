// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_mobile_maps;

final MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/google_mobile_maps')
      ..invokeMethod('init');

/// Controller for a single GoogleMaps instance.
///
/// Used for programmatically controlling a platform-specific
/// GoogleMaps view, once created.
class GoogleMapsController {
  /// An ID identifying the GoogleMaps instance, once created.
  final Future<int> id;

  GoogleMapsController(this.id);

  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    final int id = await this.id;
    await _channel.invokeMethod('animateCamera', <String, dynamic>{
      'id': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    final int id = await this.id;
    await _channel.invokeMethod('moveCamera', <String, dynamic>{
      'id': id,
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<void> addMarker(MarkerOptions markerOptions) async {
    final int id = await this.id;
    await _channel.invokeMethod('addMarker', <String, dynamic>{
      'id': id,
      'markerOptions': markerOptions._toJson(),
    });
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
  factory GoogleMapsOverlayController.fromSize(double width, double height) {
    final _GoogleMapsPlatformOverlay overlay = new _GoogleMapsPlatformOverlay();
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
  Completer<int> _textureId = new Completer<int>();

  @override
  Future<int> create(Size physicalSize) {
    _textureId.complete(_channel.invokeMethod('createMap', <String, dynamic>{
      'width': physicalSize.width,
      'height': physicalSize.height,
    }).then<int>((dynamic value) => value));
    return _textureId.future;
  }

  @override
  Future<void> show(Offset physicalOffset) async {
    final int id = await _textureId.future;
    _channel.invokeMethod('showMapOverlay', <String, dynamic>{
      'id': id,
      'x': physicalOffset.dx,
      'y': physicalOffset.dy,
    });
  }

  @override
  Future<void> hide() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('hideMapOverlay', <String, dynamic>{
      'id': id,
    });
  }

  @override
  Future<void> dispose() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('disposeMap', <String, dynamic>{
      'id': id,
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
