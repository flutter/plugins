// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  dartTestOut: 'test/test_api.dart',
  cppOptions: CppOptions(namespace: 'file_selector_windows'),
  cppHeaderOut: 'windows/messages.g.h',
  cppSourceOut: 'windows/messages.g.cpp',
  copyrightHeader: 'pigeons/copyright.txt',
))
class TypeGroup {
  TypeGroup(this.label, {required this.extensions});

  String label;
  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The C++ code treats all of it as non-nullable.
  List<String?> extensions;
}

class SelectionOptions {
  SelectionOptions({
    this.allowMultiple = false,
    this.selectFolders = false,
    this.allowedTypes = const <TypeGroup?>[],
  });
  bool allowMultiple;
  bool selectFolders;

  // TODO(stuartmorgan): Make the generic type non-nullable once supported.
  // https://github.com/flutter/flutter/issues/97848
  // The C++ code treats the values as non-nullable.
  List<TypeGroup?> allowedTypes;
}

@HostApi(dartHostTestHandler: 'TestFileSelectorApi')
abstract class FileSelectorApi {
  List<String?> showOpenDialog(
    SelectionOptions options,
    String? initialDirectory,
    String? confirmButtonText,
  );
  List<String?> showSaveDialog(
    SelectionOptions options,
    String? initialDirectory,
    String? suggestedName,
    String? confirmButtonText,
  );
}
