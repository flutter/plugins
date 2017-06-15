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
  final double cellSize;
  Snake({this.rows = 20, this.columns = 20, this.cellSize = 10.0}) {
    assert(10 <= rows);
    assert(10 <= columns);
    assert(5.0 <= cellSize);
  }

  @override
  State<StatefulWidget> createState() =>
      new SnakeState(rows, columns, cellSize);
}

class SnakeBoardPainter extends CustomPainter {
  GameState state;
  double cellSize;

  SnakeBoardPainter(this.state, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint blackLine = new Paint()..color = Colors.black;
    final Paint blackFilled = new Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      new Rect.fromPoints(Offset.zero, size.bottomLeft(Offset.zero)),
      blackLine,
    );
    for (math.Point<int> p in state.body) {
      final Offset a = new Offset(cellSize * p.x, cellSize * p.y);
      final Offset b = new Offset(cellSize * (p.x + 1), cellSize * (p.y + 1));

      canvas.drawRect(new Rect.fromPoints(a, b), blackFilled);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SnakeState extends State<Snake> {
  double cellSize;
  GameState state;
  AccelerometerEvent acceleration;

  SnakeState(int rows, int columns, this.cellSize) {
    state = new GameState(rows, columns);
  }

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(painter: new SnakeBoardPainter(state, cellSize));
  }

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        acceleration = event;
      });
    });

    new Timer.periodic(const Duration(milliseconds: 200), (_) {
      setState(() {
        _step();
      });
    });
  }

  void _step() {
    final math.Point<int> newDirection = acceleration == null
        ? null
        : acceleration.x.abs() < 1.0 && acceleration.y.abs() < 1.0
            ? null
            : (acceleration.x.abs() < acceleration.y.abs())
                ? new math.Point<int>(0, acceleration.y.sign.toInt())
                : new math.Point<int>(-acceleration.x.sign.toInt(), 0);
    state.step(newDirection);
  }
}

class GameState {
  int rows;
  int columns;
  int snakeLength;
  GameState(this.rows, this.columns) {
    snakeLength = math.min(rows, columns) - 5;
  }

  List<math.Point<int>> body = <math.Point<int>>[const math.Point<int>(0, 0)];
  math.Point<int> direction = const math.Point<int>(1, 0);

  void step(math.Point<int> newDirection) {
    math.Point<int> next = body.last + direction;
    next = new math.Point<int>(next.x % columns, next.y % rows);

    body.add(next);
    if (body.length > snakeLength) body.removeAt(0);
    direction = newDirection ?? direction;
  }
}
