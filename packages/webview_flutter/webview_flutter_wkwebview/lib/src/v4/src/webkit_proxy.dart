import '../../foundation/foundation.dart';
import '../../web_kit/web_kit.dart';

/// Handles constructing objects and calling static methods for the WebKit
/// native library.
class WebKitProxy {
  /// Constructs a [WebKitProxy].
  const WebKitProxy({
    this.onCreateWebView = WKWebView.new,
    this.onCreateWebViewConfiguration = WKWebViewConfiguration.new,
    this.onCreateScriptMessageHandler = WKScriptMessageHandler.new,
  });

  /// Constructs a [WKWebView].
  final WKWebView Function(
    WKWebViewConfiguration configuration, {
    void Function(
      String keyPath,
      NSObject object,
      Map<NSKeyValueChangeKey, Object?> change,
    )
        observeValue,
  }) onCreateWebView;

  /// Constructs a [WKWebViewConfiguration].
  final WKWebViewConfiguration Function() onCreateWebViewConfiguration;

  /// Constructs a [WKScriptMessageHandler].
  final WKScriptMessageHandler Function({
    required void Function(
      WKUserContentController userContentController,
      WKScriptMessage message,
    )
        didReceiveScriptMessage,
  }) onCreateScriptMessageHandler;
}
