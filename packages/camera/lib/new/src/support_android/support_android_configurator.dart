import 'dart:async';

import '../common/camera_interface.dart';
import '../common/native_texture.dart';
import 'camera.dart';
import 'camera_info.dart';

/// Default [CameraConfigurator] for [CameraApi.supportAndroid].
class SupportAndroidConfigurator implements CameraConfigurator {
  SupportAndroidConfigurator(this.info) : assert(info != null);

  NativeTexture _texture;
  Camera _camera;
  bool _isDisposed = false;

  final CameraInfo info;

  Camera get camera => _camera;

  @override
  Future<int> addPreviewTexture() {
    assert(!_isDisposed);

    final Completer<int> completer = Completer<int>();

    if (_texture == null) {
      NativeTexture.allocate().then((NativeTexture texture) {
        _texture = texture;
        _camera.previewTexture = _texture;
        completer.complete(_texture.textureId);
      });

      return completer.future;
    } else {
      return Future<int>.value(_texture.textureId);
    }
  }

  @override
  Future<void> dispose() {
    _isDisposed = true;

    final Completer<void> completer = Completer<void>();

    _camera
        .release()
        .then((_) => _texture?.release())
        .then((_) => completer.complete());

    return completer.future;
  }

  @override
  int get previewTextureId => _texture?.textureId;

  @override
  Future<void> start() {
    assert(!_isDisposed);
    return _camera.startPreview();
  }

  @override
  Future<void> stop() {
    assert(!_isDisposed);
    return _camera.stopPreview();
  }

  @override
  // ignore: missing_return
  Future<void> initialize() {
    assert(!_isDisposed);
    _camera = Camera.open(info.id);
  }
}
