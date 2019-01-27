import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'page.dart';

class PlaceCirclePage extends Page {
  PlaceCirclePage() : super(const Icon(Icons.map), 'Place circle');

  @override
  Widget build(BuildContext context) {
    return const PlaceCircleBody();
  }
}

class PlaceCircleBody extends StatefulWidget {
  const PlaceCircleBody();

  @override
  State<StatefulWidget> createState() => PlaceCircleBodyState();
}

class PlaceCircleBodyState extends State<PlaceCircleBody> {
  PlaceCircleBodyState();

  GoogleMapController controller;
  int _circleCount = 0;
  Circle _selectedCircle;

  int colorsIndex = 0;
  List<int> colors = <int>[
    0xFF000000,
    0xFF2196F3,
    0xFFF44336,
  ];

  int widthsIndex = 0;
  List<double> widths = <double>[10.0, 20.0, 5.0];

  int jointTypesIndex = 0;
  List<int> jointTypes = <int>[
    JointType.mitered,
    JointType.bevel,
    JointType.round
  ];

  int endCapsIndex = 0;
  List<Cap> endCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  int startCapsIndex = 0;
  List<Cap> startCaps = <Cap>[Cap.buttCap, Cap.squareCap, Cap.roundCap];

  int patternsIndex = 0;
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    null,
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
    controller.onCircleTapped.add(_onCircleTapped);
  }

  @override
  void dispose() {
    controller?.onCircleTapped?.remove(_onCircleTapped);
    super.dispose();
  }

  void _onCircleTapped(Circle circle) {
    print(circle.id);
    print("circle tapped callback aayo");
    setState(() {
      _selectedCircle = circle;
    });
  }

  void _updateSelectedCircle(CircleOptions changes) {
    print(_selectedCircle.id);
    controller.updateCircle(_selectedCircle, changes);
  }

  void _add() {
    controller.addCircle(CircleOptions(
      consumeTapEvents: true,
      radius: 5000,
      center: _createLatLng(51.4816, -3.1791),
      strokeColor: Colors.red.value,
      fillColor: Colors.teal.withAlpha(100).value,
      strokeWidth: 2,
    ));
    setState(() {
      _circleCount += 1;
    });
  }

  void _remove() {
    controller.removeCircle(_selectedCircle);
    setState(() {
      _selectedCircle = null;
      _circleCount -= 1;
    });
  }

  Future<void> _toggleGeodesic() async {
    _updateSelectedCircle(
      CircleOptions(pattern: _selectedCircle.options.pattern),
    );
  }

  Future<void> _toggleVisible() async {
    _updateSelectedCircle(
      CircleOptions(
          visible: !_selectedCircle.options.visible,
          pattern: _selectedCircle.options.pattern),
    );
  }

  Future<void> _changeColor() async {
    _updateSelectedCircle(
      CircleOptions(
          strokeColor: colors[++colorsIndex % colors.length],
          pattern: _selectedCircle.options.pattern),
    );
  }

  Future<void> _changeWidth() async {
    _updateSelectedCircle(
      CircleOptions(
          strokeWidth: widths[++widthsIndex % widths.length],
          pattern: _selectedCircle.options.pattern),
    );
  }

  Future<void> _changeJointType() async {
    _updateSelectedCircle(
      CircleOptions(
          jointType: jointTypes[++jointTypesIndex % jointTypes.length],
          pattern: _selectedCircle.options.pattern),
    );
  }

  Future<void> _changePattern() async {
    _updateSelectedCircle(
      CircleOptions(pattern: patterns[++patternsIndex % patterns.length]),
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
                          onPressed: (_circleCount == 1) ? null : _add,
                        ),
                        FlatButton(
                          child: const Text('remove'),
                          onPressed: (_selectedCircle == null) ? null : _remove,
                        ),
                        FlatButton(
                          child: const Text('toggle visible'),
                          onPressed:
                              (_selectedCircle == null) ? null : _toggleVisible,
                        ),
                        FlatButton(
                          child: const Text('toggle geodesic'),
                          onPressed: (_selectedCircle == null)
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
                              (_selectedCircle == null) ? null : _changeWidth,
                        ),
                        FlatButton(
                          child: const Text('change joint type'),
                          onPressed: (_selectedCircle == null)
                              ? null
                              : _changeJointType,
                        ),
                        FlatButton(
                          child: const Text('change color'),
                          onPressed:
                              (_selectedCircle == null) ? null : _changeColor,
                        ),
                        FlatButton(
                          child: const Text('change pattern'),
                          onPressed:
                              (_selectedCircle == null) ? null : _changePattern,
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

  LatLng _createLatLng(double lat, double lng) {
    return LatLng(lat, lng);
  }
}
