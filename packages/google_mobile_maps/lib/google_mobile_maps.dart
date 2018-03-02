import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'platform_overlay.dart';

final MethodChannel _channel =
    const MethodChannel('plugins.flutter.io/google_mobile_maps')
      ..invokeMethod('init');

class Location {
  final double latitude;
  final double longitude;

  const Location(this.latitude, this.longitude);

  dynamic _toJson() => <dynamic>[latitude, longitude];
  static Location _fromJson(dynamic json) => new Location(json[0], json[1]);
}

class Zoom {
  final double value;

  const Zoom(this.value);

  dynamic _toJson() => value;
  static Zoom _fromJson(dynamic json) => new Zoom(json);
}

class GoogleMapsController {
  final Future<int> id;

  GoogleMapsController(this.id);

  Future<void> moveCamera(Location location, Zoom zoom) async {
    final int id = await this.id;
    await _channel.invokeMethod('moveCamera', <String, dynamic>{
      'id': id,
      'location': location._toJson(),
      'zoom': zoom._toJson()
    });
  }
}

class GoogleMapsOverlayController {
  final GoogleMapsController mapsController;
  final PlatformOverlayController overlayController;

  GoogleMapsOverlayController(this.mapsController, this.overlayController);

  factory GoogleMapsOverlayController.fromSize(double width, double height) {
    final _GoogleMapsPlatformOverlayController overlayController =
        new _GoogleMapsPlatformOverlayController(width, height);
    final GoogleMapsController mapsController =
        new GoogleMapsController(overlayController.mapId);
    return new GoogleMapsOverlayController(mapsController, overlayController);
  }

  void dispose() {
    overlayController.dispose();
  }
}

class _GoogleMapsPlatformOverlayController extends PlatformOverlayController {
  Completer<int> _textureId = new Completer<int>();

  _GoogleMapsPlatformOverlayController(double width, double height)
      : super(width, height);

  Future<int> get mapId => _textureId.future;

  @override
  Future<int> createOverlay(Size physicalSize) {
    print('physicalSize: $physicalSize');
    _textureId.complete(_channel.invokeMethod('createMap', <String, dynamic>{
      'width': physicalSize.width,
      'height': physicalSize.height,
    }).then<int>((dynamic value) => value));
    return _textureId.future;
  }

  @override
  Future<void> showOverlay(Offset physicalOffset) async {
    final int id = await _textureId.future;
    _channel.invokeMethod('showMapOverlay', <String, dynamic>{
      'id': id,
      'x': physicalOffset.dx,
      'y': physicalOffset.dy,
    });
  }

  @override
  Future<void> hideOverlay() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('hideMapOverlay', <String, dynamic>{
      'id': id,
    });
  }

  @override
  Future<void> disposeOverlay() async {
    final int id = await _textureId.future;
    _channel.invokeMethod('disposeMap', <String, dynamic>{
      'id': id,
    });
  }
}

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
