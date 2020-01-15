// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library closed_caption_file;

import 'dart:convert';

/// A structured representation a parsed closed caption file.
///
/// A closed caption file includes a list of captions, each with a start and end
/// time for when the given closed caption should be displayed.
///
/// The [captions] are a list of all captions in a file.
class ClosedCaptionFile {
  /// The full list of captions read from the given file.
  final List<Caption> captions;

  /// Parses a string into a [ClosedCaptionFile], assuming [fileContents] is in
  /// the `.srt` file format.
  /// * See: https://en.wikipedia.org/wiki/SubRip
  ClosedCaptionFile.fromSrtFile(String fileContents)
      : captions = _parseCaptionsFromSrtString(fileContents);
}

/// A representation of a single caption.
///
/// A typical closed captioning file will include several [Caption]s, each
/// linked to a timestamp
class Caption {
  /// The number that this caption was assigned. \
  final int number;

  /// When in the given video should this [Caption] begin displaying.
  final Duration start;

  /// When in the given video should this [Caption] be dismissed.
  final Duration end;

  /// The actual text that should appear on screen to be read between [start]
  /// and [end].
  final String text;

  /// Creates a new [Caption] object.
  ///
  /// This is not recommended for direct use unless you are writing a parser for
  /// a new closed captioning file type.
  const Caption({this.number, this.start, this.end, this.text});
}

class _StartAndEnd {
  final Duration start;
  final Duration end;

  _StartAndEnd(this.start, this.end);

  // Assumes format from an SRT file.
  // For example:
  // 00:01:54,724 --> 00:01:56,760
  static _StartAndEnd fromSrtString(String line) {
    final times = line.split(' --> ');

    final start = _parseSrtTimestamp(times[0]);
    final end = _parseSrtTimestamp(times[1]);

    return _StartAndEnd(start, end);
  }
}

List<Caption> _parseCaptionsFromSrtString(String file) {
  final captions = <Caption>[];
  for (final captionLines in _readSrtFile(file)) {
    if (captionLines.length < 3) break;

    final captionNumber = int.parse(captionLines[0]);
    final startAndEnd = _StartAndEnd.fromSrtString(captionLines[1]);

    final text = captionLines.sublist(2).join('\n');

    final newCaption = Caption(
      number: captionNumber,
      start: startAndEnd.start,
      end: startAndEnd.end,
      text: text,
    );

    captions.add(newCaption);
  }

  return captions;
}

// Parses a time stamp in an SRT file into a Duration.
// For example:
//
// _parseSrtTimestamp('00:01:59,084')
// returns
// Duration(hours: 0, minutes: 1, seconds: 59, milliseconds: 084)
Duration _parseSrtTimestamp(String timestampString) {
  final commaSections = timestampString.split(',');
  final hoursMinutesSeconds = commaSections[0].split(':');

  final hours = int.parse(hoursMinutesSeconds[0]);
  final minutes = int.parse(hoursMinutesSeconds[1]);
  final seconds = int.parse(hoursMinutesSeconds[2]);
  final milliseconds = int.parse(commaSections[1]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

// Reads on SRT file and splits it into Lists of strings where each list is one
// caption.
List<List<String>> _readSrtFile(String file) {
  final lines = LineSplitter.split(file).toList();

  var captionStrings = <List<String>>[];
  var currentCaption = <String>[];
  var lineIndex = 0;
  for (final line in lines) {
    final isLineBlank = line.trim().isEmpty;
    if (!isLineBlank) {
      currentCaption.add(line);
    }

    if (isLineBlank || lineIndex == lines.length - 1) {
      captionStrings.add(currentCaption);
      currentCaption = <String>[];
    }

    lineIndex += 1;
  }

  return captionStrings;
}