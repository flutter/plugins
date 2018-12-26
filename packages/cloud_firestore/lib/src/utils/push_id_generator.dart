// Copyright 2017, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math';

/// Utility class for generating Firebase child node keys.
///
/// Since the Flutter plugin API is asynchronous, there's no way for us
/// to use the native SDK to generate the node key synchronously and we
/// have to do it ourselves if we want to be able to reference the
/// newly-created node synchronously.
///
/// This code is based on a Firebase blog post and ported to Dart.
/// https://firebase.googleblog.com/2015/02/the-2120-ways-to-ensure-unique_68.html
class PushIdGenerator {
  static const String PUSH_CHARS =
      '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';

  static final Random _random = Random();

  static int _lastPushTime;

  static final List<int> _lastRandChars = List<int>(12);

  static String generatePushChildName() {
    int now = DateTime.now().millisecondsSinceEpoch;
    final bool duplicateTime = (now == _lastPushTime);
    _lastPushTime = now;

    final List<String> timeStampChars = List<String>(8);
    for (int i = 7; i >= 0; i--) {
      timeStampChars[i] = PUSH_CHARS[now % 64];
      now = (now / 64).floor();
    }
    assert(now == 0);

    final StringBuffer result = StringBuffer(timeStampChars.join());

    if (!duplicateTime) {
      for (int i = 0; i < 12; i++) {
        _lastRandChars[i] = _random.nextInt(64);
      }
    } else {
      _incrementArray();
    }
    for (int i = 0; i < 12; i++) {
      result.write(PUSH_CHARS[_lastRandChars[i]]);
    }
    assert(result.length == 20);
    return result.toString();
  }

  static void _incrementArray() {
    for (int i = 11; i >= 0; i--) {
      if (_lastRandChars[i] != 63) {
        _lastRandChars[i] = _lastRandChars[i] + 1;
        return;
      }
      _lastRandChars[i] = 0;
    }
  }
}
