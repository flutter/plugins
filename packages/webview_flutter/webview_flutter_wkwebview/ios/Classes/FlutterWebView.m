// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FlutterWebView.h"
#import "FLTWKNavigationDelegate.h"
#import "FLTWKProgressionDelegate.h"
#import "FlutterWebView_Test.h"
#import "JavaScriptChannelHandler.h"

@implementation FLTWebViewFactory {
  NSObject<FlutterBinaryMessenger> *_messenger;
  FLTCookieManager *_cookieManager;
}

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                    cookieManager:(FLTCookieManager *)cookieManager {
  self = [super init];
  if (self) {
    _messenger = messenger;
    _cookieManager = cookieManager;
  }
  return self;
}

- (NSObject<FlutterMessageCodec> *)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView> *)createWithFrame:(CGRect)frame
                                    viewIdentifier:(int64_t)viewId
                                         arguments:(id _Nullable)args {
  if (@available(iOS 11.0, *)) {
    [_cookieManager setCookiesForData:args[@"cookies"]];
  }

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
    [self applyConfigurationSettings:settings toConfiguration:configuration];
    configuration.userContentController = userContentController;
    [self updateAutoMediaPlaybackPolicy:args[@"autoMediaPlaybackPolicy"]
                        inConfiguration:configuration];

    _webView = [[FLTWKWebView alloc] initWithFrame:frame configuration:configuration];

    // Background color
    NSNumber *backgroundColorNSNumber = args[@"backgroundColor"];
    if ([backgroundColorNSNumber isKindOfClass:[NSNumber class]]) {
      int backgroundColorInt = [backgroundColorNSNumber intValue];
      UIColor *backgroundColor = [UIColor colorWithRed:(backgroundColorInt >> 16 & 0xff) / 255.0
                                                 green:(backgroundColorInt >> 8 & 0xff) / 255.0
                                                  blue:(backgroundColorInt & 0xff) / 255.0
                                                 alpha:(backgroundColorInt >> 24 & 0xff) / 255.0];
      _webView.opaque = NO;
      _webView.backgroundColor = UIColor.clearColor;
      _webView.scrollView.backgroundColor = backgroundColor;
    }

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

    [self applySettings:settings];
    // TODO(amirh): return an error if apply settings failed once it's possible to do so.
    // https://github.com/flutter/flutter/issues/36228

    NSString *initialUrl = args[@"initialUrl"];
    if ([initialUrl isKindOfClass:[NSString class]]) {
      NSURL *url = [NSURL URLWithString:initialUrl];
      if (url) {
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [_webView loadRequest:request];
      }
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
    [self onUpdateSettings:call result:result];
  } else if ([[call method] isEqualToString:@"loadFile"]) {
    [self onLoadFile:call result:result];
  } else if ([[call method] isEqualToString:@"loadFlutterAsset"]) {
    [self onLoadFlutterAsset:call result:result];
  } else if ([[call method] isEqualToString:@"loadHtmlString"]) {
    [self onLoadHtmlString:call result:result];
  } else if ([[call method] isEqualToString:@"loadUrl"]) {
    [self onLoadUrl:call result:result];
  } else if ([[call method] isEqualToString:@"loadRequest"]) {
    [self onLoadRequest:call result:result];
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
  } else if ([[call method] isEqualToString:@"evaluateJavascript"]) {
    [self onEvaluateJavaScript:call result:result];
  } else if ([[call method] isEqualToString:@"runJavascript"]) {
    [self onRunJavaScript:call result:result sendReturnValue:NO];
  } else if ([[call method] isEqualToString:@"runJavascriptReturningResult"]) {
    [self onRunJavaScript:call result:result sendReturnValue:YES];
  } else if ([[call method] isEqualToString:@"addJavascriptChannels"]) {
    [self onAddJavaScriptChannels:call result:result];
  } else if ([[call method] isEqualToString:@"removeJavascriptChannels"]) {
    [self onRemoveJavaScriptChannels:call result:result];
  } else if ([[call method] isEqualToString:@"clearCache"]) {
    [self clearCache:result];
  } else if ([[call method] isEqualToString:@"getTitle"]) {
    [self onGetTitle:result];
  } else if ([[call method] isEqualToString:@"scrollTo"]) {
    [self onScrollTo:call result:result];
  } else if ([[call method] isEqualToString:@"scrollBy"]) {
    [self onScrollBy:call result:result];
  } else if ([[call method] isEqualToString:@"getScrollX"]) {
    [self getScrollX:call result:result];
  } else if ([[call method] isEqualToString:@"getScrollY"]) {
    [self getScrollY:call result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)onUpdateSettings:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *error = [self applySettings:[call arguments]];
  if (error == nil) {
    result(nil);
    return;
  }
  result([FlutterError errorWithCode:@"updateSettings_failed" message:error details:nil]);
}

- (void)onLoadFile:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *error = nil;
  if (![FLTWebViewController isValidStringArgument:[call arguments] withErrorMessage:&error]) {
    result([FlutterError errorWithCode:@"loadFile_failed"
                               message:@"Failed parsing file path."
                               details:error]);
    return;
  }

  NSURL *url = [NSURL fileURLWithPath:[call arguments] isDirectory:NO];

  if (!url) {
    NSString *errorDetails = [NSString stringWithFormat:@"Initializing NSURL with the supplied "
                                                        @"'%@' path resulted in a nil value.",
                                                        [call arguments]];
    result([FlutterError errorWithCode:@"loadFile_failed"
                               message:@"Failed parsing file path."
                               details:errorDetails]);
    return;
  }

  NSURL *baseUrl = [url URLByDeletingLastPathComponent];

  [_webView loadFileURL:url allowingReadAccessToURL:baseUrl];
  result(nil);
}

- (void)onLoadFlutterAsset:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *error = nil;
  if (![FLTWebViewController isValidStringArgument:[call arguments] withErrorMessage:&error]) {
    result([FlutterError errorWithCode:@"loadFlutterAsset_invalidKey"
                               message:@"Supplied asset key is not valid."
                               details:error]);
    return;
  }

  NSString *assetKey = [call arguments];
  NSString *assetFilePath = [FlutterDartProject lookupKeyForAsset:assetKey];
  NSURL *url = [[NSBundle mainBundle] URLForResource:[assetFilePath stringByDeletingPathExtension]
                                       withExtension:assetFilePath.pathExtension];

  if (!url) {
    result([FlutterError
        errorWithCode:@"loadFlutterAsset_invalidKey"
              message:@"Failed parsing file path for supplied key."
              details:[NSString
                          stringWithFormat:@"Failed to convert path '%@' into NSURL for key '%@'.",
                                           assetFilePath, assetKey]]);
    return;
  }

  [_webView loadFileURL:url allowingReadAccessToURL:[url URLByDeletingLastPathComponent]];
  result(nil);
}

- (void)onLoadHtmlString:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSDictionary *arguments = [call arguments];
  if (![arguments isKindOfClass:NSDictionary.class]) {
    result([FlutterError
        errorWithCode:@"loadHtmlString_failed"
              message:@"Failed parsing arguments."
              details:@"Arguments should be a dictionary containing at least a 'html' element and "
                      @"optionally a 'baseUrl' argument. For example: `@{ @\"html\": @\"some html "
                      @"code\", @\"baseUrl\": @\"https://flutter.dev\" }`"]);
    return;
  }

  NSString *htmlString = [call arguments][@"html"];
  NSString *baseUrl =
      [call arguments][@"baseUrl"] == [NSNull null] ? nil : [call arguments][@"baseUrl"];
  NSString *error = nil;
  if (![FLTWebViewController isValidStringArgument:htmlString withErrorMessage:&error]) {
    result([FlutterError errorWithCode:@"loadHtmlString_failed"
                               message:@"Failed parsing HTML string argument."
                               details:error]);
    return;
  }

  [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:baseUrl]];
  result(nil);
}

- (void)onLoadUrl:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSMutableDictionary *requestData = [[NSMutableDictionary alloc] init];
  if (call.arguments[@"url"]) {
    requestData[@"uri"] = call.arguments[@"url"];
  }
  if (call.arguments[@"headers"]) {
    requestData[@"headers"] = call.arguments[@"headers"];
  }
  NSURLRequest *request = [self buildNSURLRequest:@{@"request" : requestData}];
  if (!request) {
    result([FlutterError
        errorWithCode:@"loadUrl_failed"
              message:@"Failed parsing the URL"
              details:[NSString stringWithFormat:@"Request was: '%@'", [call arguments]]]);
  } else {
    [_webView loadRequest:request];
    result(nil);
  }
}

- (void)onLoadRequest:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSURLRequest *request = [self buildNSURLRequest:[call arguments]];
  if (!request) {
    result([FlutterError
        errorWithCode:@"loadRequest_failed"
              message:@"Failed parsing the URL"
              details:[NSString stringWithFormat:@"Request was: '%@'", [call arguments]]]);
  } else {
    [_webView loadRequest:request];
    result(nil);
  }
}

- (void)onCanGoBack:(FlutterMethodCall *)call result:(FlutterResult)result {
  BOOL canGoBack = [_webView canGoBack];
  result(@(canGoBack));
}

- (void)onCanGoForward:(FlutterMethodCall *)call result:(FlutterResult)result {
  BOOL canGoForward = [_webView canGoForward];
  result(@(canGoForward));
}

- (void)onGoBack:(FlutterMethodCall *)call result:(FlutterResult)result {
  [_webView goBack];
  result(nil);
}

- (void)onGoForward:(FlutterMethodCall *)call result:(FlutterResult)result {
  [_webView goForward];
  result(nil);
}

- (void)onReload:(FlutterMethodCall *)call result:(FlutterResult)result {
  [_webView reload];
  result(nil);
}

- (void)onCurrentUrl:(FlutterMethodCall *)call result:(FlutterResult)result {
  _currentUrl = [[_webView URL] absoluteString];
  result(_currentUrl);
}

- (void)onEvaluateJavaScript:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *jsString = [call arguments];
  if (!jsString) {
    result([FlutterError errorWithCode:@"evaluateJavaScript_failed"
                               message:@"JavaScript String cannot be null"
                               details:nil]);
    return;
  }
  [_webView evaluateJavaScript:jsString
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

- (void)onRunJavaScript:(FlutterMethodCall *)call
                 result:(FlutterResult)result
        sendReturnValue:(BOOL)sendReturnValue {
  NSString *jsString = [call arguments];
  if (!jsString) {
    result([FlutterError errorWithCode:@"runJavascript_failed"
                               message:@"JavaScript String cannot be null"
                               details:nil]);
    return;
  }
  [_webView
      evaluateJavaScript:jsString
       completionHandler:^(_Nullable id evaluateResult, NSError *_Nullable error) {
         if (error) {
           // WebKit will throw an error (WKErrorJavaScriptResultTypeIsUnsupported) when the
           // type of the evaluated value is unsupported. This also goes for
           // `null` and `undefined` on iOS 14+, for example when running a void function.
           // For ease of use this specific error is ignored when no return value is expected.
           BOOL sendError =
               sendReturnValue || error.code != WKErrorJavaScriptResultTypeIsUnsupported;
           result(sendError
                      ? [FlutterError
                            errorWithCode:(sendReturnValue ? @"runJavascriptReturningResult_failed"
                                                           : @"runJavascript_failed")
                                  message:@"Failed running JavaScript"
                                  details:[NSString
                                              stringWithFormat:@"JavaScript string was: '%@'\n%@",
                                                               jsString, error]]
                      : nil);
           return;
         }
         result(sendReturnValue ? [NSString stringWithFormat:@"%@", evaluateResult] : nil);
       }];
}

- (void)onAddJavaScriptChannels:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSArray *channelNames = [call arguments];
  NSSet *channelNamesSet = [[NSSet alloc] initWithArray:channelNames];
  [_javaScriptChannelNames addObjectsFromArray:channelNames];
  [self registerJavaScriptChannels:channelNamesSet
                        controller:_webView.configuration.userContentController];
  result(nil);
}

- (void)onRemoveJavaScriptChannels:(FlutterMethodCall *)call result:(FlutterResult)result {
  // WkWebView does not support removing a single user script, so instead we remove all
  // user scripts, all message handlers. And re-register channels that shouldn't be removed.
  [_webView.configuration.userContentController removeAllUserScripts];
  for (NSString *channelName in _javaScriptChannelNames) {
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:channelName];
  }

  NSArray *channelNamesToRemove = [call arguments];
  for (NSString *channelName in channelNamesToRemove) {
    [_javaScriptChannelNames removeObject:channelName];
  }

  [self registerJavaScriptChannels:_javaScriptChannelNames
                        controller:_webView.configuration.userContentController];
  result(nil);
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

- (void)onGetTitle:(FlutterResult)result {
  NSString *title = _webView.title;
  result(title);
}

- (void)onScrollTo:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSDictionary *arguments = [call arguments];
  int x = [arguments[@"x"] intValue];
  int y = [arguments[@"y"] intValue];

  _webView.scrollView.contentOffset = CGPointMake(x, y);
  result(nil);
}

- (void)onScrollBy:(FlutterMethodCall *)call result:(FlutterResult)result {
  CGPoint contentOffset = _webView.scrollView.contentOffset;

  NSDictionary *arguments = [call arguments];
  int x = [arguments[@"x"] intValue] + contentOffset.x;
  int y = [arguments[@"y"] intValue] + contentOffset.y;

  _webView.scrollView.contentOffset = CGPointMake(x, y);
  result(nil);
}

- (void)getScrollX:(FlutterMethodCall *)call result:(FlutterResult)result {
  int offsetX = _webView.scrollView.contentOffset.x;
  result(@(offsetX));
}

- (void)getScrollY:(FlutterMethodCall *)call result:(FlutterResult)result {
  int offsetY = _webView.scrollView.contentOffset.y;
  result(@(offsetY));
}

// Returns nil when successful, or an error message when one or more keys are unknown.
- (NSString *)applySettings:(NSDictionary<NSString *, id> *)settings {
  NSMutableArray<NSString *> *unknownKeys = [[NSMutableArray alloc] init];
  for (NSString *key in settings) {
    if ([key isEqualToString:@"jsMode"]) {
      NSNumber *mode = settings[key];
      [self updateJsMode:mode];
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
      _webView.allowsBackForwardNavigationGestures =
          [allowsBackForwardNavigationGestures boolValue];
    } else if ([key isEqualToString:@"userAgent"]) {
      NSString *userAgent = settings[key];
      [self updateUserAgent:[userAgent isEqual:[NSNull null]] ? nil : userAgent];
    } else if ([key isEqualToString:@"zoomEnabled"]) {
      NSNumber *zoomEnabled = settings[key];
      _navigationDelegate.shouldEnableZoom = [zoomEnabled boolValue];
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

- (void)applyConfigurationSettings:(NSDictionary<NSString *, id> *)settings
                   toConfiguration:(WKWebViewConfiguration *)configuration {
  NSAssert(configuration != _webView.configuration,
           @"configuration needs to be updated before webView.configuration.");
  for (NSString *key in settings) {
    if ([key isEqualToString:@"allowsInlineMediaPlayback"]) {
      NSNumber *allowsInlineMediaPlayback = settings[key];
      configuration.allowsInlineMediaPlayback = [allowsInlineMediaPlayback boolValue];
    }
  }
}

- (void)updateJsMode:(NSNumber *)mode {
  WKPreferences *preferences = [[_webView configuration] preferences];
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

/**
 * Parses the method call arguments and converts them to an NSURLRequest object.
 *
 * @param arguments the method call arguments.
 *
 * @return NSURLRequest object.
 */
- (NSURLRequest *)buildNSURLRequest:(NSDictionary<NSString *, id> *)arguments {
  id requestParameters = arguments[@"request"];
  if (![requestParameters isKindOfClass:[NSDictionary class]]) {
    return nil;
  }

  NSString *urlString = requestParameters[@"uri"];
  if (!urlString) {
    return nil;
  }

  NSURL *url = [NSURL URLWithString:urlString];
  if (!url) {
    return nil;
  }

  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

  NSString *httpMethod = requestParameters[@"method"];
  if (httpMethod) {
    [request setHTTPMethod:httpMethod];
  }

  id httpBody = requestParameters[@"body"];
  if ([httpBody isKindOfClass:[FlutterStandardTypedData class]]) {
    [request setHTTPBody:[httpBody data]];
  }

  id headers = requestParameters[@"headers"];
  if ([headers isKindOfClass:[NSDictionary class]]) {
    [request setAllHTTPHeaderFields:headers];
  }

  return request;
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

- (void)updateUserAgent:(NSString *)userAgent {
  if (@available(iOS 9.0, *)) {
    [_webView setCustomUserAgent:userAgent];
  } else {
    NSLog(@"Updating UserAgent is not supported for Flutter WebViews prior to iOS 9.");
  }
}

/**
 * Validates if the given `argument` is a non-null, non-empty string.
 *
 * @param argument The argument that should be validated.
 * @param errorDetails An optional NSString variable which will contain a detailed error message in
 * case the supplied argument is not valid.
 * @return `YES` if the given `argument` is a valid non-null, non-empty string; otherwise `NO`.
 */
+ (BOOL)isValidStringArgument:(id)argument withErrorMessage:(NSString **)errorDetails {
  if (!argument) {
    if (errorDetails) {
      *errorDetails = @"Argument is nil.";
    }
    return NO;
  }
  if (![argument isKindOfClass:NSString.class]) {
    if (errorDetails) {
      *errorDetails = @"Argument is not of type NSString.";
    }
    return NO;
  }
  if (![argument length]) {
    if (errorDetails) {
      *errorDetails = @"Argument contains an empty string.";
    }
    return NO;
  }

  return YES;
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
