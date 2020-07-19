// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../method_channel/method_channel_file_picker.dart';

/// The interface that implementations of file_picker must implement.
///
/// Platform implementations should extend this class rather than implement it as `file_picker`
/// does not consider newly added methods to be breaking changes. Extending this class
/// (using `extends`) ensures that the subclass will get the default implementation, while
/// platform implementations that `implements` this interface will be broken by newly added
/// [FilePickerPlatform] methods.
abstract class FilePickerPlatform extends PlatformInterface {
  /// Constructs a FilePickerPlatform.
  FilePickerPlatform() : super(token: _token);

  static final Object _token = Object();

  static FilePickerPlatform _instance = MethodChannelFilePicker();

  /// The default instance of [FilePickerPlatform] to use.
  ///
  /// Defaults to [MethodChannelFilePicker].
  static FilePickerPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [FilePickerPlatform] when they register themselves.
  static set instance(FilePickerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }


  /// Returns the message from each platform implementation
  Future<String> getMessage() {
    throw UnimplementedError('getMessage() has not been implemented.');
  }
}
