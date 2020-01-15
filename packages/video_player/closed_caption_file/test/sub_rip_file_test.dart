// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:test/test.dart';

import 'package:closed_caption_file/closed_caption_file.dart';

void main() {
  test('Parses SubRip file', () {
    final file = File('test/data/sample_sub_rip_file.srt');
    final parsedFile =
        ClosedCaptionFile.fromSubRipFile(file.readAsStringSync());

    expect(parsedFile.captions.length, 4);

    final firstCaption = parsedFile.captions.first;
    expect(firstCaption.number, 1);
    expect(firstCaption.start, Duration(seconds: 6));
    expect(firstCaption.end, Duration(seconds: 12, milliseconds: 74));
    expect(firstCaption.text, 'This is a test file');

    final secondCaption = parsedFile.captions[1];
    expect(secondCaption.number, 2);
    expect(
      secondCaption.start,
      Duration(minutes: 1, seconds: 54, milliseconds: 724),
    );
    expect(
      secondCaption.end,
      Duration(minutes: 1, seconds: 56, milliseconds: 760),
    );
    expect(secondCaption.text, '- Hello.\n- Yes?');

    final thirdCaption = parsedFile.captions[2];
    expect(thirdCaption.number, 3);
    expect(
      thirdCaption.start,
      Duration(minutes: 1, seconds: 56, milliseconds: 884),
    );
    expect(
      thirdCaption.end,
      Duration(minutes: 1, seconds: 58, milliseconds: 954),
    );
    expect(
      thirdCaption.text,
      'These are more test lines\nYes, these are more test lines.',
    );

    final fourthCaption = parsedFile.captions[3];
    expect(fourthCaption.number, 4);
    expect(
      fourthCaption.start,
      Duration(hours: 1, minutes: 1, seconds: 59, milliseconds: 84),
    );
    expect(
      fourthCaption.end,
      Duration(hours: 1, minutes: 2, seconds: 1, milliseconds: 552),
    );
    expect(
      fourthCaption.text,
      '- [ Machinery Beeping ]\n- I\'m not sure what that was,',
    );
  });
}
