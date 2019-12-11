import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart'
    show SynchronousFuture, describeIdentity;

/// Performs exactly like a [MemoryImage] but instead of taking in bytes it takes
/// in a future that represents bytes.
class FutureMemoryImage extends ImageProvider<FutureMemoryImage> {
  /// Constructor for FutureMemoryImage.  [_futureBytes] is the bytes that will
  /// be loaded into an image and [scale] is the scale that will be applied to
  /// that image to account for high-resolution images.
  const FutureMemoryImage(this._futureBytes, {this.scale = 1.0})
      : assert(_futureBytes != null),
        assert(scale != null);

  final Future<Uint8List> _futureBytes;

  /// The scale to place in the ImageInfo object of the image.
  final double scale;

  /// See [ImageProvider.obtainKey].
  @override
  Future<FutureMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FutureMemoryImage>(this);
  }

  /// See [ImageProvider.load].
  @override
  ImageStreamCompleter load(FutureMemoryImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
    );
  }

  Future<ui.Codec> _loadAsync(
      FutureMemoryImage key, DecoderCallback decode) async {
    assert(key == this);
    return _futureBytes.then((Uint8List bytes) {
      return decode(bytes);
    });
  }

  /// See [ImageProvider.operator==].
  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final FutureMemoryImage typedOther = other;
    return _futureBytes == typedOther._futureBytes && scale == typedOther.scale;
  }

  /// See [ImageProvider.hashCode].
  @override
  int get hashCode => hashValues(_futureBytes.hashCode, scale);

  /// See [ImageProvider.toString].
  @override
  String toString() =>
      '$runtimeType(${describeIdentity(_futureBytes)}, scale: $scale)';
}

/// Class to help loading of iOS platform images into Flutter.
///
/// For example, loading an image that is in `Assets.xcassts`.
class IosPlatformImages {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/ios_platform_images');

  /// Loads an image from asset catalogs.  The equivalent would be:
  /// `[UIImage imageNamed:name]`.
  ///
  /// Throws an exception if the image can't be found.
  ///
  /// See [https://developer.apple.com/documentation/uikit/uiimage/1624146-imagenamed?language=objc]
  static FutureMemoryImage load(String name) {
    return FutureMemoryImage(_channel.invokeMethod('loadImage', name));
  }

  /// Resolves an URL for a resource.  The equivalent would be:
  /// `[[NSBundle mainBundle] URLForResource:name withExtension:ext]`.
  ///
  /// Returns null if the resource can't be found.
  ///
  /// See [https://developer.apple.com/documentation/foundation/nsbundle/1411540-urlforresource?language=objc]
  static Future<String> resolveURL(String name, [String ext]) {
    return _channel.invokeMethod<String>('resolveURL', [name, ext]);
  }
}
