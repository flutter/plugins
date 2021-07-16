// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:mocktail/mocktail.dart';

class MockWindow extends Mock implements Window {}

class MockNavigator extends Mock implements Navigator {}

class MockMediaDevices extends Mock implements MediaDevices {}

class MockMediaStreamTrack extends Mock implements MediaStreamTrack {}

/// A fake [DomException] that returns the provided error [_name].
class FakeDomException extends Fake implements DomException {
  FakeDomException(this._name);

  final String _name;

  @override
  String get name => _name;
}
