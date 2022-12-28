// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

/// Type used when passing an override to the _getCurrentLocation function.
@visibleForTesting
typedef DebugGetCurrentLocation = Future<LatLng> Function();
HtmlElement? _myLocationButton;

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
Future<void> _displayAndCenterMyCurrentLocation(
  GoogleMapController controller,
) async {
  LatLng location;
  if (controller._overrideGetCurrentLocation != null) {
    location = await controller._overrideGetCurrentLocation!.call();
  } else {
    location = await _getCurrentLocation();
  }
  _addBlueDotMarker(controller._markersController, location);

  await controller.moveCamera(
    CameraUpdate.newLatLng(location),
  );
}

// Add my location to map
void _addMyLocationButton(gmaps.GMap map, GoogleMapController controller) {
  _myLocationButton = _createMyLocationButton(controller);

  map.addListener('dragend', () {
    document.getElementById('you_location_img')?.style.backgroundPosition =
        '0px 0px';
  });

  map.controls![gmaps.ControlPosition.RIGHT_BOTTOM as int]
      ?.push(_myLocationButton);
}

// Add blue dot for current location
Future<void> _addBlueDotMarker(
    MarkersController? markersController, LatLng location) async {
  assert(markersController != null, 'Cannot update markers after dispose().');

  final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(18, 18)),
    'icons/blue-dot.png',
    package: 'google_maps_flutter_web',
  );
  markersController?.addMarkers(<Marker>{
    Marker(
      markerId: const MarkerId('my_location_blue_dot'),
      icon: icon,
      position: location,
      zIndex: 0.5,
    )
  });
}

// Add My Location widget to right bottom
HtmlElement _createMyLocationButton(GoogleMapController controller) {
  final HtmlElement controlDiv = DivElement();
  controlDiv.style.marginRight = '10px';

  final HtmlElement firstChild = ButtonElement();
  firstChild.className = 'gm-control-active';
  firstChild.style.backgroundColor = '#fff';
  firstChild.style.border = 'none';
  firstChild.style.outline = 'none';
  firstChild.style.width = '40px';
  firstChild.style.height = '40px';
  firstChild.style.borderRadius = '2px';
  firstChild.style.boxShadow = '0 1px 4px rgba(0,0,0,0.3)';
  firstChild.style.cursor = 'pointer';
  firstChild.style.padding = '8px';
  controlDiv.append(firstChild);

  final HtmlElement secondChild = DivElement();
  secondChild.style.width = '24px';
  secondChild.style.height = '24px';
  secondChild.style.backgroundImage =
      'url(${window.location.href.replaceAll('/#', '')}/assets/packages/google_maps_flutter_web/icons/mylocation-sprite-2x.png)';
  secondChild.style.backgroundSize = '240px 24px';
  secondChild.style.backgroundPosition = '0px 0px';
  secondChild.style.backgroundRepeat = 'no-repeat';
  secondChild.id = 'you_location_img';
  firstChild.append(secondChild);

  firstChild.addEventListener('click', (_) {
    String imgX = '0';
    // Add animation when find current location
    final Timer timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      imgX = (imgX == '-24') ? '0' : '-24';
      document.getElementById('you_location_img')?.style.backgroundPosition =
          '${imgX}px 0px';
    });
    // Find and move to current location
    _displayAndCenterMyCurrentLocation(controller).then((_) {
      timer.cancel();
      document.getElementById('you_location_img')?.style.backgroundPosition =
          '-192px 0px';
    });
  });

  return controlDiv;
}
