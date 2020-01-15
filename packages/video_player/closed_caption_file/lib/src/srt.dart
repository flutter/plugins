// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import '../closed_caption_file.dart';

List<Caption> parseCaptionsFromSrtString(String file) {
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
