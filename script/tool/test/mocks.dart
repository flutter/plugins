// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:file/file.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';

class MockPlatform extends Mock implements Platform {
  MockPlatform({
    this.isLinux = false,
    this.isMacOS = false,
    this.isWindows = false,
  });

  @override
  bool isLinux;

  @override
  bool isMacOS;

  @override
  bool isWindows;

  @override
  Uri get script => isWindows
      ? Uri.file(r'C:\foo\bar', windows: true)
      : Uri.file('/foo/bar', windows: false);

  @override
  Map<String, String> environment = <String, String>{};
}

class MockProcess extends Mock implements io.Process {
  /// Creates a mock process with the given results.
  ///
  /// The default encodings match the ProcessRunner defaults; mocks for
  /// processes run with a different encoding will need to be created with
  /// the matching encoding.
  MockProcess({
    int exitCode = 0,
    String? stdout,
    String? stderr,
    Encoding stdoutEncoding = io.systemEncoding,
    Encoding stderrEncoding = io.systemEncoding,
  }) : _exitCode = exitCode {
    if (stdout != null) {
      _stdoutController.add(stdoutEncoding.encoder.convert(stdout));
    }
    if (stderr != null) {
      _stderrController.add(stderrEncoding.encoder.convert(stderr));
    }
    _stdoutController.close();
    _stderrController.close();
  }

  final int _exitCode;
  final StreamController<List<int>> _stdoutController =
      StreamController<List<int>>();
  final StreamController<List<int>> _stderrController =
      StreamController<List<int>>();
  final MockIOSink stdinMock = MockIOSink();

  @override
  int get pid => 99;

  @override
  Future<int> get exitCode async => _exitCode;

  @override
  Stream<List<int>> get stdout => _stdoutController.stream;

  @override
  Stream<List<int>> get stderr => _stderrController.stream;

  @override
  IOSink get stdin => stdinMock;
}

class MockIOSink extends Mock implements IOSink {
  List<String> lines = <String>[];

  @override
  void writeln([Object? obj = '']) => lines.add(obj.toString());
}
