import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:webview_flutter_platform_interface/v4/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/src/foundation/foundation.dart';
import 'package:webview_flutter_wkwebview/src/v4/src/webkit_proxy.dart';
import 'package:webview_flutter_wkwebview/src/v4/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_wkwebview/src/web_kit/web_kit.dart';

import 'webkit_webview_controller_test.mocks.dart';

@GenerateMocks(<Type>[WKWebView, WKWebViewConfiguration])
void main() {
  group('WebKitWebViewController', () {
    WebKitWebViewController createControllerWithMocks({
      MockWKWebView? mockWebView,
      MockWKWebViewConfiguration? mockWebViewConfiguration,
    }) {
      final PlatformWebViewControllerCreationParams controllerCreationParams =
          WebKitWebViewControllerCreationParams
              .fromPlatformWebViewControllerCreationParams(
        const PlatformWebViewControllerCreationParams(),
        webKitProxy: WebKitProxy(
          onCreateWebViewConfiguration: () =>
              mockWebViewConfiguration ?? MockWKWebViewConfiguration(),
        ),
      );

      return WebKitWebViewController(
        controllerCreationParams,
        webKitProxy: WebKitProxy(
          onCreateWebView: (
            _, {
            void Function(
              String keyPath,
              NSObject object,
              Map<NSKeyValueChangeKey, Object?> change,
            )?
                observeValue,
          }) {
            return mockWebView ?? MockWKWebView();
          },
        ),
      );
    }

    test('loadFile', () async {
      final MockWKWebView mockWebView = MockWKWebView();

      final WebKitWebViewController controller = createControllerWithMocks(
        mockWebView: mockWebView,
      );

      await controller.loadFile('/path/to/file.html');
      verify(mockWebView.loadFileUrl(
        '/path/to/file.html',
        readAccessUrl: '/path/to',
      ));
    });
  });
}
