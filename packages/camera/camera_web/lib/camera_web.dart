import 'dart:html';
import 'dart:js_util' as js_util;

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:camera_web/media_track_capabilities.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web platform implementation of the camera_plugin.
class CameraPlugin extends CameraPlatform {
  /// Registers this class as the default instance of [CameraPlatform].
  static void registerWith(Registrar registrar) {
    CameraPlatform.instance = CameraPlugin();
  }

  static MediaTrackCapabilities? _getCapabilities(MediaStreamTrack track) {
    // In firefox 'getCapabilities' is not implemented.
    final p = js_util.getProperty(track, 'getCapabilities');
    if (p == null) {
      return null;
    }
    return MediaTrackCapabilities.fromObject(track.getCapabilities());
  }

  @override
  Future<List<CameraDescription>> availableCameras() async {
    if (window.navigator.mediaDevices == null) {
      throw CameraException('The MediaDevices API is not supported!',
          'No MediaDevice found, either the browser doesn\'t support it, or you are in an un-safe context.');
    }
    final perm = await window.navigator.permissions?.query({"name": "camera"});

    if (perm == null || perm.state == "denied") {
      throw CameraException('Missing permissions',
          'Permissions for the camera have not been obtained');
    }

    final mediaDevices =
        (await window.navigator.mediaDevices!.enumerateDevices())
            .cast<MediaDeviceInfo>();

    final videoDevices =
        mediaDevices.where((element) => element.kind == "videoinput");

    return Future.wait<CameraDescription>(videoDevices.map((e) async {
      final userMedia = await window.navigator.mediaDevices!.getUserMedia({
        'video': {
          'deviceId': {'exact': e.deviceId}
        },
        'audio': false
      });

      final track = userMedia.getVideoTracks().first;

      final settings = track.getSettings();
      var facingMode = settings['facingMode'];
      if (facingMode == null) {
        final capabilities = _getCapabilities(track)?.facingMode ?? const [];
        if (capabilities.isNotEmpty) {
          facingMode = capabilities.first;
        }
      }
      var direction = CameraLensDirection.external;
      if (facingMode != null) {
        if (facingMode == 'user') {
          direction = CameraLensDirection.front;
        } else if (facingMode == 'environment') {
          direction = CameraLensDirection.back;
        }
      }

      return CameraDescription(
        name: e.label ?? '',
        lensDirection: direction,
        sensorOrientation: 0,
      );
    }).toList());
  }
}
