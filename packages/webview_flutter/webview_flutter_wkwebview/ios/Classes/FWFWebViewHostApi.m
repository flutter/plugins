// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFWebViewHostApi.h"
#import "FWFDataConverters.h"

@implementation FWFAssetManager
- (NSString *)lookupKeyForAsset:(NSString *)asset {
  return [FlutterDartProject lookupKeyForAsset:asset];
}
@end

@implementation FWFWebView
- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  // Prevents the contentInsets from being adjusted by iOS and gives control to Flutter.
  self.scrollView.contentInset = UIEdgeInsetsZero;
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

- (nonnull UIView *)view {
  return self;
}
@end

@interface FWFWebViewHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@property NSBundle *bundle;
@property FWFAssetManager *assetManager;
@end

@implementation FWFWebViewHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  return [self initWithInstanceManager:instanceManager
                                bundle:[NSBundle mainBundle]
                          assetManager:[[FWFAssetManager alloc] init]];
}

- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager
                                 bundle:(NSBundle *)bundle
                           assetManager:(FWFAssetManager *)assetManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
    _bundle = bundle;
    _assetManager = assetManager;
  }
  return self;
}

- (FWFWebView *)webViewForIdentifier:(NSNumber *)instanceId {
  return (FWFWebView *)[self.instanceManager instanceForIdentifier:instanceId.longValue];
}

+ (nonnull FlutterError *)errorForURLString:(nonnull NSString *)string {
  NSString *errorDetails = [NSString stringWithFormat:@"Initializing NSURL with the supplied "
                                                      @"'%@' path resulted in a nil value.",
                                                      string];
  return [FlutterError errorWithCode:@"FWFURLParsingError"
                             message:@"Failed parsing file path."
                             details:errorDetails];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
     configurationIdentifier:(nonnull NSNumber *)configurationInstanceId
                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  WKWebViewConfiguration *configuration = (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:configurationInstanceId.longValue];
  FWFWebView *webView = [[FWFWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)
                                            configuration:configuration];
  [self.instanceManager addInstance:webView withIdentifier:instanceId.longValue];
}

- (void)loadRequestForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                    request:(nonnull FWFNSUrlRequestData *)request
                                      error:
                                          (FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURLRequest *urlRequest = FWFNSURLRequestFromRequestData(request);
  if (!urlRequest) {
    *error = [FlutterError errorWithCode:@"FWFURLRequestParsingError"
                                 message:@"Failed instantiating an NSURLRequest."
                                 details:[NSString stringWithFormat:@"URL was: '%@'", request.url]];
    return;
  }
  [[self webViewForIdentifier:instanceId] loadRequest:urlRequest];
}

- (void)setUserAgentForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                   userAgent:(nullable NSString *)userAgent
                                       error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                 error {
  [[self webViewForIdentifier:instanceId] setCustomUserAgent:userAgent];
}

- (nullable NSNumber *)
    canGoBackForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([self webViewForIdentifier:instanceId].canGoBack);
}

- (nullable NSString *)
    URLForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                          error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [self webViewForIdentifier:instanceId].URL.absoluteString;
}

- (nullable NSNumber *)
    canGoForwardForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return @([[self webViewForIdentifier:instanceId] canGoForward]);
}

- (nullable NSNumber *)
    estimatedProgressForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                  error {
  return @([[self webViewForIdentifier:instanceId] estimatedProgress]);
}

- (void)evaluateJavaScriptForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                  javaScriptString:(nonnull NSString *)javaScriptString
                                        completion:
                                            (nonnull void (^)(id _Nullable,
                                                              FlutterError *_Nullable))completion {
  [[self webViewForIdentifier:instanceId]
      evaluateJavaScript:javaScriptString
       completionHandler:^(id _Nullable result, NSError *_Nullable error) {
         id returnValue = nil;
         FlutterError *flutterError = nil;
         if (!error) {
           if (!result || [result isKindOfClass:[NSString class]] ||
               [result isKindOfClass:[NSNumber class]]) {
             returnValue = result;
           } else {
             NSString *className = NSStringFromClass([result class]);
             NSLog(@"Return type of evaluateJavaScript is not directly supported: %@. Returned "
                   @"description of value.",
                   className);
             returnValue = [result description];
           }
         } else {
           flutterError = [FlutterError errorWithCode:@"FWFEvaluateJavaScriptError"
                                              message:@"Failed evaluating JavaScript."
                                              details:error];
         }

         completion(returnValue, flutterError);
       }];
}

- (void)goBackForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                 error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:instanceId] goBack];
}

- (void)goForwardForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                    error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:instanceId] goForward];
}

- (void)loadAssetForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                 assetKey:(nonnull NSString *)key
                                    error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSString *assetFilePath = [self.assetManager lookupKeyForAsset:key];

  NSURL *url = [self.bundle URLForResource:[assetFilePath stringByDeletingPathExtension]
                             withExtension:assetFilePath.pathExtension];
  if (!url) {
    *error = [FWFWebViewHostApiImpl errorForURLString:assetFilePath];
  } else {
    [[self webViewForIdentifier:instanceId] loadFileURL:url
                                allowingReadAccessToURL:[url URLByDeletingLastPathComponent]];
  }
}

- (void)loadFileForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                 fileURL:(nonnull NSString *)url
                           readAccessURL:(nonnull NSString *)readAccessUrl
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  NSURL *fileURL = [NSURL fileURLWithPath:url isDirectory:NO];
  NSURL *readAccessNSURL = [NSURL fileURLWithPath:readAccessUrl isDirectory:YES];

  if (!fileURL) {
    *error = [FWFWebViewHostApiImpl errorForURLString:url];
  } else if (!readAccessNSURL) {
    *error = [FWFWebViewHostApiImpl errorForURLString:readAccessUrl];
  } else {
    [[self webViewForIdentifier:instanceId] loadFileURL:fileURL
                                allowingReadAccessToURL:readAccessNSURL];
  }
}

- (void)loadHTMLForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                              HTMLString:(nonnull NSString *)string
                                 baseURL:(nullable NSString *)baseUrl
                                   error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:instanceId] loadHTMLString:string
                                                 baseURL:[NSURL URLWithString:baseUrl]];
}

- (void)reloadWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                              error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  [[self webViewForIdentifier:instanceId] reload];
}

- (void)
    setAllowsBackForwardForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                                       isAllowed:(nonnull NSNumber *)allow
                                           error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                     error {
  [[self webViewForIdentifier:instanceId] setAllowsBackForwardNavigationGestures:allow.boolValue];
}

- (void)
    setNavigationDelegateForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                               delegateIdentifier:(nullable NSNumber *)navigationDelegateInstanceId
                                            error:
                                                (FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                    error {
  id<WKNavigationDelegate> navigationDelegate = (id<WKNavigationDelegate>)[self.instanceManager
      instanceForIdentifier:navigationDelegateInstanceId.longValue];
  [[self webViewForIdentifier:instanceId] setNavigationDelegate:navigationDelegate];
}

- (void)setUIDelegateForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                           delegateIdentifier:(nullable NSNumber *)uiDelegateInstanceId
                                        error:(FlutterError *_Nullable __autoreleasing *_Nonnull)
                                                  error {
  id<WKUIDelegate> navigationDelegate =
      (id<WKUIDelegate>)[self.instanceManager instanceForIdentifier:uiDelegateInstanceId.longValue];
  [[self webViewForIdentifier:instanceId] setUIDelegate:navigationDelegate];
}

- (nullable NSString *)
    titleForWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                            error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  return [[self webViewForIdentifier:instanceId] title];
}
@end
