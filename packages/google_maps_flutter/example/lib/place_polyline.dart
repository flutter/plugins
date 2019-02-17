import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlacePolylinePage extends Page {
  PlacePolylinePage() : super(const Icon(Icons.map), 'Place polyline');

  @override
  Widget build(BuildContext context) {
    return const PlacePolylineBody();
  }
}

class PlacePolylineBody extends StatefulWidget {
  const PlacePolylineBody();

  @override
  State<StatefulWidget> createState() => PlacePolylineBodyState();
}

class PlacePolylineBodyState extends State<PlacePolylineBody> {
  PlacePolylineBodyState();

  GoogleMapController controller;
  int _polylineCount = 0;
  Polyline _selectedPolyline;

  // Values when toggling polyline color
  int colorsIndex = 0;
  List<int> colors = <int>[
    0xFF000000,
    0xFF2196F3,
    0xFFF44336,
  ];

  // Values when toggling polyline width
  int widthsIndex = 0;
  List<double> widths = <double>[10.0, 20.0, 5.0];

  int jointTypesIndex = 0;
  List<int> jointTypes = <int>[
    JointType.mitered,
    JointType.bevel,
    JointType.round
  ];

  // Values when toggling polyline end cap type
  int endCapsIndex = 0;
  List<Cap> endCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  // Values when toggling polyline start cap type
  int startCapsIndex = 0;
  List<Cap> startCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  // Values when toggling polyline pattern
  int patternsIndex = 0;
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[],
    <PatternItem>[
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)],
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)],
  ];

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    controller.onPolylineTapped.add(_onPolylineTapped);
  }

  @override
  void dispose() {
    controller?.onPolylineTapped?.remove(_onPolylineTapped);
    super.dispose();
  }

  void _onPolylineTapped(Polyline polyline) {
    setState(() {
      _selectedPolyline = polyline;
    });
  }

  void _updateSelectedPolyline(PolylineOptions changes) {
    controller.updatePolyline(_selectedPolyline, changes);
  }

  void _add() {
    controller.addPolyline(PolylineOptions(
      consumeTapEvents: true,
      color: Colors.orange.value,
      width: 10,
      points: _createPoints(),
    ));
    setState(() {
      _polylineCount += 1;
    });
  }

  void _remove() {
    controller.removePolyline(_selectedPolyline);
    setState(() {
      _selectedPolyline = null;
      _polylineCount -= 1;
    });
  }

  Future<void> _toggleGeodesic() async {
    _updateSelectedPolyline(
      PolylineOptions(
        geodesic: !_selectedPolyline.options.geodesic,
      ),
    );
  }

  Future<void> _toggleVisible() async {
    _updateSelectedPolyline(
      PolylineOptions(
        visible: !_selectedPolyline.options.visible,
      ),
    );
  }

  Future<void> _changeColor() async {
    _updateSelectedPolyline(
      PolylineOptions(
        color: colors[++colorsIndex % colors.length],
      ),
    );
  }

  Future<void> _changeWidth() async {
    _updateSelectedPolyline(
      PolylineOptions(
        width: widths[++widthsIndex % widths.length],
      ),
    );
  }

  Future<void> _changeJointType() async {
    _updateSelectedPolyline(
      PolylineOptions(
        jointType: jointTypes[++jointTypesIndex % jointTypes.length],
      ),
    );
  }

  Future<void> _changeEndCap() async {
    _updateSelectedPolyline(
      PolylineOptions(
        endCap: endCaps[++endCapsIndex % endCaps.length],
      ),
    );
  }

  Future<void> _changeStartCap() async {
    _updateSelectedPolyline(
      PolylineOptions(
        startCap: startCaps[++startCapsIndex % startCaps.length],
      ),
    );
  }

  Future<void> _changePattern() async {
    _updateSelectedPolyline(
      PolylineOptions(pattern: patterns[++patternsIndex % patterns.length]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 350.0,
            height: 300.0,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(52.4478, -3.5402),
                zoom: 7.0,
              ),
              onMapCreated: _onMapCreated,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('add'),
                          onPressed: (_polylineCount == 1) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed:
                              (_selectedPolyline == null) ? null : _remove,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('toggle geodesic'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _toggleGeodesic,
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FlatButton(
                          child: const Text('change width'),
                          onPressed:
                              (_selectedPolyline == null) ? null : _changeWidth,
                        ),
                        FlatButton(
                          child: const Text('change start cap'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changeStartCap,
                        ),
                        FlatButton(
                          child: const Text('change end cap'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changeEndCap,
                        ),
                        FlatButton(
                          child: const Text('change joint type'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changeJointType,
                        ),
                        FlatButton(
                          child: const Text('change color'),
                          onPressed:
                              (_selectedPolyline == null) ? null : _changeColor,
                        ),
                        FlatButton(
                          child: const Text('change pattern'),
                          onPressed: (_selectedPolyline == null)
                              ? null
                              : _changePattern,
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<LatLng> _createPoints() {
    final List<LatLng> points = <LatLng>[];
    points.add(_createLatLng(51.4816, -3.1791));
    points.add(_createLatLng(53.0430, -2.9925));
    points.add(_createLatLng(53.1396, -4.2739));
    points.add(_createLatLng(52.4153, -4.0829));
    return points;
  }

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
