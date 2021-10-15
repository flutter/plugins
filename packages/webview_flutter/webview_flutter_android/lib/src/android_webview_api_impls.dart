import 'android_webview.dart';
import 'android_webview.pigeon.dart';
import 'instance_manager.dart';

class WebViewHostApiImpl extends WebViewHostApi {
  WebViewHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

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
    return loadUrl(instanceManager.getInstanceId(instance)!, url, headers);
  }

  Future<String> getUrlFromInstance(WebView instance) {
    return getUrl(instanceManager.getInstanceId(instance)!);
  }

  Future<bool> canGoBackFromInstance(WebView instance) {
    return canGoBack(instanceManager.getInstanceId(instance)!);
  }

  Future<bool> canGoForwardFromInstance(WebView instance) {
    return canGoForward(instanceManager.getInstanceId(instance)!);
  }

  Future<void> goBackFromInstance(WebView instance) {
    return goBack(instanceManager.getInstanceId(instance)!);
  }

  Future<void> goForwardFromInstance(WebView instance) {
    return goForward(instanceManager.getInstanceId(instance)!);
  }

  Future<void> reloadFromInstance(WebView instance) {
    return reload(instanceManager.getInstanceId(instance)!);
  }

  Future<void> clearCacheFromInstance(WebView instance, bool includeDiskFiles) {
    return clearCache(
      instanceManager.getInstanceId(instance)!,
      includeDiskFiles,
    );
  }

  Future<String> evaluateJavascriptFromInstance(
    WebView instance,
    String javascriptString,
  ) {
    return evaluateJavascript(
        instanceManager.getInstanceId(instance)!, javascriptString);
  }

  Future<String> getTitleFromInstance(WebView instance) {
    return getTitle(instanceManager.getInstanceId(instance)!);
  }

  Future<void> scrollToFromInstance(WebView instance, int x, int y) {
    return scrollTo(instanceManager.getInstanceId(instance)!, x, y);
  }

  Future<void> scrollByFromInstance(WebView instance, int x, int y) {
    return scrollBy(instanceManager.getInstanceId(instance)!, x, y);
  }

  Future<int> getScrollXFromInstance(WebView instance) {
    return getScrollX(instanceManager.getInstanceId(instance)!);
  }

  Future<int> getScrollYFromInstance(WebView instance) {
    return getScrollY(instanceManager.getInstanceId(instance)!);
  }

  Future<void> setWebViewClientFromInstance(
    WebView instance,
    WebViewClient webViewClient,
  ) {
    return setWebViewClient(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(webViewClient)!,
    );
  }

  Future<void> addJavaScriptChannelFromInstance(
    WebView instance,
    JavaScriptChannel javaScriptChannel,
  ) {
    return addJavaScriptChannel(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(javaScriptChannel)!,
    );
  }

  Future<void> removeJavaScriptChannelFromInstance(
    WebView instance,
    JavaScriptChannel javaScriptChannel,
  ) {
    return removeJavaScriptChannel(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(javaScriptChannel)!,
    );
  }

  Future<void> setDownloadListenerFromInstance(
    WebView instance,
    DownloadListener listener,
  ) {
    return setDownloadListener(
      instanceManager.getInstanceId(instance)!,
      instanceManager.getInstanceId(listener)!,
    );
  }
}

class WebViewSettingsHostApiImpl extends WebViewSettingsHostApi {
  WebViewSettingsHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

  Future<void> createFromInstance(
    WebViewSettings instance,
    WebView webView,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      return create(instanceId, instanceManager.getInstanceId(webView)!);
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
    return setDomStorageEnabled(instanceManager.getInstanceId(instance)!, flag);
  }

  Future<void> setJavaScriptCanOpenWindowsAutomaticallyFromInstance(
    WebViewSettings instance,
    bool flag,
  ) {
    return setJavaScriptCanOpenWindowsAutomatically(
      instanceManager.getInstanceId(instance)!,
      flag,
    );
  }

  Future<void> setSupportMultipleWindowsFromInstance(
    WebViewSettings instance,
    bool support,
  ) {
    return setSupportMultipleWindows(
        instanceManager.getInstanceId(instance)!, support);
  }

  Future<void> setJavaScriptEnabledFromInstance(
    WebViewSettings instance,
    bool flag,
  ) {
    return setJavaScriptCanOpenWindowsAutomatically(
      instanceManager.getInstanceId(instance)!,
      flag,
    );
  }

  Future<void> setUserAgentStringFromInstance(
    WebViewSettings instance,
    String userAgentString,
  ) {
    return setUserAgentString(
      instanceManager.getInstanceId(instance)!,
      userAgentString,
    );
  }

  Future<void> setMediaPlaybackRequiresUserGestureFromInstance(
    WebViewSettings instance,
    bool require,
  ) {
    return setMediaPlaybackRequiresUserGesture(
      instanceManager.getInstanceId(instance)!,
      require,
    );
  }

  Future<void> setSupportZoomFromInstance(
    WebViewSettings instance,
    bool support,
  ) {
    return setSupportZoom(instanceManager.getInstanceId(instance)!, support);
  }

  Future<void> setLoadWithOverviewModeFromInstance(
    WebViewSettings instance,
    bool overview,
  ) {
    return setLoadWithOverviewMode(
      instanceManager.getInstanceId(instance)!,
      overview,
    );
  }

  Future<void> setUseWideViewPortFromInstance(
    WebViewSettings instance,
    bool use,
  ) {
    return setUseWideViewPort(instanceManager.getInstanceId(instance)!, use);
  }

  Future<void> setDisplayZoomControlsFromInstance(
    WebViewSettings instance,
    bool enabled,
  ) {
    return setDisplayZoomControls(
      instanceManager.getInstanceId(instance)!,
      enabled,
    );
  }

  Future<void> setBuiltInZoomControlsFromInstance(
    WebViewSettings instance,
    bool enabled,
  ) {
    return setBuiltInZoomControls(
      instanceManager.getInstanceId(instance)!,
      enabled,
    );
  }
}

class JavaScriptChannelHostApiImpl extends JavaScriptChannelHostApi {
  JavaScriptChannelHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

  Future<void> createFromInstance(
    JavaScriptChannel instance,
    String channelName,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      return create(instanceId, channelName);
    }
  }

  Future<void> disposeFromInstance(JavaScriptChannel instance) async {
    final int? instanceId = instanceManager.removeInstance(instance);
    if (instanceId != null) {
      return dispose(instanceId);
    }
  }
}

class JavaScriptChannelFlutterApiImpl extends JavaScriptChannelFlutterApi {
  JavaScriptChannelHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

  @override
  void postMessage(int instanceId, String message) {
    final JavaScriptChannel instance =
        instanceManager.getInstance(instanceId) as JavaScriptChannel;
    instance.postMessage(message);
  }
}

class WebViewClientHostApiImpl extends WebViewClientHostApi {
  WebViewClientHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

  Future<void> createFromInstance(
    WebViewClient instance,
    bool autoFailShouldOverrideUrlLoading,
  ) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      return create(instanceId, autoFailShouldOverrideUrlLoading);
    }
  }

  Future<void> disposeFromInstance(WebViewClient instance) async {
    final int? instanceId = instanceManager.removeInstance(instance);
    if (instanceId != null) {
      return dispose(instanceId);
    }
  }
}

class WebViewClientFlutterApiImpl extends WebViewClientFlutterApi {
  WebViewClientFlutterApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

  @override
  void onPageFinished(int instanceId, int webViewInstanceId, String url) {
    final WebViewClient instance =
        instanceManager.getInstance(instanceId) as WebViewClient;
    instance.onPageFinished(
      instanceManager.getInstance(webViewInstanceId) as WebView,
      url,
    );
  }

  @override
  void onPageStarted(int instanceId, int webViewInstanceId, String url) {
    final WebViewClient instance =
        instanceManager.getInstance(instanceId) as WebViewClient;
    instance.onPageStarted(
      instanceManager.getInstance(webViewInstanceId) as WebView,
      url,
    );
  }

  @override
  void onReceivedError(
    int instanceId,
    int webViewInstanceId,
    int errorCode,
    String description,
    String failingUrl,
  ) {
    final WebViewClient instance =
        instanceManager.getInstance(instanceId) as WebViewClient;
    instance.onReceivedError(
      instanceManager.getInstance(webViewInstanceId) as WebView,
      errorCode,
      description,
      failingUrl,
    );
  }

  @override
  void onReceivedRequestError(
    int instanceId,
    int webViewInstanceId,
    WebResourceRequestData request,
    WebResourceErrorData error,
  ) {
    final WebViewClient instance =
        instanceManager.getInstance(instanceId) as WebViewClient;
    instance.onReceivedRequestError(
      instanceManager.getInstance(webViewInstanceId) as WebView,
      WebResourceRequest(
        url: request.url!,
        isForMainFrame: request.isForMainFrame!,
        isRedirect: request.isRedirect,
        hasGesture: request.hasGesture!,
        method: request.method!,
        requestHeaders: request.requestHeaders!.cast<String, String>(),
      ),
      WebResourceError(
        errorCode: error.errorCode!,
        description: error.description!,
      ),
    );
  }

  @override
  void shouldOverrideRequestLoading(
    int instanceId,
    int webViewInstanceId,
    WebResourceRequestData request,
  ) {
    final WebViewClient instance =
        instanceManager.getInstance(instanceId) as WebViewClient;
    instance.shouldOverrideRequestLoading(
      instanceManager.getInstance(webViewInstanceId) as WebView,
      WebResourceRequest(
        url: request.url!,
        isForMainFrame: request.isForMainFrame!,
        isRedirect: request.isRedirect,
        hasGesture: request.hasGesture!,
        method: request.method!,
        requestHeaders: request.requestHeaders!.cast<String, String>(),
      ),
    );
  }

  @override
  void shouldOverrideUrlLoading(
    int instanceId,
    int webViewInstanceId,
    String url,
  ) {
    final WebViewClient instance =
        instanceManager.getInstance(instanceId) as WebViewClient;
    instance.shouldOverrideUrlLoading(
      instanceManager.getInstance(webViewInstanceId) as WebView,
      url,
    );
  }
}

class DownloadListenerHostApiImpl extends DownloadListenerHostApi {
  DownloadListenerHostApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

  Future<void> createFromInstance(DownloadListener instance) async {
    final int? instanceId = instanceManager.tryAddInstance(instance);
    if (instanceId != null) {
      return create(instanceId);
    }
  }

  Future<void> disposeFromInstance(DownloadListener instance) async {
    final int? instanceId = instanceManager.removeInstance(instance);
    if (instanceId != null) {
      return dispose(instanceId);
    }
  }
}

class DownloadListenerFlutterApiImpl extends DownloadListenerFlutterApi {
  DownloadListenerFlutterApiImpl({InstanceManager? instanceManager}) {
    this.instanceManager = instanceManager ?? InstanceManager.instance;
  }

  late final InstanceManager instanceManager;

  @override
  void onDownloadStart(
    int instanceId,
    String url,
    String userAgent,
    String contentDisposition,
    String mimetype,
    int contentLength,
  ) {
    final DownloadListener instance =
        instanceManager.getInstance(instanceId) as DownloadListener;
    instance.onDownloadStart(
      url,
      userAgent,
      contentDisposition,
      mimetype,
      contentLength,
    );
  }
}
