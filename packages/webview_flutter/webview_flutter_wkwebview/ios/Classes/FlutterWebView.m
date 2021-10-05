// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlutterWebView.h"
#import "FLTWKNavigationDelegate.h"
#import "FLTWKProgressionDelegate.h"
#import "JavaScriptChannelHandler.h"

@implementation FLTWebViewFactory {
  NSObject<FlutterBinaryMessenger> *_messenger;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  self = [super init];
  if (self) {
    _messenger = messenger;
  }
  return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
  FLTWebViewController *webviewController = [[FLTWebViewController alloc] initWithFrame:frame
                                                                         viewIdentifier:viewId
                                                                              arguments:args
                                                                        binaryMessenger:_messenger];
  return webviewController;
}

@end

@implementation FLTWKWebView

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  self.scrollView.contentInset = UIEdgeInsetsZero;
  // We don't want the contentInsets to be adjusted by iOS, flutter should always take control of
  // webview's contentInsets.
  // self.scrollView.contentInset = UIEdgeInsetsZero;
  if (@available(iOS 11, *)) {
    // Above iOS 11, adjust contentInset to compensate the adjustedContentInset so the sum will
    // always be 0.
    if (UIEdgeInsetsEqualToEdgeInsets(self.scrollView.adjustedContentInset, UIEdgeInsetsZero)) {
      return;
    }
    UIEdgeInsets insetToAdjust = self.scrollView.adjustedContentInset;
    self.scrollView.contentInset = UIEdgeInsetsMake(-insetToAdjust.top, -insetToAdjust.left,
                                                    -insetToAdjust.bottom, -insetToAdjust.right);
  }
}

@end

@implementation FLTWebViewController {
  FLTWKWebView *_webView;
  int64_t _viewId;
  FlutterMethodChannel *_channel;
  NSString *_currentUrl;
  // The set of registered JavaScript channel names.
  NSMutableSet *_javaScriptChannelNames;
  FLTWKNavigationDelegate *_navigationDelegate;
  FLTWKProgressionDelegate *_progressionDelegate;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger {
  if (self = [super init]) {
    _viewId = viewId;

    NSString *channelName = [NSString stringWithFormat:@"plugins.flutter.io/webview_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName binaryMessenger:messenger];
    _javaScriptChannelNames = [[NSMutableSet alloc] init];

    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    if ([args[@"javascriptChannelNames"] isKindOfClass:[NSArray class]]) {
      NSArray *javaScriptChannelNames = args[@"javascriptChannelNames"];
      [_javaScriptChannelNames addObjectsFromArray:javaScriptChannelNames];
      [self registerJavaScriptChannels:_javaScriptChannelNames controller:userContentController];
    }

    NSDictionary<NSString *, id> *settings = args[@"settings"];

    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    [self applyConfigurationSettings:_webView settings:settings toConfiguration:configuration];
    configuration.userContentController = userContentController;
    [self updateAutoMediaPlaybackPolicy:args[@"autoMediaPlaybackPolicy"]
                        inConfiguration:configuration];

    _webView = [[FLTWKWebView alloc] initWithFrame:frame configuration:configuration];
    _navigationDelegate = [[FLTWKNavigationDelegate alloc] initWithChannel:_channel];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = _navigationDelegate;
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
      [weakSelf onMethodCall:call result:result];
    }];

    if (@available(iOS 11.0, *)) {
      _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
      if (@available(iOS 13.0, *)) {
        _webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = NO;
      }
    }

    [self applySettings:_webView settings:settings];
    // TODO(amirh): return an error if apply settings failed once it's possible to do so.
    // https://github.com/flutter/flutter/issues/36228

    NSString *initialUrl = args[@"initialUrl"];
    if ([initialUrl isKindOfClass:[NSString class]]) {
      [self loadUrl:_webView url:initialUrl];
    }
  }
  return self;
}

- (void)dealloc {
  if (_progressionDelegate != nil) {
    [_progressionDelegate stopObservingProgress:_webView];
  }
}

- (UIView *)view {
  return _webView;
}

- (void)onMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([[call method] isEqualToString:@"updateSettings"]) {
    result([self onUpdateSettings:_webView settings:call.arguments]);
  } else if ([[call method] isEqualToString:@"loadUrl"]) {
    result([self onLoadUrl:_webView request:call.arguments]);
  } else if ([[call method] isEqualToString:@"canGoBack"]) {
    result([self onCanGoBack:_webView]);
  } else if ([[call method] isEqualToString:@"canGoForward"]) {
    result([self onCanGoForward:_webView]);
  } else if ([[call method] isEqualToString:@"goBack"]) {
    [self onGoBack:_webView];
    result(nil);
  } else if ([[call method] isEqualToString:@"goForward"]) {
    [self onGoForward:_webView];
    result(nil);
  } else if ([[call method] isEqualToString:@"reload"]) {
    [self onReload:_webView];
    result(nil);
  } else if ([[call method] isEqualToString:@"currentUrl"]) {
    result([self onCurrentUrl:_webView]);
  } else if ([[call method] isEqualToString:@"evaluateJavascript"]) {
    [self onEvaluateJavaScript:_webView jsString:call.arguments result:result];
  } else if ([[call method] isEqualToString:@"addJavascriptChannels"]) {
    [self onAddJavaScriptChannels:_webView channelNames:call.arguments];
    result(nil);
  } else if ([[call method] isEqualToString:@"removeJavascriptChannels"]) {
    [self onRemoveJavaScriptChannels:_webView channelNamesToRemove:call.arguments];
    result(nil);
  } else if ([[call method] isEqualToString:@"clearCache"]) {
    [self clearCache:result];
  } else if ([[call method] isEqualToString:@"getTitle"]) {
    result([self onGetTitle:_webView]);
  } else if ([[call method] isEqualToString:@"scrollTo"]) {
    NSDictionary *arguments = [call arguments];
    [self onScrollTo:_webView x:arguments[@"x"] y:arguments[@"y"]];
    result(nil);
  } else if ([[call method] isEqualToString:@"scrollBy"]) {
    NSDictionary *arguments = [call arguments];
    [self onScrollBy:_webView x:arguments[@"x"] y:arguments[@"y"]];
    result(nil);
  } else if ([[call method] isEqualToString:@"getScrollX"]) {
    result([self getScrollX:_webView]);
  } else if ([[call method] isEqualToString:@"getScrollY"]) {
    result([self getScrollY:_webView]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (FlutterError *_Nullable)onUpdateSettings:(WKWebView *)webView
                                   settings:(NSDictionary<NSString *, id> *)settings {
  NSString *error = [self applySettings:webView settings:settings];
  if (error == nil) return nil;
  return [FlutterError errorWithCode:@"updateSettings_failed" message:error details:nil];
}

- (FlutterError *_Nullable)onLoadUrl:(WKWebView *)webView
                             request:(NSDictionary<NSString *, id> *)request {
  if (![self loadRequest:webView request:request]) {
    return [FlutterError errorWithCode:@"loadUrl_failed"
                               message:@"Failed parsing the URL"
                               details:[NSString stringWithFormat:@"Request was: '%@'", request]];
  } else {
    return nil;
  }
}

- (NSNumber *)onCanGoBack:(WKWebView *)webView {
  return @(webView.canGoBack);
}

- (NSNumber *)onCanGoForward:(WKWebView *)webView {
  return @(webView.canGoForward);
}

- (void)onGoBack:(WKWebView *)webView {
  [webView goBack];
}

- (void)onGoForward:(WKWebView *)webView {
  [webView goForward];
}

- (void)onReload:(WKWebView *)webView {
  [webView reload];
}

- (NSString *)onCurrentUrl:(WKWebView *)webView {
  _currentUrl = [[webView URL] absoluteString];
  return _currentUrl;
}

- (void)onEvaluateJavaScript:(WKWebView *)webView
                    jsString:(NSString *)jsString
                      result:(FlutterResult)result {
  if (!jsString) {
    result([FlutterError errorWithCode:@"evaluateJavaScript_failed"
                               message:@"JavaScript String cannot be null"
                               details:nil]);
    return;
  }
  [webView evaluateJavaScript:jsString
            completionHandler:^(_Nullable id evaluateResult, NSError *_Nullable error) {
              if (error) {
                result([FlutterError
                    errorWithCode:@"evaluateJavaScript_failed"
                          message:@"Failed evaluating JavaScript"
                          details:[NSString stringWithFormat:@"JavaScript string was: '%@'\n%@",
                                                             jsString, error]]);
              } else {
                result([NSString stringWithFormat:@"%@", evaluateResult]);
              }
            }];
}

- (void)onAddJavaScriptChannels:(WKWebView *)webView channelNames:(NSArray *)channelNames {
  NSSet *channelNamesSet = [[NSSet alloc] initWithArray:channelNames];
  [_javaScriptChannelNames addObjectsFromArray:channelNames];
  [self registerJavaScriptChannels:channelNamesSet
                        controller:webView.configuration.userContentController];
}

- (void)onRemoveJavaScriptChannels:(WKWebView *)webView
              channelNamesToRemove:(NSArray *)channelNamesToRemove {
  // WkWebView does not support removing a single user script, so instead we remove all
  // user scripts, all message handlers. And re-register channels that shouldn't be removed.
  [webView.configuration.userContentController removeAllUserScripts];
  for (NSString *channelName in _javaScriptChannelNames) {
    [webView.configuration.userContentController removeScriptMessageHandlerForName:channelName];
  }

  for (NSString *channelName in channelNamesToRemove) {
    [_javaScriptChannelNames removeObject:channelName];
  }

  [self registerJavaScriptChannels:_javaScriptChannelNames
                        controller:webView.configuration.userContentController];
}

- (void)clearCache:(FlutterResult)result {
  if (@available(iOS 9.0, *)) {
    NSSet *cacheDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    WKWebsiteDataStore *dataStore = [WKWebsiteDataStore defaultDataStore];
    NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [dataStore removeDataOfTypes:cacheDataTypes
                   modifiedSince:dateFrom
               completionHandler:^{
                 result(nil);
               }];
  } else {
    // support for iOS8 tracked in https://github.com/flutter/flutter/issues/27624.
    NSLog(@"Clearing cache is not supported for Flutter WebViews prior to iOS 9.");
  }
}

- (NSString *)onGetTitle:(WKWebView *)webView {
  return webView.title;
}

- (void)onScrollTo:(WKWebView *)webView x:(NSNumber *)x y:(NSNumber *)y {
  webView.scrollView.contentOffset = CGPointMake(x.intValue, y.intValue);
}

- (void)onScrollBy:(WKWebView *)webView x:(NSNumber *)x y:(NSNumber *)y {
  CGPoint contentOffset = webView.scrollView.contentOffset;
  int offsetX = x.intValue + contentOffset.x;
  int offsetY = y.intValue + contentOffset.y;

  webView.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
}

- (NSNumber *)getScrollX:(WKWebView *)webView {
  return @((int)webView.scrollView.contentOffset.x);
}

- (NSNumber *)getScrollY:(WKWebView *)webView {
  return @((int)webView.scrollView.contentOffset.y);
}

// Returns nil when successful, or an error message when one or more keys are unknown.
- (NSString *)applySettings:(WKWebView *)webView settings:(NSDictionary<NSString *, id> *)settings {
  NSMutableArray<NSString *> *unknownKeys = [[NSMutableArray alloc] init];
  for (NSString *key in settings) {
    if ([key isEqualToString:@"jsMode"]) {
      NSNumber *mode = settings[key];
      [self updateJsMode:webView mode:mode];
    } else if ([key isEqualToString:@"hasNavigationDelegate"]) {
      NSNumber *hasDartNavigationDelegate = settings[key];
      _navigationDelegate.hasDartNavigationDelegate = [hasDartNavigationDelegate boolValue];
    } else if ([key isEqualToString:@"hasProgressTracking"]) {
      NSNumber *hasProgressTrackingValue = settings[key];
      bool hasProgressTracking = [hasProgressTrackingValue boolValue];
      if (hasProgressTracking) {
        _progressionDelegate = [[FLTWKProgressionDelegate alloc] initWithWebView:_webView
                                                                         channel:_channel];
      }
    } else if ([key isEqualToString:@"debuggingEnabled"]) {
      // no-op debugging is always enabled on iOS.
    } else if ([key isEqualToString:@"gestureNavigationEnabled"]) {
      NSNumber *allowsBackForwardNavigationGestures = settings[key];
      webView.allowsBackForwardNavigationGestures = [allowsBackForwardNavigationGestures boolValue];
    } else if ([key isEqualToString:@"userAgent"]) {
      NSString *userAgent = settings[key];
      [self updateUserAgent:webView userAgent:[userAgent isEqual:[NSNull null]] ? nil : userAgent];
    } else {
      [unknownKeys addObject:key];
    }
  }
  if ([unknownKeys count] == 0) {
    return nil;
  }
  return [NSString stringWithFormat:@"webview_flutter: unknown setting keys: {%@}",
                                    [unknownKeys componentsJoinedByString:@", "]];
}

- (void)applyConfigurationSettings:(WKWebView *)webView
                          settings:(NSDictionary<NSString *, id> *)settings
                   toConfiguration:(WKWebViewConfiguration *)configuration {
  NSAssert(configuration != webView.configuration,
           @"configuration needs to be updated before webView.configuration.");
  for (NSString *key in settings) {
    if ([key isEqualToString:@"allowsInlineMediaPlayback"]) {
      NSNumber *allowsInlineMediaPlayback = settings[key];
      configuration.allowsInlineMediaPlayback = [allowsInlineMediaPlayback boolValue];
    }
  }
}

- (void)updateJsMode:(WKWebView *)webView mode:(NSNumber *)mode {
  WKPreferences *preferences = [[webView configuration] preferences];
  switch ([mode integerValue]) {
    case 0:  // disabled
      [preferences setJavaScriptEnabled:NO];
      break;
    case 1:  // unrestricted
      [preferences setJavaScriptEnabled:YES];
      break;
    default:
      NSLog(@"webview_flutter: unknown JavaScript mode: %@", mode);
  }
}

- (void)updateAutoMediaPlaybackPolicy:(NSNumber *)policy
                      inConfiguration:(WKWebViewConfiguration *)configuration {
  switch ([policy integerValue]) {
    case 0:  // require_user_action_for_all_media_types
      if (@available(iOS 10.0, *)) {
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeAll;
      } else if (@available(iOS 9.0, *)) {
        configuration.requiresUserActionForMediaPlayback = true;
      } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        configuration.mediaPlaybackRequiresUserAction = true;
#pragma clang diagnostic pop
      }
      break;
    case 1:  // always_allow
      if (@available(iOS 10.0, *)) {
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
      } else if (@available(iOS 9.0, *)) {
        configuration.requiresUserActionForMediaPlayback = false;
      } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        configuration.mediaPlaybackRequiresUserAction = false;
#pragma clang diagnostic pop
      }
      break;
    default:
      NSLog(@"webview_flutter: unknown auto media playback policy: %@", policy);
  }
}

- (bool)loadRequest:(WKWebView *)webView request:(NSDictionary<NSString *, id> *)request {
  if (!request) {
    return false;
  }

  NSString *url = request[@"url"];
  if ([url isKindOfClass:[NSString class]]) {
    id headers = request[@"headers"];
    if ([headers isKindOfClass:[NSDictionary class]]) {
      return [self loadUrl:webView url:url withHeaders:headers];
    } else {
      return [self loadUrl:webView url:url];
    }
  }

  return false;
}

- (bool)loadUrl:(WKWebView *)webView url:(NSString *)url {
  return [self loadUrl:webView url:url withHeaders:[NSMutableDictionary dictionary]];
}

- (bool)loadUrl:(WKWebView *)webView
            url:(NSString *)url
    withHeaders:(NSDictionary<NSString *, NSString *> *)headers {
  NSURL *nsUrl = [NSURL URLWithString:url];
  if (!nsUrl) {
    return false;
  }
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:nsUrl];
  [request setAllHTTPHeaderFields:headers];
  [webView loadRequest:request];
  return true;
}

- (void)registerJavaScriptChannels:(NSSet *)channelNames
                        controller:(WKUserContentController *)userContentController {
  for (NSString *channelName in channelNames) {
    FLTJavaScriptChannel *channel =
        [[FLTJavaScriptChannel alloc] initWithMethodChannel:_channel
                                      javaScriptChannelName:channelName];
    [userContentController addScriptMessageHandler:channel name:channelName];
    NSString *wrapperSource = [NSString
        stringWithFormat:@"window.%@ = webkit.messageHandlers.%@;", channelName, channelName];
    WKUserScript *wrapperScript =
        [[WKUserScript alloc] initWithSource:wrapperSource
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                            forMainFrameOnly:NO];
    [userContentController addUserScript:wrapperScript];
  }
}

- (void)updateUserAgent:(WKWebView *)webView userAgent:(NSString *)userAgent {
  if (@available(iOS 9.0, *)) {
    [webView setCustomUserAgent:userAgent];
  } else {
    NSLog(@"Updating UserAgent is not supported for Flutter WebViews prior to iOS 9.");
  }
}

#pragma mark WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView
    createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
               forNavigationAction:(WKNavigationAction *)navigationAction
                    windowFeatures:(WKWindowFeatures *)windowFeatures {
  if (!navigationAction.targetFrame.isMainFrame) {
    [webView loadRequest:navigationAction.request];
  }

  return nil;
}

@end
