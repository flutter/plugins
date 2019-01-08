import 'package:flutter/material.dart';
import 'package:google_maps_flutter_example/page.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlacePolygonPage extends Page {
  PlacePolygonPage() : super(const Icon(Icons.map), 'Place polygon');

  @override
  Widget build(BuildContext context) {
    return const PlacePolygonBody();
  }
}

class PlacePolygonBody extends StatefulWidget {
  const PlacePolygonBody();

  @override
  State<StatefulWidget> createState() => PlacePolygonBodyState();
}

class PlacePolygonBodyState extends State<PlacePolygonBody> {
  PlacePolygonBodyState();

  static final LatLng center = const LatLng(-33.86711, 151.1947171);

  GoogleMapController controller;
  Polygon _selectedPolygon;
  int _polygonCount = 0;

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    controller.onPolygonTapped.add(_onPolygonTapped);
  }

  @override
  void dispose() {
    controller?.onPolygonTapped?.remove(_onPolygonTapped);
    super.dispose();
  }

  void _updateSelectedPolygon(PolygonOptions changes) {
    controller.updatePolygon(_selectedPolygon, changes);
  }

  void _onPolygonTapped(Polygon polygon) {
    if (_selectedPolygon == null) {
      setState(() {
        _selectedPolygon = polygon;
      });
      _updateSelectedPolygon(
        const PolygonOptions(fillColor: 0x3500ff00, strokeColor: 0x8000ff00),
      );
    } else {
      _updateSelectedPolygon(
        const PolygonOptions(fillColor: 0x35ff0000, strokeColor: 0x80ff0000),
      );
      setState(() {
        _selectedPolygon = null;
      });
    }
  }

  void _remove() {
    controller.removePolygon(_selectedPolygon);
    setState(() {
      _selectedPolygon = null;
      _polygonCount -= 1;
    });
  }

  void _addHole() {
    if (_selectedPolygon != null) {
      _updateSelectedPolygon(
        const PolygonOptions(
          holes: <List<LatLng>>[
            <LatLng>[
              LatLng(-33.853812, 151.199619),
              LatLng(-33.853951, 151.210352),
              LatLng(-33.864126, 151.211320),
            ],
          ],
        ),
      );
    }
  }

  void _removeHole() {
    if (_selectedPolygon != null) {
      _updateSelectedPolygon(
        const PolygonOptions(holes: []),
      );
    }
  }

  void _add() {
    if (_polygonCount < 1) {
      controller.addPolygon(
        PolygonOptions.defaultOptions.copyWith(new PolygonOptions(
          points: <LatLng>[
            LatLng(-33.819306, 151.174164),
            LatLng(-33.820311, 151.265666),
            LatLng(-33.893669, 151.281408),
            LatLng(-33.894117, 151.169447),
          ],
        )),
      );

      setState(() {
        _polygonCount += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 300.0,
            height: 200.0,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-33.86711, 151.1947171),
                zoom: 11,
              ),
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
                              (_selectedPolygon == null) ? null : _remove,
                        ),
                        FlatButton(
                          child: const Text('add hole'),
                          onPressed:
                              (_selectedPolygon == null) ? null : _addHole,
                        ),
                        FlatButton(
                          child: const Text('remove hole'),
                          onPressed:
                              (_selectedPolygon == null) ? null : _removeHole,
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
}
