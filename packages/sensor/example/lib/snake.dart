// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensor/sensor.dart';

class Snake extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new SnakeState();
}

class SnakeBoardPainter extends CustomPainter {
  GameState state;

  SnakeBoardPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    Paint blackLine = new Paint()..color = Colors.black;
    Paint blackFilled = new Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        new Rect.fromPoints(Offset.zero, size.bottomLeft(Offset.zero)),
        blackLine);
    for (math.Point<int> p in state.body) {
      Offset a = new Offset(10.0 * p.x, 10.0 * p.y);
      Offset b = new Offset(10.0 * (p.x + 1), 10.0 * (p.y + 1));

      canvas.drawRect(new Rect.fromPoints(a, b), blackFilled);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SnakeState extends State<Snake> {
  GameState state = new GameState();
  List<double> accelerometerValues;
  @override
  Widget build(BuildContext context) {
    return new CustomPaint(painter: new SnakeBoardPainter(state));
  }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((List<double> event) {
      setState(() {
        accelerometerValues = event;
      });
    });

    new Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _step();
      });
    });
  }

  void _step() {
    math.Point<int> newDirection = accelerometerValues == null
        ? null
        : accelerometerValues[0].abs() < 1.0 &&
                accelerometerValues[1].abs() < 1.0
            ? null
            : (accelerometerValues[0].abs() < accelerometerValues[1].abs())
                ? new math.Point<int>(0, accelerometerValues[1].sign.toInt())
                : new math.Point<int>(-accelerometerValues[0].sign.toInt(), 0);
    state.step(newDirection);
  }
}

class GameState {
  List<math.Point<int>> body = <math.Point<int>>[new math.Point<int>(0, 0)];
  math.Point<int> direction = new math.Point<int>(1, 0);

  void step(math.Point<int> newDirection) {
    math.Point<int> next = body.last + direction;
    next = new math.Point<int>(next.x % 20, next.y % 20);

    body.add(next);
    if (body.length > 15) body.removeAt(0);
    direction = newDirection ?? direction;
  }
}
