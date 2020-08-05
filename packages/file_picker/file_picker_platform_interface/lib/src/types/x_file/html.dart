import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http show readBytes;

import './base.dart';

import '../types.dart';

/// A XFile that works on web.
///
/// It wraps the bytes of a selected file.
class XFile extends XFileBase {
  final String path; // TODO: get rid of this guy
  final XPath xPath;
  final Uint8List _initBytes;
  final int _length;
  @override
  final String name;

  /// Construct a XFile object from its ObjectUrl.
  ///
  /// Optionally, this can be initialized with `bytes` and `length`
  /// so no http requests are performed to retrieve files later.
  ///
  /// `name` needs to be passed from the outside, since we only have
  /// access to it while we create the ObjectUrl.
  // TODO: Replace this constructor
  XFile(
    this.path, {
    this.name,
    int length,
    Uint8List bytes,
    this.xPath ,
  })  : _initBytes = bytes,
        _length = length,
        super(path);

  /// Constructor from XPath
  XFile.fromXPath(
      this.xPath, {
      int length,
      Uint8List bytes,
  })  : _initBytes = bytes,
        _length = length,
        path = xPath.path, // TODO: just replace path everywhere
        name = xPath.name,
        super(xPath.path);

  Future<Uint8List> get _bytes async {
    if (_initBytes != null) {
      return Future.value(UnmodifiableUint8ListView(_initBytes));
    }
    return http.readBytes(path);
  }

  @override
  Future<int> length() async {
    return _length ?? (await _bytes).length;
  }

  @override
  Future<String> readAsString({Encoding encoding = utf8}) async {
    return encoding.decode(await _bytes);
  }

  @override
  Future<Uint8List> readAsBytes() async {
    return Future.value(await _bytes);
  }

  @override
  Stream<Uint8List> openRead([int start, int end]) async* {
    final bytes = await _bytes;
    yield bytes.sublist(start ?? 0, end ?? bytes.length);
  }
}
