import 'dart:html' as html;

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/foundation.dart';

/// A utility to fetch camera settings
/// based on the camera tracks.
class CameraSettings {
  // A facing mode constraint name.
  static const _facingModeKey = "facingMode";

  /// The current browser window used to access media devices.
  @visibleForTesting
  html.Window? window = html.window;

  /// Returns a camera lens direction based on the [videoTrack]'s facing mode.
  CameraLensDirection getLensDirectionForVideoTrack(
    html.MediaStreamTrack videoTrack,
  ) {
    final mediaDevices = window?.navigator.mediaDevices;

    // Throw a not supported exception if the current browser window
    // does not support any media devices.
    if (mediaDevices == null) {
      throw CameraException(
        CameraErrorCodes.notSupported,
        'The camera is not supported on this device.',
      );
    }

    // Check if the facing mode is supported by the current browser.
    final supportedConstraints = mediaDevices.getSupportedConstraints();
    final facingModeSupported = supportedConstraints[_facingModeKey] ?? false;

    // Fallback to the external lens direction
    // if the facing mode is not supported.
    if (!facingModeSupported) {
      return CameraLensDirection.external;
    }

    // Extract the facing mode from the video track settings.
    // The property may not be available if it's not supported
    // by the browser or not available due to context.
    //
    // MediaTrackSettings:
    // https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackSettings
    final videoTrackSettings = videoTrack.getSettings();
    final facingMode = videoTrackSettings[_facingModeKey];

    if (facingMode == null) {
      // If the facing mode does not exist on the video track settings,
      // check for the facing mode in video track capabilities.
      //
      // MediaTrackCapabilities:
      // https://www.w3.org/TR/mediacapture-streams/#dom-mediatrackcapabilities
      final videoTrackCapabilities = videoTrack.getCapabilities();

      // A list of facing mode capabilities as
      // the camera may support multiple facing modes.
      final facingModeCapabilities =
          List<String>.from(videoTrackCapabilities[_facingModeKey] ?? []);

      if (facingModeCapabilities.isNotEmpty) {
        final facingModeCapability = facingModeCapabilities.first;
        return mapFacingModeToLensDirection(facingModeCapability);
      } else {
        // Fallback to the external lens direction
        // if there are no facing mode capabilities.
        return CameraLensDirection.external;
      }
    }

    return mapFacingModeToLensDirection(facingMode);
  }

  /// Maps the facing mode to appropriate camera lens direction.
  ///
  /// The following values for the facing mode are supported:
  /// https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackSettings/facingMode
  @visibleForTesting
  CameraLensDirection mapFacingModeToLensDirection(String facingMode) {
    switch (facingMode) {
      case 'user':
        return CameraLensDirection.front;
      case 'environment':
        return CameraLensDirection.back;
      case 'left':
      case 'right':
      default:
        return CameraLensDirection.external;
    }
  }
}
