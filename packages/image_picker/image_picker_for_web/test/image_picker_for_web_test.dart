// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK

import 'dart:html' as html;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockWindow extends Mock implements html.Window {}

void main() {

}
