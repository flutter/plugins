// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JavaScriptChannelHandler.h"

@implementation FLTJavaScriptChannel {
  FlutterMethodChannel* _methodChannel;
  NSString* _javaScriptChannelName;
}

- (instancetype)initWithMethodChannel:(FlutterMethodChannel*)methodChannel
                javaScriptChannelName:(NSString*)javaScriptChannelName {
  self = [super init];
  NSAssert(methodChannel != nil, @"methodChannel must not be null.");
  NSAssert(javaScriptChannelName != nil, @"javaScriptChannelName must not be null.");
  if (self) {
    _methodChannel = methodChannel;
    _javaScriptChannelName = javaScriptChannelName;
  }
  return self;
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
  NSAssert(_methodChannel != nil, @"Can't send a message to an unitialized JavaScript channel.");
  NSAssert(_javaScriptChannelName != nil,
           @"Can't send a message to an unitialized JavaScript channel.");
  NSDictionary* arguments = @{
    @"channel" : _javaScriptChannelName,
    @"message" : [NSString stringWithFormat:@"%@", message.body]
  };
  [_methodChannel invokeMethod:@"javascriptChannelMessage" arguments:arguments];
}

@end
