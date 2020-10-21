// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:test_core/src/runner/engine.dart';
import 'package:test_core/src/runner/reporter.dart';

import '../common.dart';
import 'constants.dart';

/// A reporter that plugs into [directRunTests] from `package:test_core`.
class ResultReporter implements Reporter {
  final Engine _engine;
  Completer<Map<String, Object>> _resultsCompleter;

  final _subscriptions = <StreamSubscription<Object>>{};

  /// When the [_engine] has completed execution of tests, [_resultsCompleter]
  /// will be completed with the test results.
  ResultReporter(this._engine, this._resultsCompleter) {
    _subscriptions.add(_engine.success.asStream().listen(_onDone));
  }

  void _onDone(bool _) async {
    _cancel();
    final Map<String, Object> results = {
      for (final liveTest in _engine.liveTests)
        liveTest.test.name: liveTest.state.result.name == success
            ? success
            : Failure(
                liveTest.test.name, liveTest.errors.first.stackTrace.toString(),
                error: liveTest.errors.first.error)
    };
    _resultsCompleter.complete(results);
  }

  void _cancel() {
    for (final StreamSubscription<Object> subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  @override
  void pause() {}
  @override
  void resume() {}
}
