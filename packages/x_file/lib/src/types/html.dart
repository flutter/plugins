import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http show readBytes;
import 'package:meta/meta.dart';
import 'dart:html';

import '../web_helpers/web_helpers.dart';
import './base.dart';

/// A XFile that works on web.
///
/// It wraps the bytes of a selected file.
class XFile extends XFileBase {
  String path;

  final String mimeType;
  final Uint8List _data;
  final int _length;
  final String name;
  final DateTime _lastModified;
  Element _target;

  final XFileTestOverrides _overrides;

  bool get _hasTestOverrides => _overrides != null;

  /// Construct a XFile object from its ObjectUrl.
  ///
  /// Optionally, this can be initialized with `bytes` and `length`
  /// so no http requests are performed to retrieve files later.
  ///
  /// `name` needs to be passed from the outside, since we only have
  /// access to it while we create the ObjectUrl.
  XFile(
    this.path, {
    this.mimeType,
    this.name,
    int length,
    Uint8List bytes,
    DateTime lastModified,
    @visibleForTesting XFileTestOverrides overrides,
  })  : _data = bytes,
        _length = length,
        _overrides = overrides,
        _lastModified = lastModified,
        super(path);

  /// Construct an XFile from its data
  XFile.fromData(
    Uint8List bytes, {
    this.mimeType,
    this.name,
    int length,
    DateTime lastModified,
    this.path,
    @visibleForTesting XFileTestOverrides overrides,
  })  : _data = bytes,
        _length = length,
        _overrides = overrides,
        _lastModified = lastModified,
        super(path) {
    if (path == null) {
      final blob = (mimeType == null) ? Blob([bytes]) : Blob([bytes], mimeType);
      this.path = Url.createObjectUrl(blob);
    }
  }

  @override
  Future<DateTime> lastModified() async {
    if (_lastModified != null) {
      return Future.value(_lastModified);
    }
    return null;
  }

  Future<Uint8List> get _bytes async {
    if (_data != null) {
      return Future.value(UnmodifiableUint8ListView(_data));
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

  /// Saves the data of this XFile at the location indicated by path.
  /// For the web implementation, the path variable is ignored.
  void saveTo(String path) async {
    // Create a DOM container where we can host the anchor.
    _target = ensureInitialized('__x_file_dom_element');

    // Create an <a> tag with the appropriate download attributes and click it
    // May be overridden with XFileTestOverrides
    final AnchorElement element =
        (_hasTestOverrides && _overrides.createAnchorElement != null)
            ? _overrides.createAnchorElement(this.path, this.name)
            : createAnchorElement(this.path, this.name);

    // Clear the children in our container so we can add an element to click
    _target.children.clear();
    addElementToContainerAndClick(_target, element);
  }
}

/// Overrides some functions to allow testing
@visibleForTesting
class XFileTestOverrides {
  /// For overriding the creation of the file input element.
  Element Function(String href, String suggestedName) createAnchorElement;

  /// Default constructor for overrides
  XFileTestOverrides({this.createAnchorElement});
}
