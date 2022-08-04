import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_platform_interface/v4/src/platform_webview_widget.dart';

import '../../foundation/foundation.dart';
import '../webview_flutter_wkwebview.dart';

/// An implementation of [PlatformWebViewWidget] with the WebKit api.
class WebKitWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebKitWebViewWidget].
  WebKitWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(
    BuildContext context, {
    required covariant WebKitWebViewController controller,
    TextDirection? layoutDirection = TextDirection.ltr,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
  }) {
    return UiKitView(
      viewType: 'plugins.flutter.io/webview',
      onPlatformViewCreated: (_) {},
      layoutDirection: layoutDirection,
      gestureRecognizers: gestureRecognizers,
      creationParams:
          NSObject.globalInstanceManager.getIdentifier(controller.webView),
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
