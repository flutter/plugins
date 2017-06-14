// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class Snake extends StatefulWidget {
  final int rows;
  final int columns;
  final double offsetSize;
  Snake({this.rows = 20, this.columns = 20, this.offsetSize = 10.0});

  @override
  State<StatefulWidget> createState() =>
      new SnakeState(rows, columns, offsetSize);
}

class SnakeBoardPainter extends CustomPainter {
  GameState state;
  double offsetSize;

  SnakeBoardPainter(this.state, this.offsetSize);

  @override
  void paint(Canvas canvas, Size size) {
    final blackLine = new Paint()..color = Colors.black;
    final blackFilled = new Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
        new Rect.fromPoints(Offset.zero, size.bottomLeft(Offset.zero)),
        blackLine);
    for (math.Point<int> p in state.body) {
      final a = new Offset(offsetSize * p.x, offsetSize * p.y);
      final b = new Offset(offsetSize * (p.x + 1), offsetSize * (p.y + 1));

      canvas.drawRect(new Rect.fromPoints(a, b), blackFilled);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SnakeState extends State<Snake> {
  double offsetSize;
  GameState state;
  List<double> accelerometerValues;

  SnakeState(int rows, int columns, this.offsetSize) {
    state = new GameState(rows, columns);
  }

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(painter: new SnakeBoardPainter(state, offsetSize));
  }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        accelerometerValues = [event.x, event.y, event.z];
      });
    });

    new Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _step();
      });
    });
  }

  void _step() {
    final math.Point<int> newDirection = accelerometerValues == null
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
  int rows;
  int columns;
  int snakeLength;
  GameState(this.rows, this.columns) {
    snakeLength = math.max(rows, columns) - 5;
  }

  var body = <math.Point<int>>[const math.Point<int>(0, 0)];
  var direction = const math.Point<int>(1, 0);

  void step(math.Point<int> newDirection) {
    var next = body.last + direction;
    next = new math.Point<int>(next.x % columns, next.y % rows);

    body.add(next);
    if (body.length > snakeLength)
      body.removeAt(0);
    direction = newDirection ?? direction;
  }
}
