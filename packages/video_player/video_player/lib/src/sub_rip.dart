// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'closed_caption_file.dart';

/// Represents a [ClosedCaptionFile], parsed from the SubRip file format.
/// See: https://en.wikipedia.org/wiki/SubRip
class SubRipCaptionFile extends ClosedCaptionFile {
  /// Parses a string into a [ClosedCaptionFile], assuming [fileContents] is in
  /// the SubRip file format.
  /// * See: https://en.wikipedia.org/wiki/SubRip
  SubRipCaptionFile(this.fileContents)
      : _captions = _parseCaptionsFromSubRipString(fileContents);

  /// The entire body of the SubRip file.
  final String fileContents;

  @override
  List<Caption> get captions => _captions;

  final List<Caption> _captions;
}

List<Caption> _parseCaptionsFromSubRipString(String file) {
  final List<Caption> captions = <Caption>[];
  for (List<String> captionLines in _readSubRipFile(file)) {
    if (captionLines.length < 3) break;

    final int captionNumber = int.parse(captionLines[0]);
    final _StartAndEnd startAndEnd =
        _StartAndEnd.fromSubRipString(captionLines[1]);

    final String text = captionLines.sublist(2).join('\n');

    final Caption newCaption = Caption(
      number: captionNumber,
      start: startAndEnd.start,
      end: startAndEnd.end,
      text: text,
    );

    if (newCaption.start != null && newCaption.end != null) {
      captions.add(newCaption);
    }
  }

  return captions;
}

class _StartAndEnd {
  final Duration start;
  final Duration end;

  _StartAndEnd(this.start, this.end);

  // Assumes format from an SubRip file.
  // For example:
  // 00:01:54,724 --> 00:01:56,760
  static _StartAndEnd fromSubRipString(String line) {
    final RegExp format =
        RegExp(_subRipTimeStamp + _subRipArrow + _subRipTimeStamp);

    if (!format.hasMatch(line)) {
      return _StartAndEnd(null, null);
    }

    final List<String> times = line.split(_subRipArrow);

    final Duration start = _parseSubRipTimestamp(times[0]);
    final Duration end = _parseSubRipTimestamp(times[1]);

    return _StartAndEnd(start, end);
  }
}

// Parses a time stamp in an SubRip file into a Duration.
// For example:
//
// _parseSubRipTimestamp('00:01:59,084')
// returns
// Duration(hours: 0, minutes: 1, seconds: 59, milliseconds: 084)
Duration _parseSubRipTimestamp(String timestampString) {
  if (!RegExp(_subRipTimeStamp).hasMatch(timestampString)) {
    return null;
  }

  final List<String> commaSections = timestampString.split(',');
  final List<String> hoursMinutesSeconds = commaSections[0].split(':');

  final int hours = int.parse(hoursMinutesSeconds[0]);
  final int minutes = int.parse(hoursMinutesSeconds[1]);
  final int seconds = int.parse(hoursMinutesSeconds[2]);
  final int milliseconds = int.parse(commaSections[1]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

// Reads on SubRip file and splits it into Lists of strings where each list is one
// caption.
List<List<String>> _readSubRipFile(String file) {
  final List<String> lines = LineSplitter.split(file).toList();

  final List<List<String>> captionStrings = <List<String>>[];
  List<String> currentCaption = <String>[];
  int lineIndex = 0;
  for (final String line in lines) {
    final bool isLineBlank = line.trim().isEmpty;
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

const String _subRipTimeStamp = r'\d\d:\d\d:\d\d,\d\d\d';
const String _subRipArrow = r' --> ';
