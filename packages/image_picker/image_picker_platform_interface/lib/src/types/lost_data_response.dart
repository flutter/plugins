// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker_platform_interface/src/types/types.dart';

/// The response object of [ImagePicker.retrieveLostData].
///
/// Only applies to Android.
/// See also:
/// * [ImagePicker.retrieveLostData] for more details on retrieving lost data.
@Deprecated('Use methods that return a LostData object instead.')
class LostDataResponse {
  /// Creates an instance with the given [file], [exception], and [type]. Any of
  /// the params may be null, but this is never considered to be empty.
  LostDataResponse({this.file, this.exception, this.type});

  /// Initializes an instance with all member params set to null and considered
  /// to be empty.
  LostDataResponse.empty()
      : file = null,
        exception = null,
        type = null,
        _empty = true;

  /// Whether it is an empty response.
  ///
  /// An empty response should have [file], [exception] and [type] to be null.
  bool get isEmpty => _empty;

  /// The file that was lost in a previous [pickImage] or [pickVideo] call due to MainActivity being destroyed.
  ///
  /// Can be null if [exception] exists.
  final File file;

  /// The exception of the last [pickImage] or [pickVideo].
  ///
  /// If the last [pickImage] or [pickVideo] threw some exception before the MainActivity destruction, this variable keeps that
  /// exception.
  /// You should handle this exception as if the [pickImage] or [pickVideo] got an exception when the MainActivity was not destroyed.
  ///
  /// Note that it is not the exception that caused the destruction of the MainActivity.
  final PlatformException exception;

  /// Can either be [RetrieveType.image] or [RetrieveType.video];
  final RetrieveType type;

  bool _empty = false;
}
