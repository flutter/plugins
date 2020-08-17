// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// TODO: should we be using this package or just extracting the important conversion data from it?
import 'package:mime_type/mime_type.dart';

/// A set of allowed XTypes
class XTypeGroup {
  /// Creates a new group with the given label and file extensions.
  const XTypeGroup({this.label, this.fileTypes});

  /// The label for the grouping. On platforms that support selectable groups,
  /// this will be visible to the user for selecting the group.
  final String label;

  /// A list of allowed file extensions. E.g., ['png', 'jpg', 'jpeg', 'gif'].
  ///
  /// A null or empty list indicates any type is allowed.
  final List<XType> fileTypes;
}

/// A cross platform file type
class XType {
  /// Variables to store type
  String _mime;
  String _extension;

  /// Default constructor
  XType({
    String extension,
    String mime,
  }) :  this._extension = extension,
        this._mime = mime;

  /// Constructors that take other files types as input
  XType.fromMime(String mime) : this._mime = mime;

  /// Constructor that takes extension as input
  XType.fromExtension(String extension) : this._extension = extension;

  /// Get the mime type from this XType
  String get mime {
    if (mime == null) {
      _mime = mimeFromExtension(_extension);
    }
    return _mime;
  }

  /// Get the extension from this XType
  String get extension {
    if (_extension == null) {
      _extension = extensionFromMime(_mime);
    }
    return _extension;
  }
}