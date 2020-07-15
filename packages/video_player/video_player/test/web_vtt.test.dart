// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/src/closed_caption_file.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('Parses VTT file', () {
    final WebVttCaptionFile parsedFile = WebVttCaptionFile(_validVTT);

    expect(parsedFile.captions.length, 7);

    //[minutes]:[seconds].[milliseconds]
    final Caption firstCaption = parsedFile.captions.first;
    expect(firstCaption.number, 1);
    expect(firstCaption.start, Duration(seconds: 1));
    expect(firstCaption.end, Duration(seconds: 2, milliseconds: 500));
    expect(firstCaption.text, 'We are in New York City');

    //With multiline
    final Caption secondCaption = parsedFile.captions[1];
    expect(secondCaption.number, 2);
    expect(
      secondCaption.start,
      Duration(minutes: 0, seconds: 2, milliseconds: 800),
    );
    expect(
      secondCaption.end,
      Duration(minutes: 0, seconds: 3, milliseconds: 283),
    );
    expect(secondCaption.text,
        "— It will perforate your stomach.\n— You could die.");

    //With Long Text
    final Caption thirdCaption = parsedFile.captions[2];
    expect(thirdCaption.number, 3);
    expect(
      thirdCaption.start,
      Duration(minutes: 0, seconds: 4, milliseconds: 0),
    );
    expect(
      thirdCaption.end,
      Duration(minutes: 0, seconds: 4, milliseconds: 900),
    );
    expect(thirdCaption.text,
        "The Organisation for Sample Public Service Announcements accepts no liability for the content of this advertisement, or for the consequences of any actions taken on the basis of the information provided.");

    //With styles on html style tags
    final Caption fourthCaption = parsedFile.captions[3];
    expect(fourthCaption.number, 4);
    expect(
      fourthCaption.start,
      Duration(minutes: 0, seconds: 5, milliseconds: 200),
    );
    expect(
      fourthCaption.end,
      Duration(minutes: 0, seconds: 6, milliseconds: 0),
    );
    expect(fourthCaption.text,
        "You know I'm so excited my glasses are falling off here.");

    //With format [hours]:[minutes]:[seconds].[milliseconds]
    final Caption fifthCaption = parsedFile.captions[4];
    expect(fifthCaption.number, 5);
    expect(
      fifthCaption.start,
      Duration(minutes: 0, seconds: 6, milliseconds: 050),
    );
    expect(
      fifthCaption.end,
      Duration(minutes: 0, seconds: 6, milliseconds: 150),
    );
    expect(fifthCaption.text, "I have a different time!");

    //With custom html tag
    final Caption sixthCaption = parsedFile.captions[5];
    expect(sixthCaption.number, 6);
    expect(
      sixthCaption.start,
      Duration(minutes: 0, seconds: 6, milliseconds: 200),
    );
    expect(
      sixthCaption.end,
      Duration(minutes: 0, seconds: 6, milliseconds: 900),
    );
    expect(sixthCaption.text, "This is yellow text on a blue background");

    //With format [hours]:[minutes].[milliseconds]
    final Caption lastCaption = parsedFile.captions[6];
    expect(lastCaption.number, 7);
    expect(
      lastCaption.start,
      Duration(hours: 60, minutes: 1, seconds: 0, milliseconds: 000),
    );
    expect(
      lastCaption.end,
      Duration(hours: 60, minutes: 1, seconds: 0, milliseconds: 900),
    );
    expect(lastCaption.text, "Hour");
  });

  test('Parses VTT file with malformed input', () {
    final ClosedCaptionFile parsedFile = WebVttCaptionFile(_malformedVTT);

    expect(parsedFile.captions.length, 1);

    final Caption firstCaption = parsedFile.captions.single;
    expect(firstCaption.number, 1);
    expect(firstCaption.start, Duration(seconds: 13));
    expect(firstCaption.end, Duration(seconds: 16, milliseconds: 0));
    expect(firstCaption.text, 'Valid');
  });
}

const String _validVTT = '''
WEBVTT Kind: captions; Language: en

REGION
id:bill
width:40%
lines:3
regionanchor:100%,100%
viewportanchor:90%,90%
scroll:up

NOTE
This file was written by Jill. I hope
you enjoy reading it. Some things to
bear in mind:
- I was lip-reading, so the cues may
not be 100% accurate
- I didn’t pay too close attention to
when the cues should start or end.

1
00:01.000 --> 00:02.500
<v Roger Bingham>We are in New York City

2
00:02.800 --> 00:03.283
— It will perforate your stomach.
— You could die.

00:04.000 --> 00:04.900
The Organisation for Sample Public Service Announcements accepts no liability for the content of this advertisement, or for the consequences of any actions taken on the basis of the information provided.

00:05.200 --> 00:06.000 align:start size:50%
<v Roger Bingham><i>You know I'm so excited my glasses are falling off here.</i>

00:00:06.050 --> 00:00:06.150 
<v Roger Bingham><i>I have a different time!</i>

00:06.200 --> 00:06.900
<c.yellow.bg_blue>This is yellow text on a blue background</c>

60:01.000 --> 60:01.900
Hour

''';

const String _malformedVTT = '''

WEBVTT Kind: captions; Language: en

00:09.000--> 00:11.430
<Test>This one should be ignored because the arrow needs a space.

00:13.000 --> 00:16.000
<Test>Valid

00:16.000 --> 00:8.000
<Test>This one should be ignored because the time is missing a digit.

''';
