import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share_platform_interface/share_platform_interface.dart';
import 'package:mime/mime.dart';

const MethodChannel _channel = MethodChannel('plugins.flutter.io/share');

/// An implementation of [UrlLauncherPlatform] that uses method channels.
class MethodChannelShare extends SharePlatform {
  @override
  Future<void> share(
    String text, {
    @required String subject,
    @required Rect sharePositionOrigin,
  }) {
    final Map<String, dynamic> params = <String, dynamic>{
      'text': text,
      'subject': subject,
    };

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return _channel.invokeMethod(
      'share',
      params,
    );
  }

  @override
  Future<bool> shareFiles(
    List<String> paths, {
    @required List<String> mimeTypes,
    @required String subject,
    @required String text,
    @required Rect sharePositionOrigin,
  }) {
    final Map<String, dynamic> params = <String, dynamic>{
      'paths': paths,
      'mimeTypes': mimeTypes ??
          paths.map((String path) => _mimeTypeForPath(path)).toList(),
    };

    if (subject != null) params['subject'] = subject;
    if (text != null) params['text'] = text;

    if (sharePositionOrigin != null) {
      params['originX'] = sharePositionOrigin.left;
      params['originY'] = sharePositionOrigin.top;
      params['originWidth'] = sharePositionOrigin.width;
      params['originHeight'] = sharePositionOrigin.height;
    }

    return _channel.invokeMethod<bool>(
      'shareFiles',
      params,
    );
  }

  String _mimeTypeForPath(String path) {
    assert(path != null);
    return lookupMimeType(path) ?? 'application/octet-stream';
  }
}
