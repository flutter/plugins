import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http show readBytes;
import 'package:meta/meta.dart';
import 'dart:html';

import './base.dart';

/// A XFile that works on web.
///
/// It wraps the bytes of a selected file.
class XFile extends XFileBase {
  String path;
  final Uint8List _data;
  final int _length;
  @override
  final String name;
  Element _target;

  /// Construct a XFile object from its ObjectUrl.
  ///
  /// Optionally, this can be initialized with `bytes` and `length`
  /// so no http requests are performed to retrieve files later.
  ///
  /// `name` needs to be passed from the outside, since we only have
  /// access to it while we create the ObjectUrl.
  XFile(
      this.path, {
        this.name,
        int length,
        Uint8List bytes,
      })  : _data = bytes,
        _length = length,
        super(path) {
    // Create a DOM container where we can host the anchor.
    _target = _ensureInitialized(this.name + '-x-file-dom-element');
  }

  /// Construct an XFile from its data
  XFile.fromData(
      Uint8List bytes, {
        this.name,
        int length,
      })  : _data = bytes,
        _length = length,
        super('') {
    Blob blob = Blob([bytes]);
    this.path = Url.createObjectUrl(blob);
    // Create a DOM container where we can host the anchor.
    _target = _ensureInitialized(this.name + '-x-file-dom-element');
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
  void saveTo(String path) {
    // Create an <a> tag with the appropriate download attributes and click it
    final AnchorElement element = createAnchorElement(this.path, this.name);

    _addElementToDomAndClick(element);
  }

  /// Create anchor element with download attribute
  @visibleForTesting
  AnchorElement createAnchorElement(String href, String suggestedName) {
    final element = AnchorElement(href: href);
    element.download = suggestedName;
    return element;
  }

  void _addElementToDomAndClick(Element element) {
    // Add the file input element and click it
    // All previous elements will be removed before adding the new one
    _target.children.clear();
    _target.children.add(element);
    element.click();
  }

  /// Initializes a DOM container where we can host elements.
  Element _ensureInitialized(String id) {
    var target = querySelector('#${id}');
    if (target == null) {
      final Element targetElement =
      Element.tag('flt-x-file-input')..id = id;

      querySelector('body').children.add(targetElement);
      target = targetElement;
    }
    return target;
  }
}