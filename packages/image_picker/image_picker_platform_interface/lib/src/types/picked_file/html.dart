import 'dart:convert';
import 'dart:typed_data';

import './base.dart';

/// A PickedFile that works on web.
///
/// It wraps the bytes of a selected file.
class PickedFile extends PickedFileBase {
  final String path;
  final Uint8List _bytes;

  /// Construct a PickedFile object, from its `bytes`.
  PickedFile(this.path, {Uint8List bytes})
      : _bytes = bytes,
        super(path);

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    return encoding.decode(_bytes);
  }

  @override
  Uint8List readAsBytesSync() {
    return UnmodifiableUint8ListView(_bytes);
  }

  @override
  Stream<Uint8List> openRead([int start, int end]) {
    return Stream.fromIterable(
        [_bytes.sublist(start ?? 0, end ?? _bytes.length)]);
  }
}
