// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library closed_caption_file;

import 'src/sub_rip.dart';

/// A structured representation of a parsed closed caption file.
///
/// A closed caption file includes a list of captions, each with a start and end
/// time for when the given closed caption should be displayed.
///
/// The [captions] are a list of all captions in a file, in the order that they
/// appeared in the file.
class ClosedCaptionFile {
  /// The full list of captions from a given file.
  final List<Caption> captions;

  /// Creates a dart representation of an entire file's worth of closed
  /// captioning.
  ///
  /// This constructor should only be used if you're writing a parser for a
  /// currently unsupported file type.
  ///
  /// Prefer using one of the convenience constructors, such as
  /// `ClosedCaptionFile.fromSubRipFile(...)`.
  const ClosedCaptionFile({this.captions = const <Caption>[]});

  /// Parses a string into a [ClosedCaptionFile], assuming [fileContents] is in
  /// the SubRip file format.
  /// * See: https://en.wikipedia.org/wiki/SubRip
  ClosedCaptionFile.fromSubRipFile(String fileContents)
      : captions = parseCaptionsFromSubRipString(fileContents);
}

/// A representation of a single caption.
///
/// A typical closed captioning file will include several [Caption]s, each
/// linked to a start and end time.
class Caption {
  /// Creates a new [Caption] object.
  ///
  /// This is not recommended for direct use unless you are writing a parser for
  /// a new closed captioning file type.
  const Caption({this.number, this.start, this.end, this.text});

  /// The number that this caption was assigned.
  final int number;

  /// When in the given video should this [Caption] begin displaying.
  final Duration start;

  /// When in the given video should this [Caption] be dismissed.
  final Duration end;

  /// The actual text that should appear on screen to be read between [start]
  /// and [end].
  final String text;
}
