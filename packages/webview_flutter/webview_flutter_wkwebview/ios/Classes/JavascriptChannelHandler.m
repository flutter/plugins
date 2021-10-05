// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "JavascriptChannelHandler.h"

@implementation FLTJavascriptChannel {
  FlutterMethodChannel* _methodChannel;
  NSString* _javascriptChannelName;
}

- (instancetype)initWithMethodChannel:(FlutterMethodChannel*)methodChannel
                javascriptChannelName:(NSString*)javascriptChannelName {
  self = [super init];
  NSAssert(methodChannel != nil, @"methodChannel must not be null.");
  NSAssert(javascriptChannelName != nil, @"javascriptChannelName must not be null.");
  if (self) {
    _methodChannel = methodChannel;
    _javascriptChannelName = javascriptChannelName;
  }
  return self;
}

- (void)userContentController:(WKUserContentController*)userContentController
      didReceiveScriptMessage:(WKScriptMessage*)message {
  NSAssert(_methodChannel != nil, @"Can't send a message to an unitialized JavaScript channel.");
  NSAssert(_javascriptChannelName != nil,
           @"Can't send a message to an unitialized JavaScript channel.");
  NSDictionary* arguments = @{
    @"channel" : _javascriptChannelName,
    @"message" : [NSString stringWithFormat:@"%@", message.body]
  };
  [_methodChannel invokeMethod:@"javascriptChannelMessage" arguments:arguments];
}

@end
