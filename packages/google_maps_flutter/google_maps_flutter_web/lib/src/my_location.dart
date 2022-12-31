// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// Type used when passing an override to the _getCurrentLocation function.
@visibleForTesting
typedef DebugGetCurrentLocation = Future<LatLng> Function();

DebugGetCurrentLocation? _overrideGetCurrentLocation;

// Get current location
_MyLocationButton? _myLocationButton;

// Watch current location and update blue dot
void _watchLocationAndUpdateBlueDot(GoogleMapController controller) {
  window.navigator.geolocation
      .watchPosition()
      .listen((Geoposition location) async {
    final Marker blueDot = await _createBlueDotMarker(LatLng(
      location.coords!.latitude!.toDouble(),
      location.coords!.longitude!.toDouble(),
    ));
    controller._markersController?.addMarkers(<Marker>{blueDot});
  });
}

// Get current location
Future<LatLng> _getCurrentLocation() async {
  final Geoposition location =
      await window.navigator.geolocation.getCurrentPosition();
  return LatLng(
    location.coords!.latitude!.toDouble(),
    location.coords!.longitude!.toDouble(),
  );
}

// Find and move to current location
Future<void> _centerMyCurrentLocation(
  GoogleMapController controller,
) async {
  try {
    LatLng location;
    if (_overrideGetCurrentLocation != null) {
      location = await _overrideGetCurrentLocation!.call();
    } else {
      location = await _getCurrentLocation();
    }
    await controller.moveCamera(
      CameraUpdate.newLatLng(location),
    );
    _myLocationButton?.doneAnimation();
  } catch (e) {
    _myLocationButton?.disable();
  }
}

// Add my location to map
void _renderMyLocationButton(gmaps.GMap map, GoogleMapController controller) {
  _myLocationButton = _MyLocationButton();

  _myLocationButton?.addClickListener(
    () async {
      _myLocationButton?.startAnimation();

      await _centerMyCurrentLocation(controller);
    },
  );
  map.addListener('dragend', () {
    _myLocationButton?.resetAnimation();
  });

  map.controls![gmaps.ControlPosition.RIGHT_BOTTOM as int]
      ?.push(_myLocationButton?.getButtonElement);
}

// Create blue dot marker with current location
Future<Marker> _createBlueDotMarker(LatLng location) async {
  final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(18, 18)),
    'icons/blue-dot.png',
    package: 'google_maps_flutter_web',
  );
  return Marker(
    markerId: const MarkerId('my_location_blue_dot'),
    icon: icon,
    position: location,
    zIndex: 0.5,
  );
}

class _MyLocationButton {
  _MyLocationButton() {
    _addCss();
    _createButton();
  }

  late ButtonElement _firstChild;
  late DivElement _secondChild;
  late DivElement _controlDiv;
  bool isAnimating = false;
  // Add animation css
  void _addCss() {
    final StyleElement styleElement = StyleElement();
    document.head?.append(styleElement);
    final CssStyleSheet sheet = styleElement.sheet as CssStyleSheet;
    String rule =
        '.waiting { animation: 1000ms infinite step-end blink-position-icon;}';
    sheet.insertRule(rule);
    rule =
        '@keyframes blink-position-icon {0% {background-position: -24px 0px;} '
        '50% {background-position: 0px 0px;}}';
    sheet.insertRule(rule);
  }

  // Add My Location widget to right bottom
  void _createButton() {
    _controlDiv = DivElement();

    _controlDiv.style.marginRight = '10px';

    _firstChild = ButtonElement();
    _firstChild.className = 'gm-control-active';
    _firstChild.style.backgroundColor = '#fff';
    _firstChild.style.border = 'none';
    _firstChild.style.outline = 'none';
    _firstChild.style.width = '40px';
    _firstChild.style.height = '40px';
    _firstChild.style.borderRadius = '2px';
    _firstChild.style.boxShadow = '0 1px 4px rgba(0,0,0,0.3)';
    _firstChild.style.cursor = 'pointer';
    _firstChild.style.padding = '8px';
    _controlDiv.append(_firstChild);

    _secondChild = DivElement();
    _secondChild.style.width = '24px';
    _secondChild.style.height = '24px';
    _secondChild.style.backgroundImage =
        'url(${window.location.href.replaceAll('/#', '')}/assets/packages/google_maps_flutter_web/icons/mylocation-sprite-2x.png)';
    _secondChild.style.backgroundSize = '240px 24px';
    _secondChild.style.backgroundPosition = '0px 0px';
    _secondChild.style.backgroundRepeat = 'no-repeat';
    _secondChild.id = 'my_location_btn';
    _firstChild.append(_secondChild);
  }

  HtmlElement get getButtonElement => _controlDiv;

  void addClickListener(Function onLick) {
    _firstChild.addEventListener('click', (_) {
      onLick();
    });
  }

  void resetAnimation() {
    if (_firstChild.disabled) {
      _secondChild.style.backgroundPosition = '-24px 0px';
    } else {
      _secondChild.style.backgroundPosition = '0px 0px';
    }
  }

  void startAnimation() {
    if (_firstChild.disabled && !isAnimating) {
      return;
    }
    _secondChild.classes.add('waiting');
  }

  void doneAnimation() {
    if (_firstChild.disabled) {
      return;
    }
    _secondChild.classes.remove('waiting');
    _secondChild.style.backgroundPosition = '-192px 0px';
  }

  void disable() {
    _firstChild.disabled = true;
    _secondChild.style.backgroundPosition = '-24px 0px';
  }

  void enable() {
    _firstChild.disabled = false;
  }
}
