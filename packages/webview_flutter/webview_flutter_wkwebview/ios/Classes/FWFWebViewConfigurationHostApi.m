// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FWFWebViewConfigurationHostApi.h"
#import "FWFDataConverters.h"
#import "FWFWebViewConfigurationHostApi.h"

@interface FWFWebViewConfigurationFlutterApiImpl ()
// BinaryMessenger and InstanceManager must be weak to prevent a circular reference
// with the objects it stores.
@property(nonatomic, weak) FWFInstanceManager *instanceManager;
@end

@implementation FWFWebViewConfigurationFlutterApiImpl
- (instancetype)initWithBinaryMessenger:(id<FlutterBinaryMessenger>)binaryMessenger
                        instanceManager:(FWFInstanceManager *)instanceManager {
  self = [self initWithBinaryMessenger:binaryMessenger];
  if (self) {
    _instanceManager = instanceManager;
  }
  return self;
}

- (void)createWithConfiguration:(WKWebViewConfiguration *)configuration
                     completion:(void (^)(NSError *_Nullable))completion {
  long identifier = [self.instanceManager addHostCreatedInstance:configuration];
  [self createWithIdentifier:@(identifier) completion:completion];
}
@end

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

- (WKWebViewConfiguration *)webViewConfigurationForIdentifier:(NSNumber *)identifier {
  return (WKWebViewConfiguration *)[self.instanceManager
      instanceForIdentifier:identifier.longValue];
}

- (void)createWithIdentifier:(nonnull NSNumber *)identifier
                       error:(FlutterError *_Nullable *_Nonnull)error {
  WKWebViewConfiguration *webViewConfiguration = [[WKWebViewConfiguration alloc] init];
  [self.instanceManager addDartCreatedInstance:webViewConfiguration
                                withIdentifier:identifier.longValue];
}

- (void)createFromWebViewWithIdentifier:(nonnull NSNumber *)identifier
                      webViewIdentifier:(nonnull NSNumber *)webViewIdentifier
                                  error:(FlutterError *_Nullable __autoreleasing *_Nonnull)error {
  WKWebView *webView =
      (WKWebView *)[self.instanceManager instanceForIdentifier:webViewIdentifier.longValue];
  [self.instanceManager addDartCreatedInstance:webView.configuration
                                withIdentifier:identifier.longValue];
}

- (void)setAllowsInlineMediaPlaybackForConfigurationWithIdentifier:(nonnull NSNumber *)identifier
                                                         isAllowed:(nonnull NSNumber *)allow
                                                             error:
                                                                 (FlutterError *_Nullable *_Nonnull)
                                                                     error {
  [[self webViewConfigurationForIdentifier:identifier]
      setAllowsInlineMediaPlayback:allow.boolValue];
}

- (void)
    setMediaTypesRequiresUserActionForConfigurationWithIdentifier:(nonnull NSNumber *)identifier
                                                         forTypes:
                                                             (nonnull NSArray<
                                                                 FWFWKAudiovisualMediaTypeEnumData
                                                                     *> *)types
                                                            error:
                                                                (FlutterError *_Nullable *_Nonnull)
                                                                    error {
  NSAssert(types.count, @"Types must not be empty.");

  WKWebViewConfiguration *configuration =
      (WKWebViewConfiguration *)[self webViewConfigurationForIdentifier:identifier];
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
