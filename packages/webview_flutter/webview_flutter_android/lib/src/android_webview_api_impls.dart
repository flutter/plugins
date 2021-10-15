import 'android_webview.dart';
import 'android_webview.pigeon.dart';
import 'instance_manager.dart';

class WebViewHostApiImpl extends WebViewHostApi {
  Future<void> createFromInstance(
    WebView webView,
    bool useHybridComposition,
  ) async {
    final int? instanceId = InstanceManager.instance.tryAddInstance(webView);
    if (instanceId != null) {
      return create(instanceId, useHybridComposition);
    }
  }

  Future<void> disposeFromInstance(WebView webView) async {
    final int? instanceId = InstanceManager.instance.removeInstance(webView);
    if (instanceId != null) {
      return dispose(instanceId);
    }
  }
}
