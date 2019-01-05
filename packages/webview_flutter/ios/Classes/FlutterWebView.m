#import "FlutterWebView.h"

@implementation FLTWebViewFactory {
  NSObject<FlutterBinaryMessenger>* _messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
  FLTWebViewController* webviewController = [[FLTWebViewController alloc] initWithFrame:frame
                                                                         viewIdentifier:viewId
                                                                              arguments:args
                                                                        binaryMessenger:_messenger];
  return webviewController;
}

@end

@interface FLTWebViewController () <WKNavigationDelegate>

@end

@implementation FLTWebViewController {
  WKWebView* _webView;
  int64_t _viewId;
  FlutterMethodChannel* _channel;
  NSString* _currentUrl;
  NSURL* _currentNSURL;
  NSString* _invalidUrlRegex;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger {
  if ([super init]) {
    _viewId = viewId;
    _webView = [[WKWebView alloc] initWithFrame:frame];
    _webView.navigationDelegate = self;
    NSString* channelName = [NSString stringWithFormat:@"plugins.flutter.io/webview_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      [weakSelf onMethodCall:call result:result];
    }];
    NSDictionary<NSString*, id>* settings = args[@"settings"];
    [self applySettings:settings];
    NSString* initialUrl = args[@"initialUrl"];
    if (initialUrl && initialUrl != [NSNull null]) {
      [self loadUrl:initialUrl];
    }
  }
  return self;
}

- (UIView*)view {
  return _webView;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([[call method] isEqualToString:@"updateSettings"]) {
    [self onUpdateSettings:call result:result];
  } else if ([[call method] isEqualToString:@"loadUrl"]) {
    [self onLoadUrl:call result:result];
  } else if ([[call method] isEqualToString:@"canGoBack"]) {
    [self onCanGoBack:call result:result];
  } else if ([[call method] isEqualToString:@"canGoForward"]) {
    [self onCanGoForward:call result:result];
  } else if ([[call method] isEqualToString:@"goBack"]) {
    [self onGoBack:call result:result];
  } else if ([[call method] isEqualToString:@"goForward"]) {
    [self onGoForward:call result:result];
  } else if ([[call method] isEqualToString:@"reload"]) {
    [self onReload:call result:result];
  } else if ([[call method] isEqualToString:@"currentUrl"]) {
    [self onCurrentUrl:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onUpdateSettings:(FlutterMethodCall*)call result:(FlutterResult)result {
  [self applySettings:[call arguments]];
  result(nil);
}

- (void)onLoadUrl:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSString* url = [call arguments];
  if (![self loadUrl:url]) {
    result([FlutterError errorWithCode:@"loadUrl_failed"
                               message:@"Failed parsing the URL"
                               details:[NSString stringWithFormat:@"URL was: '%@'", url]]);
  } else {
    result(nil);
  }
}

- (void)onCanGoBack:(FlutterMethodCall*)call result:(FlutterResult)result {
  BOOL canGoBack = [_webView canGoBack];
  result([NSNumber numberWithBool:canGoBack]);
}

- (void)onCanGoForward:(FlutterMethodCall*)call result:(FlutterResult)result {
  BOOL canGoForward = [_webView canGoForward];
  result([NSNumber numberWithBool:canGoForward]);
}

- (void)onGoBack:(FlutterMethodCall*)call result:(FlutterResult)result {
  [_webView goBack];
  result(nil);
}

- (void)onGoForward:(FlutterMethodCall*)call result:(FlutterResult)result {
  [_webView goForward];
  result(nil);
}

- (void)onReload:(FlutterMethodCall*)call result:(FlutterResult)result {
  [_webView reload];
  result(nil);
}

- (void)onCurrentUrl:(FlutterMethodCall*)call result:(FlutterResult)result {
  _currentUrl = [[_webView URL] absoluteString];
  result(_currentUrl);
}

- (void)applySettings:(NSDictionary<NSString*, id>*)settings {
  for (NSString* key in settings) {
    if ([key isEqualToString:@"jsMode"]) {
      NSNumber* mode = settings[key];
      [self updateJsMode:mode];
    } else if ([key isEqualToString:@"invalidUrlRegex"]) {
      _invalidUrlRegex = settings[key];
    } else {
      NSLog(@"webview_flutter: unknown setting key: %@", key);
    }
  }
}

- (void)updateJsMode:(NSNumber*)mode {
  WKPreferences* preferences = [[_webView configuration] preferences];
  switch ([mode integerValue]) {
    case 0:  // disabled
      [preferences setJavaScriptEnabled:NO];
      break;
    case 1:  // unrestricted
      [preferences setJavaScriptEnabled:YES];
      break;
    default:
      NSLog(@"webview_flutter: unknown javascript mode: %@", mode);
  }
}

- (bool)loadUrl:(NSString*)url {
  NSURL* nsUrl = [NSURL URLWithString:url];
  if (!nsUrl) {
    return false;
  }
  NSURLRequest* req = [NSURLRequest requestWithURL:nsUrl];
  [_webView loadRequest:req];
  return true;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView*)webView
    decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction
                    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  _currentNSURL = navigationAction.request.URL;
  if ([self checkInvalidUrl:_currentNSURL]) {
    decisionHandler(WKNavigationActionPolicyCancel);
  } else {
    decisionHandler(WKNavigationActionPolicyAllow);
  }
  [self onNavigateUrl:_currentNSURL method:@"onUrlShouldLoad"];
}

- (void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation {
  [self onNavigateUrl:_currentNSURL method:@"onPageStarted"];
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation {
  [self onNavigateUrl:_currentNSURL method:@"onPageFinished"];
}

- (bool)checkInvalidUrl:(NSURL*)url {
  NSString* urlString = url != nil ? [url absoluteString] : nil;
  if (_invalidUrlRegex && urlString) {
    NSError* error = NULL;
    NSRegularExpression* regex =
        [NSRegularExpression regularExpressionWithPattern:_invalidUrlRegex
                                                  options:NSRegularExpressionCaseInsensitive
                                                    error:&error];
    NSTextCheckingResult* match = [regex firstMatchInString:urlString
                                                    options:0
                                                      range:NSMakeRange(0, [urlString length])];
    return match != nil;
  } else {
    return false;
  }
}

- (void)onNavigateUrl:(NSURL*)url method:(NSString*)method {
  if (url) {
    NSDictionary* args = @{@"url" : [url absoluteString]};
    [_channel invokeMethod:method arguments:args];
  }
}

@end
