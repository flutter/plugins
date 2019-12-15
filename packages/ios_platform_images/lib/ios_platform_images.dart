import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart'
    show SynchronousFuture, describeIdentity;

class _FutureImageStreamCompleter extends ImageStreamCompleter {
  final Future<double> futureScale;
  final InformationCollector informationCollector;

  _FutureImageStreamCompleter(
      {Future<ui.Codec> codec, this.futureScale, this.informationCollector})
      : assert(codec != null),
        assert(futureScale != null) {
    codec.then<void>(_onCodecReady, onError: (dynamic error, StackTrace stack) {
      reportError(
        context: ErrorDescription('resolving a single-frame image stream'),
        exception: error,
        stack: stack,
        informationCollector: informationCollector,
        silent: true,
      );
    });
  }

  Future<void> _onCodecReady(ui.Codec codec) async {
    try {
      ui.FrameInfo nextFrame = await codec.getNextFrame();
      double scale = await futureScale;
      setImage(ImageInfo(image: nextFrame.image, scale: scale));
    } catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        informationCollector: this.informationCollector,
        silent: true,
      );
    }
  }
}

/// Performs exactly like a [MemoryImage] but instead of taking in bytes it takes
/// in a future that represents bytes.
class _FutureMemoryImage extends ImageProvider<_FutureMemoryImage> {
  /// Constructor for FutureMemoryImage.  [_futureBytes] is the bytes that will
  /// be loaded into an image and [_futureScale] is the scale that will be applied to
  /// that image to account for high-resolution images.
  const _FutureMemoryImage(this._futureBytes, this._futureScale)
      : assert(_futureBytes != null),
        assert(_futureScale != null);

  final Future<Uint8List> _futureBytes;
  final Future<double> _futureScale;

  /// See [ImageProvider.obtainKey].
  @override
  Future<_FutureMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FutureMemoryImage>(this);
  }

  /// See [ImageProvider.load].
  @override
  ImageStreamCompleter load(_FutureMemoryImage key, DecoderCallback decode) {
    return _FutureImageStreamCompleter(
      codec: _loadAsync(key, decode),
      futureScale: _futureScale,
    );
  }

  Future<ui.Codec> _loadAsync(
      _FutureMemoryImage key, DecoderCallback decode) async {
    assert(key == this);
    return _futureBytes.then((Uint8List bytes) {
      return decode(bytes);
    });
  }

  /// See [ImageProvider.operator==].
  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final _FutureMemoryImage typedOther = other;
    return _futureBytes == typedOther._futureBytes &&
        _futureScale == typedOther._futureScale;
  }

  /// See [ImageProvider.hashCode].
  @override
  int get hashCode => hashValues(_futureBytes.hashCode, _futureScale);

  /// See [ImageProvider.toString].
  @override
  String toString() =>
      '$runtimeType(${describeIdentity(_futureBytes)}, scale: $_futureScale)';
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
  static ImageProvider load(String name) {
    Future<Map> loadInfo = _channel.invokeMethod('loadImage', name);
    Completer<Uint8List> bytesCompleter = Completer<Uint8List>();
    Completer<double> scaleCompleter = Completer<double>();
    loadInfo.then((map) {
      scaleCompleter.complete(map["scale"]);
      bytesCompleter.complete(map["data"]);
    });
    return _FutureMemoryImage(bytesCompleter.future, scaleCompleter.future);
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
