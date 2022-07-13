import '../../foundation/foundation.dart';
import '../../web_kit/web_kit.dart';

/// Handles constructing objects and calling static methods for the WebKit
/// native library.
class WebKitProxy {
  /// Constructs a [WebKitProxy].
  const WebKitProxy();

  /// Constructs a [WKWebView].
  WKWebView createWebView(
    WKWebViewConfiguration configuration, {
    void Function(
      String keyPath,
      NSObject object,
      Map<NSKeyValueChangeKey, Object?> change,
    )?
        observeValue,
  }) {
    return WKWebView(configuration, observeValue: observeValue);
  }

  /// Constructs a [WKWebViewConfiguration].
  WKWebViewConfiguration createWebViewConfiguration() {
    return WKWebViewConfiguration();
  }

  /// Constructs a [WKScriptMessageHandler].
  WKScriptMessageHandler createScriptMessageHandler({
    required void Function(
      WKUserContentController userContentController,
      WKScriptMessage message,
    )
        didReceiveScriptMessage,
  }) {
    return WKScriptMessageHandler(
      didReceiveScriptMessage: didReceiveScriptMessage,
    );
  }
}
