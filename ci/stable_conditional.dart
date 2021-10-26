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
//     // FLUTTER_STABLE_CONDITIONAL_IF_NOT_STABLE
//     printf("hello world\n");
//     // FLUTTER_STABLE_CONDITIONAL_ELSE
//     // printf("goodbye world\n");
//     // FLUTTER_STABLE_CONDITIONAL_ENDIF
//   }
//
// Example output:
//   int main() {
//     printf("goodbye world\n");
//   }

import 'dart:convert' show LineSplitter;
import 'dart:io' show FileSystemEntity, File;

final List<String> _filesToProcess = <String>[
  'packages/android_intent/android/src/test/java/io/flutter/plugins/androidintent/MethodCallHandlerImplTest.java',
  'packages/camera/camera/android/src/test/java/io/flutter/plugins/camera/DartMessengerTest.java',
  'packages/quick_actions/quick_actions/android/src/test/java/io/flutter/plugins/quickactions/QuickActionsTest.java',
  'packages/url_launcher/url_launcher/android/src/test/java/io/flutter/plugins/urllauncher/MethodCallHandlerImplTest.java',
];

final RegExp _replacer = RegExp(
    r'^\s*// FLUTTER_STABLE_CONDITIONAL_IF_NOT_STABLE(.*?)^\s*// FLUTTER_STABLE_CONDITIONAL_ELSE(.*?)^\s*// FLUTTER_STABLE_CONDITIONAL_ENDIF',
    multiLine: true,
    dotAll: true);
final RegExp _commentRemover = RegExp(r'^(\s*)\/\/\s*(.*)');
const String _newline = '\n';

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
  _filesToProcess.map((String path) => File(path)).forEach(_process);
}
