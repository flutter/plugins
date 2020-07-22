import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import './base.dart';

/// A XFile backed by a dart:io File.
class XFile extends XFileBase {
  final File _file;

  /// Construct a XFile object backed by a dart:io File.
  XFile(String path)
      : _file = File(path),
        super(path);

  @override
  String get path {
    return _file.path;
  }

  @override
  String get name {
    return _file.path.split(Platform.pathSeparator).last;
  }

  @override
  Future<int> length() {
    return _file.length();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    return _file.readAsString(encoding: encoding);
  }

  @override
  Future<Uint8List> readAsBytes() {
    return _file.readAsBytes();
  }

  @override
  Stream<Uint8List> openRead([int start, int end]) {
    return _file
        .openRead(start ?? 0, end)
        .map((chunk) => Uint8List.fromList(chunk));
  }
}
