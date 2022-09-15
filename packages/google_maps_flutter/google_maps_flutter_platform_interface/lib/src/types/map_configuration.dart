// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

import 'ui.dart';

/// Configuration options for the GoogleMaps user interface.
@immutable
class MapConfiguration {
  /// Creates a new configuration instance with the given options.
  ///
  /// Any options that aren't passed will be null, which allows this to serve
  /// as either a full configuration selection, or an update to an existing
  /// configuration where only non-null values are updated.
  const MapConfiguration({
    this.compassEnabled,
    this.mapToolbarEnabled,
    this.cameraTargetBounds,
    this.mapType,
    this.minMaxZoomPreference,
    this.rotateGesturesEnabled,
    this.scrollGesturesEnabled,
    this.tiltGesturesEnabled,
    this.trackCameraPosition,
    this.zoomControlsEnabled,
    this.zoomGesturesEnabled,
    this.liteModeEnabled,
    this.myLocationEnabled,
    this.myLocationButtonEnabled,
    this.padding,
    this.indoorViewEnabled,
    this.trafficEnabled,
    this.buildingsEnabled,
  });

  /// True if the compass UI should be shown.
  final bool? compassEnabled;

  /// True if the map toolbar should be shown.
  final bool? mapToolbarEnabled;

  /// The bounds to display.
  final CameraTargetBounds? cameraTargetBounds;

  /// The type of the map.
  final MapType? mapType;

  /// The prefered zoom range.
  final MinMaxZoomPreference? minMaxZoomPreference;

  /// True if rotate gestures should be enabled.
  final bool? rotateGesturesEnabled;

  /// True if scroll gestures should be enabled.
  final bool? scrollGesturesEnabled;

  /// True if tilt gestures should be enabled.
  final bool? tiltGesturesEnabled;

  /// True if camera position changes should trigger notifications.
  final bool? trackCameraPosition;

  /// True if zoom controls should be displayed.
  final bool? zoomControlsEnabled;

  /// True if zoom gestures should be enabled.
  final bool? zoomGesturesEnabled;

  /// True if the map should use Lite Mode, showing a limited-interactivity
  /// bitmap, on supported platforms.
  final bool? liteModeEnabled;

  /// True if the current location should be tracked and displayed.
  final bool? myLocationEnabled;

  /// True if the control to jump to the current location should be displayed.
  final bool? myLocationButtonEnabled;

  /// The padding for the map display.
  final EdgeInsets? padding;

  /// True if indoor map views should be enabled.
  final bool? indoorViewEnabled;

  /// True if the traffic overlay should be enabled.
  final bool? trafficEnabled;

  /// True if 3D building display should be enabled.
  final bool? buildingsEnabled;

  /// Returns a new options object containing only the values of this instance
  /// that are different from [other].
  MapConfiguration diffFrom(MapConfiguration other) {
    return MapConfiguration(
      compassEnabled:
          compassEnabled != other.compassEnabled ? compassEnabled : null,
      mapToolbarEnabled: mapToolbarEnabled != other.mapToolbarEnabled
          ? mapToolbarEnabled
          : null,
      cameraTargetBounds: cameraTargetBounds != other.cameraTargetBounds
          ? cameraTargetBounds
          : null,
      mapType: mapType != other.mapType ? mapType : null,
      minMaxZoomPreference: minMaxZoomPreference != other.minMaxZoomPreference
          ? minMaxZoomPreference
          : null,
      rotateGesturesEnabled:
          rotateGesturesEnabled != other.rotateGesturesEnabled
              ? rotateGesturesEnabled
              : null,
      scrollGesturesEnabled:
          scrollGesturesEnabled != other.scrollGesturesEnabled
              ? scrollGesturesEnabled
              : null,
      tiltGesturesEnabled: tiltGesturesEnabled != other.tiltGesturesEnabled
          ? tiltGesturesEnabled
          : null,
      trackCameraPosition: trackCameraPosition != other.trackCameraPosition
          ? trackCameraPosition
          : null,
      zoomControlsEnabled: zoomControlsEnabled != other.zoomControlsEnabled
          ? zoomControlsEnabled
          : null,
      zoomGesturesEnabled: zoomGesturesEnabled != other.zoomGesturesEnabled
          ? zoomGesturesEnabled
          : null,
      liteModeEnabled:
          liteModeEnabled != other.liteModeEnabled ? liteModeEnabled : null,
      myLocationEnabled: myLocationEnabled != other.myLocationEnabled
          ? myLocationEnabled
          : null,
      myLocationButtonEnabled:
          myLocationButtonEnabled != other.myLocationButtonEnabled
              ? myLocationButtonEnabled
              : null,
      padding: padding != other.padding ? padding : null,
      indoorViewEnabled: indoorViewEnabled != other.indoorViewEnabled
          ? indoorViewEnabled
          : null,
      trafficEnabled:
          trafficEnabled != other.trafficEnabled ? trafficEnabled : null,
      buildingsEnabled:
          buildingsEnabled != other.buildingsEnabled ? buildingsEnabled : null,
    );
  }

  /// Returns a copy of this instance with any non-null settings form [diff]
  /// replacing the previous values.
  MapConfiguration applyDiff(MapConfiguration diff) {
    return MapConfiguration(
      compassEnabled: diff.compassEnabled ?? compassEnabled,
      mapToolbarEnabled: diff.mapToolbarEnabled ?? mapToolbarEnabled,
      cameraTargetBounds: diff.cameraTargetBounds ?? cameraTargetBounds,
      mapType: diff.mapType ?? mapType,
      minMaxZoomPreference: diff.minMaxZoomPreference ?? minMaxZoomPreference,
      rotateGesturesEnabled:
          diff.rotateGesturesEnabled ?? rotateGesturesEnabled,
      scrollGesturesEnabled:
          diff.scrollGesturesEnabled ?? scrollGesturesEnabled,
      tiltGesturesEnabled: diff.tiltGesturesEnabled ?? tiltGesturesEnabled,
      trackCameraPosition: diff.trackCameraPosition ?? trackCameraPosition,
      zoomControlsEnabled: diff.zoomControlsEnabled ?? zoomControlsEnabled,
      zoomGesturesEnabled: diff.zoomGesturesEnabled ?? zoomGesturesEnabled,
      liteModeEnabled: diff.liteModeEnabled ?? liteModeEnabled,
      myLocationEnabled: diff.myLocationEnabled ?? myLocationEnabled,
      myLocationButtonEnabled:
          diff.myLocationButtonEnabled ?? myLocationButtonEnabled,
      padding: diff.padding ?? padding,
      indoorViewEnabled: diff.indoorViewEnabled ?? indoorViewEnabled,
      trafficEnabled: diff.trafficEnabled ?? trafficEnabled,
      buildingsEnabled: diff.buildingsEnabled ?? buildingsEnabled,
    );
  }

  /// True if no options are set.
  bool get isEmpty =>
      compassEnabled == null &&
      mapToolbarEnabled == null &&
      cameraTargetBounds == null &&
      mapType == null &&
      minMaxZoomPreference == null &&
      rotateGesturesEnabled == null &&
      scrollGesturesEnabled == null &&
      tiltGesturesEnabled == null &&
      trackCameraPosition == null &&
      zoomControlsEnabled == null &&
      zoomGesturesEnabled == null &&
      liteModeEnabled == null &&
      myLocationEnabled == null &&
      myLocationButtonEnabled == null &&
      padding == null &&
      indoorViewEnabled == null &&
      trafficEnabled == null &&
      buildingsEnabled == null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MapConfiguration &&
        compassEnabled == other.compassEnabled &&
        mapToolbarEnabled == other.mapToolbarEnabled &&
        cameraTargetBounds == other.cameraTargetBounds &&
        mapType == other.mapType &&
        minMaxZoomPreference == other.minMaxZoomPreference &&
        rotateGesturesEnabled == other.rotateGesturesEnabled &&
        scrollGesturesEnabled == other.scrollGesturesEnabled &&
        tiltGesturesEnabled == other.tiltGesturesEnabled &&
        trackCameraPosition == other.trackCameraPosition &&
        zoomControlsEnabled == other.zoomControlsEnabled &&
        zoomGesturesEnabled == other.zoomGesturesEnabled &&
        liteModeEnabled == other.liteModeEnabled &&
        myLocationEnabled == other.myLocationEnabled &&
        myLocationButtonEnabled == other.myLocationButtonEnabled &&
        padding == other.padding &&
        indoorViewEnabled == other.indoorViewEnabled &&
        trafficEnabled == other.trafficEnabled &&
        buildingsEnabled == other.buildingsEnabled;
  }

  @override
  int get hashCode => Object.hash(
        compassEnabled,
        mapToolbarEnabled,
        cameraTargetBounds,
        mapType,
        minMaxZoomPreference,
        rotateGesturesEnabled,
        scrollGesturesEnabled,
        tiltGesturesEnabled,
        trackCameraPosition,
        zoomControlsEnabled,
        zoomGesturesEnabled,
        liteModeEnabled,
        myLocationEnabled,
        myLocationButtonEnabled,
        padding,
        indoorViewEnabled,
        trafficEnabled,
        buildingsEnabled,
      );
}
