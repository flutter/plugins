part of google_maps_flutter;

typedef void MapCreatedCallback(GoogleMapController controller);

class GoogleMap extends StatefulWidget {
  GoogleMap({@required this.onMapCreated, GoogleMapOptions options})
      : this.options = GoogleMapOptions.defaultOptions.copyWith(options);

  final MapCreatedCallback onMapCreated;
  final GoogleMapOptions options;

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
