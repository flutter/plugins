// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/src/closed_caption_file.dart';
import 'package:video_player/video_player.dart';

void main() {
  test('Parses VTT file', () {
    final WebVTTCaptionFile parsedFile = WebVTTCaptionFile(_validVTT);

    expect(parsedFile.captions.length, 13);

    final Caption firstCaption = parsedFile.captions.first;
    expect(firstCaption.number, 1);
    expect(firstCaption.start, Duration(seconds: 9));
    expect(firstCaption.end, Duration(seconds: 11, milliseconds: 430));
    expect(firstCaption.text, 'We are in New York City');

    final Caption secondCaption = parsedFile.captions[1];
    expect(secondCaption.number, 2);
    expect(
      secondCaption.start,
      Duration(minutes: 0, seconds: 13, milliseconds: 0),
    );
    expect(
      secondCaption.end,
      Duration(minutes: 0, seconds: 16, milliseconds: 0),
    );
    expect(secondCaption.text,
        "We're actually at the Lucern Hotel, just down the street");

    //With styles on timestamp
    final Caption lastCaption = parsedFile.captions[12];
    expect(lastCaption.number, 13);
    expect(
      lastCaption.start,
      Duration(minutes: 0, seconds: 35, milliseconds: 500),
    );
    expect(
      lastCaption.end,
      Duration(minutes: 0, seconds: 38, milliseconds: 0),
    );
    expect(lastCaption.text,
        "You know I'm so excited my glasses are falling off here.");
  });

  test('Parses VTT file with malformed input', () {
    final ClosedCaptionFile parsedFile = WebVTTCaptionFile(_malformedVTT);

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

00:09.000 --> 00:11.430
<v Roger Bingham>We are in New York City

00:13.000 --> 00:16.000
<v Roger Bingham>We're actually at the Lucern Hotel, just down the street

00:16.000 --> 00:18.000
<v Roger Bingham>from the American Museum of Natural History

00:18.000 --> 00:20.000
<v Roger Bingham>And with me is Neil deGrasse Tyson

00:20.000 --> 00:22.000
<v Roger Bingham>Astrophysicist, Director of the Hayden Planetarium

00:22.000 --> 00:24.000
<v Roger Bingham>at the AMNH.

00:24.000 --> 00:26.000
<v Roger Bingham>Thank you for walking down here.

00:27.000 --> 00:30.000
<v Roger Bingham>And I want to do a follow-up on the last conversation we did.

00:30.000 --> 00:31.500 align:end size:50%
<v Roger Bingham>When we e-mailed—

00:30.500 --> 00:32.500 align:start size:50%
<v Neil deGrasse Tyson>Didn't we talk about enough in that conversation?

00:32.000 --> 00:35.500 align:end size:50%
<v Roger Bingham>No! No no no no; 'cos 'cos obviously 'cos

00:32.500 --> 00:33.500 align:start size:50%
<v Neil deGrasse Tyson><i>Laughs</i>

00:35.500 --> 00:38.000 align:start size:50%
<v Roger Bingham>You know I'm so excited my glasses are falling off here.

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
