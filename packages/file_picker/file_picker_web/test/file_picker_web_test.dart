// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@TestOn('chrome') // Uses web-only Flutter SDK

import 'dart:html' as html;
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker_web/file_picker_web.dart';
import 'package:mockito/mockito.dart';

import 'package:platform_detect/test_utils.dart' as platform;

class MockWindow extends Mock implements html.Window {}

void main() {
}