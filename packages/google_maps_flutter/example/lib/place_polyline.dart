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
  Map<PolylineId, Polyline> polylines = <PolylineId, Polyline>{};
  int _polylineIdCounter = 1;
  PolylineId selectedPolyline;

  // Values when toggling polyline color
  int colorsIndex = 0;
  List<Color> colors = <Color>[
    Colors.purple,
    Colors.red,
    Colors.green,
    Colors.pink,
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onPolylineTapped(PolylineId polylineId) {
    setState(() {
      selectedPolyline = polylineId;
    });
  }

  void _remove() {
    setState(() {
      if (polylines.containsKey(selectedPolyline)) {
        polylines.remove(selectedPolyline);
      }
    });
  }

  void _add() {
    final int polylineCount = polylines.length;

    if (polylineCount == 12) {
      return;
    }

    final String polylineIdVal = 'polyline_id_$_polylineIdCounter';
    _polylineIdCounter++;
    final PolylineId polylineId = PolylineId(polylineIdVal);

    final Polyline polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.orange,
      width: 10,
      points: _createPoints(),
      onTap: () {
        _onPolylineTapped(polylineId);
      },
    );

    setState(() {
      polylines[polylineId] = polyline;
    });
  }

  Future<void> _toggleGeodesic() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        geodesicParam: !polyline.geodesic,
      );
    });
  }

  Future<void> _toggleVisible() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        visibleParam: !polyline.visible,
      );
    });
  }

  Future<void> _changeColor() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        colorParam: colors[++colorsIndex % colors.length],
      );
    });
  }

  Future<void> _changeWidth() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        widthParam: widths[++widthsIndex % widths.length],
      );
    });
  }

  Future<void> _changeJointType() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        jointTypeParam: jointTypes[++jointTypesIndex % jointTypes.length],
      );
    });
  }

  Future<void> _changeEndCap() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        endCapParam: endCaps[++endCapsIndex % endCaps.length],
      );
    });
  }

  Future<void> _changeStartCap() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        startCapParam: startCaps[++startCapsIndex % startCaps.length],
      );
    });
  }

  Future<void> _changePattern() async {
    final Polyline polyline = polylines[selectedPolyline];
    setState(() {
      polylines[selectedPolyline] = polyline.copyWith(
        patternParam: patterns[++patternsIndex % patterns.length],
      );
    });
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
              polylines: Set<Polyline>.of(polylines.values),
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
                          onPressed: _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed:
                              (selectedPolyline == null) ? null : _remove,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('toggle geodesic'),
                          onPressed: (selectedPolyline == null)
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
                              (selectedPolyline == null) ? null : _changeWidth,
                        ),
                        FlatButton(
                          child: const Text('change start cap'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : _changeStartCap,
                        ),
                        FlatButton(
                          child: const Text('change end cap'),
                          onPressed:
                              (selectedPolyline == null) ? null : _changeEndCap,
                        ),
                        FlatButton(
                          child: const Text('change joint type'),
                          onPressed: (selectedPolyline == null)
                              ? null
                              : _changeJointType,
                        ),
                        FlatButton(
                          child: const Text('change color'),
                          onPressed:
                              (selectedPolyline == null) ? null : _changeColor,
                        ),
                        FlatButton(
                          child: const Text('change pattern'),
                          onPressed: (selectedPolyline == null)
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
