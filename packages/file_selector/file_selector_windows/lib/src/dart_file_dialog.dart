// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:win32/win32.dart';
import 'dart_place.dart';

/// Exposes custom places.
class CustomPlace {
  /// CustomPlace constructor.
  CustomPlace(this.item, this.place);

  /// An IShellItem.
  IShellItem item;

  /// A Place.
  Place place;
}

/// An abstract of FileDialog, that allows user to interact with the file system.
abstract class FileDialog {
  /// Sets a filter for the file types shown.
  ///
  /// When using the Open dialog, the file types declared here are used to
  /// filter the view. When using the Save dialog, these values determine which
  /// file name extension is appended to the file name.
  ///
  /// The first value is the "friendly" name which is shown to the user (e.g.
  /// `JPEG Files`); the second value is a filter, which may be a semicolon-
  /// separated list (for example `*.jpg;*.jpeg`).
  Map<String, String> filterSpecification = <String, String>{};

  /// Set hWnd of dialog
  int hWndOwner = NULL;

  /// Sets is save dialog option, this allows the user to select inixistent files.
  bool fileMustExist = false;

  /// Clears the current filter specification, this way a new filter can be added.
  void clearFilterSpecification() {
    filterSpecification = <String, String>{};
  }
}
