// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JavaScriptChannelHandler.h"

@interface FLTJavaScriptChannel ()

@property(strong, nonatomic) FlutterMethodChannel *methodChannel;
@property(copy, nonatomic) NSString *javaScriptChannelName;

@end

@implementation FLTJavaScriptChannel

- (instancetype)initWithMethodChannel:(FlutterMethodChannel *)methodChannel
                javaScriptChannelName:(NSString *)javaScriptChannelName {
  self = [super init];
  NSAssert(methodChannel != nil, @"methodChannel must not be null.");
  NSAssert(javaScriptChannelName != nil, @"javaScriptChannelName must not be null.");
  if (self) {
    self.methodChannel = methodChannel;
    self.javaScriptChannelName = javaScriptChannelName;
  }
  return self;
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
  NSAssert(self.methodChannel != nil,
           @"Can't send a message to an unitialized JavaScript channel.");
  NSAssert(self.javaScriptChannelName != nil,
           @"Can't send a message to an unitialized JavaScript channel.");
  NSDictionary *arguments = @{
    @"channel" : self.javaScriptChannelName,
    @"message" : [NSString stringWithFormat:@"%@", message.body]
  };
  [self.methodChannel invokeMethod:@"javascriptChannelMessage" arguments:arguments];
}

@end
