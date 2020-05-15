import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import './base.dart';

/// A PickedFile backed by a dart:io File.
class PickedFile extends PickedFileBase {
  final File _file;

  /// Construct a PickedFile object backed by a dart:io File.
  PickedFile(String path)
      : _file = File(path),
        super(path);

  @override
  String get path {
    return _file.path;
  }

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    return _file.readAsStringSync(encoding: encoding);
  }

  @override
  Uint8List readAsBytesSync() {
    return _file.readAsBytesSync();
  }

  @override
  Stream<Uint8List> openRead([int start, int end]) {
    return _file.openRead(start ?? 0, end);
  }
}
