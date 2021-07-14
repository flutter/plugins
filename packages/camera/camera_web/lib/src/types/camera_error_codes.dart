// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Error codes that may occur during the camera initialization or streaming.
abstract class CameraErrorCodes {
  /// The camera is not supported.
  static const notSupported = 'cameraNotSupported';

  /// The camera is not found.
  static const notFound = 'cameraNotFound';

  /// The camera is not readable.
  static const notReadable = 'cameraNotReadable';

  /// The camera options are impossible to satisfy.
  static const overconstrained = 'cameraOverconstrained';

  /// The camera cannot be used or the permission
  /// to access the camera is not granted.
  static const permissionDenied = 'cameraPermission';

  /// The camera options are incorrect or attempted
  /// to access the media input from an insecure context.
  static const type = 'cameraType';

  /// An unknown camera error.
  static const unknown = 'cameraUnknown';
}
