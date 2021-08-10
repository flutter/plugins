// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMediaStreamTrack extends Mock implements MediaStreamTrack {}

/// A fake [MediaError] that returns the provided error [_code].
class FakeMediaError extends Fake implements MediaError {
  FakeMediaError(this._code);

  final int _code;

  @override
  int get code => _code;
}
