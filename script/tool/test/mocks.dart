// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:mockito/mockito.dart';

class MockProcess extends Mock implements io.Process {
  final Completer<int> exitCodeCompleter = Completer<int>();
  final StreamController<List<int>> stdoutController =
      StreamController<List<int>>();
  final StreamController<List<int>> stderrController =
      StreamController<List<int>>();
  final MockIOSink stdinMock = MockIOSink();

  @override
  Future<int> get exitCode => exitCodeCompleter.future;

  @override
  Stream<List<int>> get stdout => stdoutController.stream;

  @override
  Stream<List<int>> get stderr => stderrController.stream;

  @override
  IOSink get stdin => stdinMock;
}

class MockIOSink extends Mock implements IOSink {
  List<String> lines = <String>[];

  @override
  void writeln([Object obj = ""]) => lines.add(obj);
}
