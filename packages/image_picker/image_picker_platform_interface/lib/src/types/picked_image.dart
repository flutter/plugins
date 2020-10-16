import 'dart:convert';

import 'dart:typed_data';

import 'picked_file/picked_file.dart';

/// A PickedImage is a [PickedFile] with an optional [thumbnail] variable for
/// a small sized thumbnail image file.
class PickedImage implements PickedFile {
  /// Small sized thumbnail image file
  final PickedFile thumbnail;
  final PickedFile _image;

  /// Constructs a PickedImage object from the imagePath with optionally the
  /// path to a thumbnail file.
  PickedImage(String imagePath, {String thumbnailPath})
      : thumbnail = thumbnailPath != null ? PickedFile(thumbnailPath) : null,
        _image = PickedFile(imagePath);

  /// Constructs a PickedImage object from a PickedFile object. A thumbnail
  /// file is optional.
  PickedImage.fromFile(PickedFile image, {this.thumbnail})
      : assert(image != null),
        _image = image;

  @override
  Stream<Uint8List> openRead([int start, int end]) =>
      _image.openRead(start, end);

  @override
  String get path => _image.path;

  @override
  Future<Uint8List> readAsBytes() => _image.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _image.readAsString(encoding: encoding);
}
