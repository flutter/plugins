import 'android_webview.dart';
import 'android_webview.pigeon.dart';
import 'instance_manager.dart';

final InstanceManager _instanceManager = InstanceManager();

class WebViewHostApiImpl extends WebViewHostApi {
  WebViewHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? _instanceManager;
  }

  late final InstanceManager instanceManager;

  int _getInstanceId(Object instance) =>
      instanceManager.getInstanceId(instance)!;

  Future<void> createFromInstance(
    WebView instance,
    bool useHybridComposition,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      return create(instanceId, useHybridComposition);
    }
  }

  Future<void> disposeFromInstance(WebView instance) async {
    final int? instanceId = instanceManager.removeInstance(instance);
    if (instanceId != null) {
      return dispose(instanceId);
    }
  }

  Future<void> loadUrlFromInstance(
    WebView instance,
    String url,
    Map<String, String> headers,
  ) {
    return loadUrl(_getInstanceId(instance), url, headers);
  }

  Future<String> getUrlFromInstance(WebView instance) {
    return getUrl(_getInstanceId(instance));
  }

  Future<bool> canGoBackFromInstance(WebView instance) {
    return canGoBack(_getInstanceId(instance));
  }

  Future<bool> canGoForwardFromInstance(WebView instance) {
    return canGoForward(_getInstanceId(instance));
  }

  Future<void> goBackFromInstance(WebView instance) {
    return goBack(_getInstanceId(instance));
  }

  Future<void> goForwardFromInstance(WebView instance) {
    return goForward(_getInstanceId(instance));
  }

  Future<void> reloadFromInstance(WebView instance) {
    return reload(_getInstanceId(instance));
  }

  Future<void> clearCacheFromInstance(WebView instance, bool includeDiskFiles) {
    return clearCache(_getInstanceId(instance), includeDiskFiles);
  }

  Future<String> evaluateJavascriptFromInstance(
    WebView instance,
    String javascriptString,
  ) {
    return evaluateJavascript(_getInstanceId(instance), javascriptString);
  }

  Future<String> getTitleFromInstance(WebView instance) {
    return getTitle(_getInstanceId(instance));
  }

  Future<void> scrollToFromInstance(WebView instance, int x, int y) {
    return scrollTo(_getInstanceId(instance), x, y);
  }

  Future<void> scrollByFromInstance(WebView instance, int x, int y) {
    return scrollBy(_getInstanceId(instance), x, y);
  }

  Future<int> getScrollXFromInstance(WebView instance) {
    return getScrollX(_getInstanceId(instance));
  }

  Future<int> getScrollYFromInstance(WebView instance) {
    return getScrollY(_getInstanceId(instance));
  }
}

class WebViewSettingsHostApiImpl extends WebViewSettingsHostApi {
  WebViewSettingsHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? _instanceManager;
  }

  late final InstanceManager instanceManager;

  int _getInstanceId(Object instance) =>
      instanceManager.getInstanceId(instance)!;

  Future<void> createFromInstance(
    WebViewSettings instance,
    WebView webView,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      return create(instanceId, _getInstanceId(webView));
    }
  }

  Future<void> disposeFromInstance(WebViewSettings instance) async {
    final int? instanceId = instanceManager.removeInstance(instance);
    if (instanceId != null) {
      return dispose(instanceId);
    }
  }

  Future<void> setDomStorageEnabledFromInstance(
    WebViewSettings instance,
    bool flag,
  ) {
    return setDomStorageEnabled(_getInstanceId(instance), flag);
  }

  Future<void> setJavaScriptCanOpenWindowsAutomaticallyFromInstance(
    WebViewSettings instance,
    bool flag,
  ) {
    return setJavaScriptCanOpenWindowsAutomatically(
      _getInstanceId(instance),
      flag,
    );
  }

  Future<void> setSupportMultipleWindowsFromInstance(
    WebViewSettings instance,
    bool support,
  ) {
    return setSupportMultipleWindows(_getInstanceId(instance), support);
  }

  Future<void> setJavaScriptEnabledFromInstance(
    WebViewSettings instance,
    bool flag,
  ) {
    return setJavaScriptCanOpenWindowsAutomatically(
      _getInstanceId(instance),
      flag,
    );
  }

  Future<void> setUserAgentStringFromInstance(
    WebViewSettings instance,
    String userAgentString,
  ) {
    return setUserAgentString(_getInstanceId(instance), userAgentString);
  }

  Future<void> setMediaPlaybackRequiresUserGestureFromInstance(
    WebViewSettings instance,
    bool require,
  ) {
    return setMediaPlaybackRequiresUserGesture(
      _getInstanceId(instance),
      require,
    );
  }
}
