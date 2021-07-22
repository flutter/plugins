// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/src/types/types.dart';
import 'package:flutter/foundation.dart';

/// A utility to fetch and map camera settings.
class CameraSettings {
  // A facing mode constraint name.
  static const _facingModeKey = "facingMode";

  /// The current browser window used to access media devices.
  @visibleForTesting
  html.Window? window = html.window;

  /// Returns a facing mode of the [videoTrack]
  /// (null if the facing mode is not available).
  String? getFacingModeForVideoTrack(html.MediaStreamTrack videoTrack) {
    final mediaDevices = window?.navigator.mediaDevices;

    // Throw a not supported exception if the current browser window
    // does not support any media devices.
    if (mediaDevices == null) {
      throw CameraException(
        CameraErrorCodes.notSupported,
        'The camera is not supported on this device.',
      );
    }

    // Check if the camera facing mode is supported by the current browser.
    final supportedConstraints = mediaDevices.getSupportedConstraints();
    final facingModeSupported = supportedConstraints[_facingModeKey] ?? false;

    // Return null if the facing mode is not supported.
    if (!facingModeSupported) {
      return null;
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
      try {
        // If the facing mode does not exist in the video track settings,
        // check for the facing mode in the video track capabilities.
        //
        // MediaTrackCapabilities:
        // https://www.w3.org/TR/mediacapture-streams/#dom-mediatrackcapabilities
        //
        // This may throw a not supported error on Firefox.
        final videoTrackCapabilities = videoTrack.getCapabilities();

        // A list of facing mode capabilities as
        // the camera may support multiple facing modes.
        final facingModeCapabilities =
            List<String>.from(videoTrackCapabilities[_facingModeKey] ?? []);

        if (facingModeCapabilities.isNotEmpty) {
          final facingModeCapability = facingModeCapabilities.first;
          return facingModeCapability;
        } else {
          // Return null if there are no facing mode capabilities.
          return null;
        }
      } catch (e) {
        switch (e.runtimeType.toString()) {
          case 'JSNoSuchMethodError':
            // Return null if getting capabilities is currently not supported.
            return null;
          default:
            throw CameraException(
              CameraErrorCodes.unknown,
              'An unknown error occured when getting the video track capabilities.',
            );
        }
      }
    }

    return facingMode;
  }

  /// Maps the given [facingMode] to [CameraLensDirection].
  ///
  /// The following values for the facing mode are supported:
  /// https://developer.mozilla.org/en-US/docs/Web/API/MediaTrackSettings/facingMode
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
