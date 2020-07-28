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

/// A set of allowed file types.
class FileTypeFilterGroup {
  /// Creates a new group with the given label and file extensions.
  const FileTypeFilterGroup({this.label, this.fileExtensions});

  /// The label for the grouping. On platforms that support selectable groups,
  /// this will be visible to the user for selecting the group.
  final String label;

  /// A list of allowed file extensions. E.g., ['png', 'jpg', 'jpeg', 'gif'].
  ///
  /// A null or empty list indicates any type is allowed.
  final List<String> fileExtensions;
}
