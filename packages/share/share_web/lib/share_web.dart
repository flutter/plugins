@JS()
library share;

import 'package:flutter/widgets.dart';
import 'package:share_platform_interface/share_platform_interface.dart';

import 'package:js/js.dart';

class SharePlugin extends SharePlatform {
  @override
  Future<void> share(
    String text, {
    @required String subject,
    @required Rect sharePositionOrigin,
  }) {
    print('share called from $this');
    return invokeWebShare(ShareConfig(text: text, subject: subject));
  }

  @override
  Future<void> shareFiles(
    List<String> paths, {
    @required List<String> mimeTypes,
    @required String subject,
    @required String text,
    @required Rect sharePositionOrigin,
  }) {
    // return html.window.navigator.share({
    //   'title': subject,
    //   'text': text,
    //   'files': js.JsArray<String>.from(paths),
    // });
    return invokeWebShareFiles(
      ShareFilesConfig(paths: paths, subject: subject, text: text),
    );
  }

  @JS('navigator.share')
  external Future<void> invokeWebShare(ShareConfig config);

  @JS('navigator.shareFiles')
  external Future<void> invokeWebShareFiles(ShareFilesConfig config);
}

@JS()
@anonymous
class ShareConfig {
  external String get text;
  external String get subject;

  external factory ShareConfig({
    @required String text,
    @required String subject,
  });
}

@JS()
@anonymous
class ShareFilesConfig {
  external List<String> get paths;
  external String get subject;
  external String get text;

  external factory ShareFilesConfig({
    @required List<String> paths,
    @required String subject,
    @required String text,
  });
}
