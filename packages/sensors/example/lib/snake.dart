// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

class Snake extends StatefulWidget {
  Snake({this.rows = 20, this.columns = 20, this.cellSize = 10.0}) {
    assert(10 <= rows);
    assert(10 <= columns);
    assert(5.0 <= cellSize);
  }

  final int rows;
  final int columns;
  final double cellSize;

  @override
  State<StatefulWidget> createState() => SnakeState(rows, columns, cellSize);
}

class SnakeBoardPainter extends CustomPainter {
  SnakeBoardPainter(this.state, this.cellSize);

  GameState state;
  double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint blackLine = Paint()..color = Colors.black;
    final Paint blackFilled = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromPoints(Offset.zero, size.bottomLeft(Offset.zero)),
      blackLine,
    );
    for (math.Point<int> p in state.body) {
      final Offset a = Offset(cellSize * p.x, cellSize * p.y);
      final Offset b = Offset(cellSize * (p.x + 1), cellSize * (p.y + 1));

      canvas.drawRect(Rect.fromPoints(a, b), blackFilled);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class SnakeState extends State<Snake> {
  SnakeState(int rows, int columns, this.cellSize) {
    state = GameState(rows, columns);
  }

  double cellSize;
  GameState state;
  AccelerometerEvent acceleration;
  StreamSubscription<AccelerometerEvent> _streamSubscription;
  Timer _timer;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: SnakeBoardPainter(state, cellSize));
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _streamSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        acceleration = event;
      });
    });

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
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
                ? math.Point<int>(0, acceleration.y.sign.toInt())
                : math.Point<int>(-acceleration.x.sign.toInt(), 0);
    state.step(newDirection);
  }
}

class GameState {
  GameState(this.rows, this.columns) {
    snakeLength = math.min(rows, columns) - 5;
  }

  int rows;
  int columns;
  int snakeLength;

  List<math.Point<int>> body = <math.Point<int>>[const math.Point<int>(0, 0)];
  math.Point<int> direction = const math.Point<int>(1, 0);

  void step(math.Point<int> newDirection) {
    math.Point<int> next = body.last + direction;
    next = math.Point<int>(next.x % columns, next.y % rows);

    body.add(next);
    if (body.length > snakeLength) body.removeAt(0);
    direction = newDirection ?? direction;
  }
}
