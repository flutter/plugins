// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:html/dom.dart';

import 'closed_caption_file.dart';
import 'package:html/parser.dart' as html_parser;

/// Represents a [ClosedCaptionFile], parsed from the WebVtt file format.
/// See: https://en.wikipedia.org/wiki/WebVtt
class WebVttCaptionFile extends ClosedCaptionFile {
  /// Parses a string into a [ClosedCaptionFile], assuming [fileContents] is in
  /// the WebVtt file format.
  /// * See: https://en.wikipedia.org/wiki/WebVtt
  WebVttCaptionFile(this.fileContents) : _captions = _parseCaptionsFromWebVttString(fileContents);

  /// The entire body of the Vtt file.
  final String fileContents;

  @override
  List<Caption> get captions => _captions;

  final List<Caption> _captions;
}

List<Caption> _parseCaptionsFromWebVttString(String file) {
  final List<Caption> captions = <Caption>[];

  // Ignore metadata
  List<String> metadata = ['HEADER', 'NOTE', 'REGION', 'WEBVTT'];

  int captionNumber = 1;
  for (List<String> captionLines in _readWebVttFile(file)) {
    // CaptionLines represent a complete caption
    // E.g
    // [
    //  [00:00.000 --> 01:24.000 align:center]
    //  ['Introduction']
    // ]
    // if caption has just header or time, but no text, captionLines.length will be 1
    if (captionLines.length < 2) continue;

    // if caption has header equal metadata, ignore
    String metadaType = captionLines[0]?.split(' ')[0];
    if (metadata.contains(metadaType)) continue;

    // Caption has header
    bool hasHeader = captionLines.length > 2;
    if (hasHeader && int.tryParse(captionLines[0]) != null) {
      captionNumber = int.parse(captionLines[0]);
    }

    final _StartAndEnd startAndEnd = _StartAndEnd.fromWebVttString(
      hasHeader ? captionLines[1] : captionLines[0],
    );

    final String text = captionLines.sublist(hasHeader ? 2 : 1).join('\n');

    // TODO: Handle text formats
    // Some captions comes with anotations (information about who/how is the speech being delivered) and styles tags.
    // E.g:
    // <v.first.loud Neil deGrasse Tyson><i>Laughs</i>
    final String textWithoutFormat = _parseHtmlString(text);

    final Caption newCaption = Caption(
      number: captionNumber,
      start: startAndEnd.start,
      end: startAndEnd.end,
      text: textWithoutFormat,
    );

    if (newCaption.start != null && newCaption.end != null) {
      captions.add(newCaption);
      captionNumber++;
    }
  }

  return captions;
}

class _StartAndEnd {
  final Duration start;
  final Duration end;

  _StartAndEnd(this.start, this.end);

  // Assumes format from an Vtt file.
  // For example:
  // 00:09.000 --> 00:11.000
  static _StartAndEnd fromWebVttString(String line) {
    final RegExp format = RegExp(_webVttTimeStamp + _webVttArrow + _webVttTimeStamp);

    if (!format.hasMatch(line)) {
      return _StartAndEnd(null, null);
    }

    final List<String> times = line.split(_webVttArrow);

    final Duration start = _parseWebVttTimestamp(times[0]);
    final Duration end = _parseWebVttTimestamp(times[1]);

    return _StartAndEnd(start, end);
  }
}

String _parseHtmlString(String htmlString) {
  final Document document = html_parser.parse(htmlString);
  final String parsedString = html_parser.parse(document.body.text).documentElement.text;
  return parsedString;
}

// Parses a time stamp in an Vtt file into a Duration.
// For example:
//
// _parseWebVttimestamp('00:01:08.430')
// returns
// Duration(hours: 0, minutes: 1, seconds: 8, milliseconds: 430)
Duration _parseWebVttTimestamp(String timestampString) {
  if (!RegExp(_webVttTimeStamp).hasMatch(timestampString)) {
    return null;
  }

  final List<String> dotSections = timestampString.split('.');
  final List<String> hoursMinutesSeconds = dotSections[0].split(':');

  int hours = 0;
  int minutes = 0;
  int seconds = 0;

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

  // TODO: Handle styles
  // Some captions comes with styles about where/how the caption should be rendered.
  // E.g:
  // 00:32.500 --> 00:33.500 align:left size:50%
  // if (milisecondsStyles.length > 1) {
  //  List<String> styles = milisecondsStyles.sublist(1);
  // }
  int milliseconds = int.parse(milisecondsStyles[0]);

  return Duration(
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    milliseconds: milliseconds,
  );
}

// Reads on Vtt file and splits it into Lists of strings where each list is one
// caption.
List<List<String>> _readWebVttFile(String file) {
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

const String _webVttTimeStamp = r'(\d+):(\d{2})(:\d{2})?\.(\d{3})';
const String _webVttArrow = r' --> ';
