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

/// A set of allowed XTypes
class XTypeGroup {
  /// Creates a new group with the given label and file extensions.
  XTypeGroup({
    this.label,
    this.extensions,
    this.mimeTypes,
    this.macUTIs,
    this.webWildCards,
  }) : assert(
            !((extensions == null || extensions.isEmpty) &&
                (mimeTypes == null || mimeTypes.isEmpty) &&
                (macUTIs == null || macUTIs.isEmpty) &&
                (webWildCards == null || webWildCards.isEmpty)),
            "At least one type must be provided for an XTypeGroup.");

  /// The 'name' or reference to this group of types
  final String label;

  /// The extensions for this group
  final List<String> extensions;

  /// The MIME types for this group
  final List<String> mimeTypes;

  /// The UTIs for this group
  final List<String> macUTIs;

  /// The web wild cards for this group (ex: image/*, video/*)
  final List<String> webWildCards;
}
