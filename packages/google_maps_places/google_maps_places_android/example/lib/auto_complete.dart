// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_places_platform_interface/google_maps_places_platform_interface.dart';

import 'page.dart';

class AutoCompletePage extends PlacesExampleAppPage {
  const AutoCompletePage({Key? key})
      : super(const Icon(Icons.search), 'Places Autocomplete', key: key);

  @override
  Widget build(BuildContext context) {
    return const AutoCompleteBody();
  }
}

class AutoCompleteBody extends StatefulWidget {
  const AutoCompleteBody({super.key});

  @override
  State<StatefulWidget> createState() => _MyAutoCompleteBodyState();
}

class _MyAutoCompleteBodyState extends State<AutoCompleteBody> {
  final GoogleMapsPlacesPlatform _places = GoogleMapsPlacesPlatform.instance;

  String _query = '';
  final List<String> _countries = <String>['fi'];
  TypeFilter _typeFilter = TypeFilter.address;

  final LatLng _origin = const LatLng(65.0121, 25.4651);

  final LatLngBounds _locationBias = LatLngBounds(
    southwest: const LatLng(60.4518, 22.2666),
    northeast: const LatLng(70.0821, 27.8718),
  );
  final LatLngBounds _locationRestriction = LatLngBounds(
    southwest: const LatLng(64.4518, 24.2666),
    northeast: const LatLng(66.0821, 26.8718),
  );

  bool _withCountries = false;
  bool _withTypeFilter = false;
  bool _withOrigin = false;
  bool _withLocationBias = false;
  bool _withLocationRestriction = false;
  bool _withTokenRefresh = false;

  bool _findingPlaces = false;
  dynamic _error;

  List<AutocompletePrediction> _results = <AutocompletePrediction>[];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    final List<Widget> widgets = _buildQueryWidgets() + _buildResultWidgets();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(children: widgets),
    );
  }

  void _findAction() {
    if (_findingPlaces || _query.isEmpty) {
      return;
    }
    setState(() {
      _findingPlaces = true;
      _results = <AutocompletePrediction>[];
      _error = null;
    });
    _findPlacesAutoComplete();
  }

  Future<void> _findPlacesAutoComplete() async {
    try {
      final List<AutocompletePrediction> result =
          await _places.findAutocompletePredictions(
              query: _query,
              countries: _withCountries ? _countries : null,
              typeFilter: _withTypeFilter ? <TypeFilter>[_typeFilter] : null,
              origin: _withOrigin ? _origin : null,
              locationBias: _withLocationBias ? _locationBias : null,
              locationRestriction:
                  _withLocationRestriction ? _locationRestriction : null,
              refreshToken: _withTokenRefresh ? _withTokenRefresh : null);

      setState(() {
        _results = result;
        _findingPlaces = false;
      });
    } catch (error) {
      setState(() {
        _error = error;
        _findingPlaces = false;
      });
    }
  }

  List<Widget> _buildQueryWidgets() {
    return <Widget>[
      const Text('Required fields:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      TextFormField(
        onChanged: (String text) {
          _query = text;
        },
        initialValue: _query,
        decoration: const InputDecoration(label: Text('Query')),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            Text('Optional fields:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Enabled', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      CheckboxListTile(
        title: Row(
          children: <Widget>[
            const Text('TypeFilter:  '),
            DropdownButton<TypeFilter>(
              items: TypeFilter.values
                  .map((TypeFilter item) => DropdownMenuItem<TypeFilter>(
                      value: item, child: Text(item.name)))
                  .toList(growable: false),
              value: _typeFilter,
              onChanged: (TypeFilter? value) {
                if (value != null) {
                  setState(() {
                    _typeFilter = value;
                  });
                }
              },
            ),
          ],
        ),
        checkColor: Colors.white,
        value: _withTypeFilter,
        onChanged: (bool? value) {
          setState(() {
            _withTypeFilter = value!;
          });
        },
      ),
      CheckboxListTile(
        title: Text('Countries:  ${_countries.join(',')}'),
        checkColor: Colors.white,
        value: _withCountries,
        onChanged: (bool? value) {
          setState(() {
            _withCountries = value!;
          });
        },
      ),
      CheckboxListTile(
        title: Text('Origin:  (${_origin.latitude}, ${_origin.longitude})'),
        checkColor: Colors.white,
        value: _withOrigin,
        onChanged: (bool? value) {
          setState(() {
            _withOrigin = value!;
          });
        },
      ),
      CheckboxListTile(
        title: Text('Location bias: '
            '(${_locationBias.northeast.latitude}, '
            '${_locationBias.northeast.longitude}), '
            '(${_locationBias.southwest.latitude}, '
            '${_locationBias.southwest.longitude})'),
        checkColor: Colors.white,
        value: _withLocationBias,
        onChanged: (bool? value) {
          setState(() {
            _withLocationBias = value!;
            _withLocationRestriction = false;
          });
        },
      ),
      CheckboxListTile(
        title: Text('Location restriction:  '
            '(${_locationRestriction.northeast.latitude}, '
            '${_locationRestriction.northeast.longitude}), '
            '(${_locationRestriction.southwest.latitude}, '
            '${_locationRestriction.southwest.longitude})'),
        checkColor: Colors.white,
        value: _withLocationRestriction,
        onChanged: (bool? value) {
          setState(() {
            _withLocationRestriction = value!;
            _withLocationBias = false;
          });
        },
      ),
      CheckboxListTile(
        title: Text('Refresh token:  ${_withTokenRefresh ? 'Yes' : 'No'}'),
        checkColor: Colors.white,
        value: _withTokenRefresh,
        onChanged: (bool? value) {
          setState(() {
            _withTokenRefresh = value!;
          });
        },
      ),
      ElevatedButton(
        onPressed: _findAction,
        child: const Text('Find'),
      ),
      Container(padding: const EdgeInsets.only(top: 20))
    ];
  }

  Widget _buildPredictionRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: Text(title)),
        Flexible(child: Text(value, textAlign: TextAlign.end))
      ],
    );
  }

  Widget _buildAutoPredictionItem(AutocompletePrediction? item) {
    if (item == null) {
      return Container();
    }
    return Column(children: <Widget>[
      _buildPredictionRow('FullText: ', item.fullText),
      _buildPredictionRow('PrimaryText: ', item.primaryText),
      _buildPredictionRow('SecondaryText: ', item.secondaryText),
      _buildPredictionRow(
          'Distance: ', '${(item.distanceMeters ?? 0) / 1000} km'),
      _buildPredictionRow('PlaceId: ', item.placeId),
      _buildPredictionRow(
          'PlaceTypes: ',
          item.placeTypes
              .map((PlaceType placeType) => placeType.name)
              .join(', ')),
      const Divider(thickness: 2),
    ]);
  }

  Widget _buildErrorWidget() {
    final ThemeData theme = Theme.of(context);
    final String errorText = _error == null ? '' : _error.toString();
    return Text(errorText,
        style: theme.textTheme.caption?.copyWith(color: theme.errorColor));
  }

  List<Widget> _buildResultWidgets() {
    return <Widget>[
      const Padding(
        padding: EdgeInsets.only(top: 4.0, bottom: 16.0),
        child: Text('Results:', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      if (_error != null)
        _buildErrorWidget()
      else if (!_findingPlaces)
        Column(
          children:
              _results.map(_buildAutoPredictionItem).toList(growable: false),
        )
      else
        const Center(child: CircularProgressIndicator()),
      const Image(
        image: AssetImage('assets/google_on_white.png'),
      ),
    ];
  }
}
