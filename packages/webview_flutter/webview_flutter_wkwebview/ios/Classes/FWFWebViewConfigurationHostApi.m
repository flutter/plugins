// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFWebViewConfigurationHostApi.h"
#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFWebViewConfigurationHostApiImpl ()
@property(nonatomic) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebViewConfigurationHostApiImpl
- (instancetype)initWithInstanceManager:(FWFInstanceManager *)instanceManager {
  self = [self init];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (WKWebViewConfiguration *)webViewConfigurationForIdentifier:(NSNumber *)instanceId {
  return (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:instanceId.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)instanceId
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
  [self.instanceManager addInstance:webViewConfiguration withIdentifier:instanceId.longValue];
}

- (void)createFromWebViewWithIdentifier:(nonnull NSNumber *)instanceId
                      webViewIdentifier:(nonnull NSNumber *)webViewInstanceId
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  WKWebView *webView =
      (WKWebView *)[self.instanceManager instanceForIdentifier:webViewInstanceId.longValue];
  [self.instanceManager addInstance:webView.configuration withIdentifier:instanceId.longValue];
}

- (void)setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                                                         isAllowed:(nonnull NSNumber *)allow
                                                             error:
                                                                 (FlutterError *_Nullable *_Nonnull)
                                                                     error {
  [[self webViewConfigurationForIdentifier:instanceId]
      setAllowsInlineMediaPlayback:allow.boolValue];
}

- (void)
    setMediaTypesRequiresUserActionForConfigurationWithIdentifier:(nonnull NSNumber *)instanceId
                                                         forTypes:
                                                             (nonnull NSArray<
                                                                 FWFWKAudiovisualMediaTypeEnumData
                                                                     *> *)types
                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  NSAssert(types.count, @"Types must not be empty.");

  WKWebViewConfiguration *configuration =
      (WKWebViewConfiguration *)[self webViewConfigurationForIdentifier:instanceId];
  if (@available(iOS 10.0, *)) {
    WKAudiovisualMediaTypes typesInt = 0;
    for (FWFWKAudiovisualMediaTypeEnumData *data in types) {
      typesInt |= FWFWKAudiovisualMediaTypeFromEnumData(data);
    }
    [configuration setMediaTypesRequiringUserActionForPlayback:typesInt];
  } else {
    for (FWFWKAudiovisualMediaTypeEnumData *data in types) {
      switch (data.value) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case FWFWKAudiovisualMediaTypeEnumNone:
          configuration.requiresUserActionForMediaPlayback = false;
          break;
        case FWFWKAudiovisualMediaTypeEnumAudio:
        case FWFWKAudiovisualMediaTypeEnumVideo:
        case FWFWKAudiovisualMediaTypeEnumAll:
          configuration.requiresUserActionForMediaPlayback = true;
          break;
#pragma clang diagnostic pop
      }
    }
  }
}
@end
