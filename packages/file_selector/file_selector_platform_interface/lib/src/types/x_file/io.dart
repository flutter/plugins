import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import './base.dart';

import '../types.dart';

/// A XFile backed by a dart:io File.
class XFile extends XFileBase {
  final File _file;
  int _length;

  final Uint8List _data;

  final XType type;

  /// Construct a XFile object backed by a dart:io File.
  XFile(String path, { this.type })
      : _file = File(path),
        _data = null,
        super(path);

  /// Construct an XFile from its data
  XFile.fromData(Uint8List data, {
      this.type,
      String path,
      String name,
      int length,
    }): _data = data,
        _file = File(path),
        _length = length,
        super(path) {
    if (length == null) {
      _length = data.length;
    }
  }

  @override
  void saveTo(String path) async {
    File fileToSave = File(path);
    await fileToSave.writeAsBytes(_data);
    await fileToSave.create();
  }

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
    if (_length != null) {
      return Future.value(_length);
    }
    return _file.length();
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) {
    if (_data != null) {
      return Future.value(String.fromCharCodes(_data));
    }
    return _file.readAsString(encoding: encoding);
  }

  @override
  Future<Uint8List> readAsBytes() {
    if (_data != null) {
      return Future.value(_data);
    }
    return _file.readAsBytes();
  }

  @override
  Stream<Uint8List> openRead([int start, int end]) async* {
    if (_data != null) {
      final bytes = _data;
      yield bytes.sublist(start ?? 0, end ?? bytes.length);
    }
    yield* _file
        .openRead(start ?? 0, end)
        .map((chunk) => Uint8List.fromList(chunk));
  }
}
