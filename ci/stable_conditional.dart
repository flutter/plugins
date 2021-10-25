// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// stable_conditional.dart
//
// Performs simple find and replace operations for conditional compilation
// before executing stable channel tests.
//
// Example input:
//   int main() {
//     // FLUTTER_STABLE_CHANNEL_BEGIN
//     printf("hello world\n");
//     // FLUTTER_STABLE_CHANNEL_REPLACE
//     // printf("goodbye world\n");
//     // FLUTTER_STABLE_CHANNEL_END
//   }
//
// Example output:
//   int main() {
//     printf("goodbye world\n");
//   }

import 'dart:convert' show LineSplitter;
import 'dart:io' show Directory, FileSystemEntity, File;

final RegExp _isSourceRegex =
    RegExp(r'\.cc$|\.java$|\.m$\.h$|\.c$|\.swift$|\.kt$');
final RegExp _replacer = RegExp(
    r'^\s*// FLUTTER_STABLE_CHANNEL_BEGIN(.*?)^\s*// FLUTTER_STABLE_CHANNEL_REPLACE(.*?)^\s*// FLUTTER_STABLE_CHANNEL_END',
    multiLine: true,
    dotAll: true);
final RegExp _commentRemover = RegExp(r'^(\s*)\/+\s*(.*)');
const String _newline = '\n';

bool _isSourceFile(FileSystemEntity entity) =>
    _isSourceRegex.hasMatch(entity.path);

void _process(FileSystemEntity entity) {
  const LineSplitter splitter = LineSplitter();
  final String text = File(entity.path).readAsStringSync();
  String replaced = '';
  int index = 0;
  for (final RegExpMatch match in _replacer.allMatches(text)) {
    replaced += text.substring(index, match.start);
    for (final String line in splitter.convert(match.group(2)!)) {
      final RegExpMatch? commentRemoverMatch = _commentRemover.firstMatch(line);
      if (commentRemoverMatch != null) {
        replaced += commentRemoverMatch.group(1)! +
            commentRemoverMatch.group(2)! +
            _newline;
      }
    }
    index = match.end;
  }
  if (replaced.isNotEmpty) {
    replaced += text.substring(index, text.length);
    File(entity.path).writeAsStringSync(replaced);
    print('modified: ${entity.path}');
  }
}

void main(List<String> args) {
  final String channel = args[0];
  if (channel == 'stable') {
    final Directory dir = Directory('.');
    dir.list(recursive: true).where(_isSourceFile).forEach(_process);
  }
}
