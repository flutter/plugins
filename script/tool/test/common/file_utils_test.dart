// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:flutter_plugin_tools/src/common/file_utils.dart';
import 'package:test/test.dart';

void main() {
  test('works on Posix', () async {
    final FileSystem fileSystem =
        MemoryFileSystem();

    final Directory base = fileSystem.directory('/').childDirectory('base');
    final File file =
        childFileWithSubcomponents(base, <String>['foo', 'bar', 'baz.txt']);

    expect(file.absolute.path, '/base/foo/bar/baz.txt');
  });

  test('works on Windows', () async {
    final FileSystem fileSystem =
        MemoryFileSystem(style: FileSystemStyle.windows);

    final Directory base = fileSystem.directory(r'C:\').childDirectory('base');
    final File file =
        childFileWithSubcomponents(base, <String>['foo', 'bar', 'baz.txt']);

    expect(file.absolute.path, r'C:\base\foo\bar\baz.txt');
  });
}
