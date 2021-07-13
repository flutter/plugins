// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html';

import 'package:mocktail/mocktail.dart';

class MockWindow extends Mock implements Window {}

class MockNavigator extends Mock implements Navigator {}

class MockMediaDevices extends Mock implements MediaDevices {}

/// A fake [DomException] that returns the provided [errorName].
class FakeDomException extends Fake implements DomException {
  FakeDomException(this.errorName);

  final String errorName;

  @override
  String get name => errorName;
}
