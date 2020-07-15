// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'closed_caption_file.dart';
import 'package:html/parser.dart';

/// Represents a [ClosedCaptionFile], parsed from the WebVTT file format.
/// See: https://en.wikipedia.org/wiki/WebVTT
class WebVTTCaptionFile extends ClosedCaptionFile {
  /// Parses a string into a [ClosedCaptionFile], assuming [fileContents] is in
  /// the WebVTT file format.
  /// * See: https://en.wikipedia.org/wiki/WebVTT
  WebVTTCaptionFile(this.fileContents)
      : _captions = _parseCaptionsFromWebVTTString(fileContents);

  /// The entire body of the VTT file.
  final String fileContents;

  @override
  List<Caption> get captions => _captions;

  final List<Caption> _captions;
}

List<Caption> _parseCaptionsFromWebVTTString(String file) {
  final List<Caption> captions = <Caption>[];
  int number = 1;
  for (List<String> captionLines in _readWebVTTFile(file)) {
    if (captionLines.length < 2) continue;
    print(captionLines);

    final int captionNumber = number;
    final _StartAndEnd startAndEnd =
        _StartAndEnd.fromWebVTTString(captionLines[0]);

    final String text = captionLines.sublist(1).join('\n');

    //TODO: Handle text format
    final String textWithoutFormat = _parseHtmlString(text);

    final Caption newCaption = Caption(
      number: captionNumber,
      start: startAndEnd.start,
      end: startAndEnd.end,
      text: textWithoutFormat,
    );

    if (newCaption.start != null && newCaption.end != null) {
      captions.add(newCaption);
      number++;
    }
  }

  return captions;
}

class _StartAndEnd {
  final Duration start;
  final Duration end;

  _StartAndEnd(this.start, this.end);

  // Assumes format from an VTT file.
  // For example:
  // 00:09.000 --> 00:11.000
  static _StartAndEnd fromWebVTTString(String line) {
    final RegExp format =
        RegExp(_webVTTTimeStamp + _webVTTArrow + _webVTTTimeStamp);

    if (!format.hasMatch(line)) {
      return _StartAndEnd(null, null);
    }

    final List<String> times = line.split(_webVTTArrow);

    final Duration start = _parseWebVTTTimestamp(times[0]);
    final Duration end = _parseWebVTTTimestamp(times[1]);

    return _StartAndEnd(start, end);
  }
}

String _parseHtmlString(String htmlString) {
  var document = parse(htmlString);
  String parsedString = parse(document.body.text).documentElement.text;
  return parsedString;
}

// Parses a time stamp in an VTT file into a Duration.
// For example:
//
// _parseWebVTTimestamp('00:01:08.430')
// returns
// Duration(hours: 0, minutes: 1, seconds: 8, milliseconds: 430)
Duration _parseWebVTTTimestamp(String timestampString) {
  if (!RegExp(_webVTTTimeStamp).hasMatch(timestampString)) {
    return null;
  }

  final List<String> dotSections = timestampString.split('.');
  final List<String> hoursMinutesSeconds = dotSections[0].split(':');

  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  List<String> styles;

  if (hoursMinutesSeconds.length > 2) {
    // Timestamp takes the form of [hours]:[minutes]:[seconds].[milliseconds]
    hours = int.parse(hoursMinutesSeconds[0]);
    minutes = int.parse(hoursMinutesSeconds[1]);
    seconds = int.parse(hoursMinutesSeconds[2]);
  } else if (int.parse(hoursMinutesSeconds[0]) > 59) {
    // Timestamp takes the form of [hours]:[minutes].[milliseconds]
    // First position is hours as it's over 59.
    hours = int.parse(hoursMinutesSeconds[0]);
    minutes = int.parse(hoursMinutesSeconds[1]);
  } else {
    // Timestamp takes the form of [minutes]:[seconds].[milliseconds]
    minutes = int.parse(hoursMinutesSeconds[0]);
    seconds = int.parse(hoursMinutesSeconds[1]);
  }

  List<String> milisecondsStyles = dotSections[1].split(" ");
  //TODO: Handle styles data on timestamp
  if (milisecondsStyles.length > 1) {
    styles = milisecondsStyles.sublist(1);
  }
  int milliseconds = int.parse(milisecondsStyles[0]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

// Reads on VTT file and splits it into Lists of strings where each list is one
// caption.
List<List<String>> _readWebVTTFile(String file) {
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

const String _webVTTTimeStamp = r'(\d+):(\d{2})(:\d{2})?\.(\d{3})';
const String _webVTTArrow = r' --> ';
