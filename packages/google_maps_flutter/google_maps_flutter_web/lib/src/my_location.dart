// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of google_maps_flutter_web;

Geolocation _geolocation = window.navigator.geolocation;

// Watch current location and update blue dot
Future<void> _displayAndWatchMyLocation(MarkersController controller) async {
  final Marker marker = await _createBlueDotMarker();
  _geolocation.watchPosition().listen((Geoposition location) async {
    // TODO(nploi): https://github.com/flutter/plugins/pull/6868#discussion_r1057898052
    // We're discarding a lot of information from coords, like its accuracy, heading and speed. Those can be used to:
    // - Render a bigger "blue halo" around the current position marker when the accuracy is low.
    // - Render the direction in which we're looking at with a small "cone" using the heading information.
    // - Render the current position marker as an arrow when the current position is "moving" (speed > certain threshold), and the direction in which the arrow should point (again, with the heading information).
    controller.addMarkers(<Marker>{
      marker.copyWith(
          positionParam: LatLng(
        location.coords!.latitude!.toDouble(),
        location.coords!.longitude!.toDouble(),
      ))
    });
  });
}

// Get current location
Future<LatLng> _getCurrentLocation() async {
  final Geoposition location = await _geolocation.getCurrentPosition(
      timeout: const Duration(seconds: 30));
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
    final LatLng location = await _getCurrentLocation();
    await controller.moveCamera(
      CameraUpdate.newLatLng(location),
    );
    controller._myLocationButton?.doneAnimation();
  } catch (e) {
    controller._myLocationButton?.disableBtn();
  }
}

// Add my location to map
void _addMyLocationButton(gmaps.GMap map, GoogleMapController controller) {
  controller._myLocationButton = MyLocationButton();
  controller._myLocationButton?.addClickListener(
    (_) async {
      controller._myLocationButton?.startAnimation();
      await _centerMyCurrentLocation(controller);
    },
  );
  map.addListener('dragend', () {
    controller._myLocationButton?.resetAnimation();
  });

  map.controls![gmaps.ControlPosition.RIGHT_BOTTOM as int]
      ?.push(controller._myLocationButton?.getButton);
}

// Create blue dot marker
Future<Marker> _createBlueDotMarker() async {
  final BitmapDescriptor icon = await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(size: Size(18, 18)),
    'icons/blue-dot.png',
    package: 'google_maps_flutter_web',
  );
  return Marker(
    markerId: const MarkerId('my_location_blue_dot'),
    icon: icon,
    zIndex: 0.5,
  );
}

/// This class support create my location button & handle animation
@visibleForTesting
class MyLocationButton {
  /// Add css and create my location button
  MyLocationButton() {
    _addCss();
    _createButton();
  }

  late ButtonElement _btnChild;
  late DivElement _imageChild;
  late DivElement _controlDiv;

  // Add animation css
  void _addCss() {
    final StyleElement styleElement = StyleElement();
    document.head?.append(styleElement);
    // ignore: cast_nullable_to_non_nullable
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

    _btnChild = ButtonElement();
    _btnChild.className = 'gm-control-active';
    _btnChild.style.backgroundColor = '#fff';
    _btnChild.style.border = 'none';
    _btnChild.style.outline = 'none';
    _btnChild.style.width = '40px';
    _btnChild.style.height = '40px';
    _btnChild.style.borderRadius = '2px';
    _btnChild.style.boxShadow = '0 1px 4px rgba(0,0,0,0.3)';
    _btnChild.style.cursor = 'pointer';
    _btnChild.style.padding = '8px';
    _controlDiv.append(_btnChild);

    _imageChild = DivElement();
    _imageChild.style.width = '24px';
    _imageChild.style.height = '24px';
    _imageChild.style.backgroundImage =
        'url(${window.location.href.replaceAll('/#', '')}/assets/packages/google_maps_flutter_web/icons/mylocation-sprite-2x.png)';
    _imageChild.style.backgroundSize = '240px 24px';
    _imageChild.style.backgroundPosition = '0px 0px';
    _imageChild.style.backgroundRepeat = 'no-repeat';
    _imageChild.id = 'my_location_btn';
    _btnChild.append(_imageChild);
  }

  /// Get button element
  HtmlElement get getButton => _controlDiv;

  /// Add click listener
  void addClickListener(EventListener? listener) {
    _btnChild.addEventListener('click', listener);
  }

  /// Reset animation
  void resetAnimation() {
    if (_btnChild.disabled) {
      _imageChild.style.backgroundPosition = '-24px 0px';
    } else {
      _imageChild.style.backgroundPosition = '0px 0px';
    }
  }

  /// Start animation
  void startAnimation() {
    if (_btnChild.disabled) {
      return;
    }
    _imageChild.classes.add('waiting');
  }

  /// Done animation
  void doneAnimation() {
    if (_btnChild.disabled) {
      return;
    }
    _imageChild.classes.remove('waiting');
    _imageChild.style.backgroundPosition = '-192px 0px';
  }

  /// Disable button
  void disableBtn() {
    _btnChild.disabled = true;
    _imageChild.style.backgroundPosition = '-24px 0px';
  }

  /// Check button disabled or enabled
  bool isDisabled() {
    return _btnChild.disabled;
  }
}
