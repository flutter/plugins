import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http show readBytes;
import 'package:meta/meta.dart';
import 'dart:html';

import './base.dart';

import '../x_type/x_type.dart';

/// A XFile that works on web.
///
/// It wraps the bytes of a selected file.
class XFile extends XFileBase {
  String path;
  final XType type;

  final Uint8List _data;
  final int _length;
  final String name;
  final DateTime lastModified;
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
        this.type,
        this.name,
        int length,
        Uint8List bytes,
        this.lastModified,
        @visibleForTesting XFileTestOverrides overrides,
      })  : _data = bytes,
        _length = length,
        _overrides = overrides,
        super(path);

  /// Construct an XFile from its data
  XFile.fromData(
      Uint8List bytes, {
        this.type,
        this.name,
        int length,
        this.lastModified,
        @visibleForTesting XFileTestOverrides overrides,
      })  : _data = bytes,
        _length = length,
        _overrides = overrides,
        super('') {
    Blob blob;
    if (type == null) {
      blob = Blob([bytes]);
    } else {
      blob = Blob([bytes], type.mime);
    }
    this.path = Url.createObjectUrl(blob);
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
    _target = _ensureInitialized('__x_file_dom_element');

    // Create an <a> tag with the appropriate download attributes and click it
    final AnchorElement element = createAnchorElement(this.path, this.name);

    _addElementToDomAndClick(element);
  }

  /// Create anchor element with download attribute
  @visibleForTesting
  AnchorElement createAnchorElement(String href, String suggestedName) {
    if (_hasTestOverrides && _overrides.createAnchorElement != null) {
      return _overrides.createAnchorElement(href, suggestedName);
    }

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
      Element.tag('flt-x-file')..id = id;

      querySelector('body').children.add(targetElement);
      target = targetElement;
    }
    return target;
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