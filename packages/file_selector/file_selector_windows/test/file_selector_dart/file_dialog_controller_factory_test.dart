// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_windows/src/file_selector_dart/file_dialog_controller.dart';
import 'package:file_selector_windows/src/file_selector_dart/file_dialog_controller_factory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:win32/win32.dart';

import 'fake_file_dialog.dart';

void main() {
  final FileDialogControllerFactory fileDialogControllerFactory =
      FileDialogControllerFactory();
  final IFileDialog dialog = FakeIFileDialog();

  test('createController should return a FileDialogController', () {
    expect(
      fileDialogControllerFactory.createController(dialog),
      isA<FileDialogController>(),
    );
  });
}
