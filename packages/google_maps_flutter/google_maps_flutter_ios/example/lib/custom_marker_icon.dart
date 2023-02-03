// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<ByteData> createCustomMarkerIconImage({required Size size}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);
  final _MarkerPainter painter = _MarkerPainter();

  painter.paint(canvas, size);

  final ui.Image image = await recorder
      .endRecording()
      .toImage(size.width.floor(), size.height.floor());

  final ByteData? bytes =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes!;
}

class _MarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const RadialGradient gradient = RadialGradient(
      colors: <Color>[Colors.yellow, Colors.red],
      stops: <double>[0.4, 1.0],
    );
    canvas.drawRect(
      rect,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) => false;
  @override
  bool shouldRebuildSemantics(_MarkerPainter oldDelegate) => false;
}
