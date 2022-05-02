/*iterate classes class*/
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWF__customValues_nameWithoutPrefix__HostApiTests : XCTestCase
@end

@implementation FWF__customValues_nameWithoutPrefix__HostApiTests
/*iterate methods method*/
- (void)test/*replace :case=pascal name*/methodName/**/ {
  FWFWebView *mock__class_customValues_nameWithoutPrefix__ = OCMClassMock([
  /*if class_customValues_isProtocol*/
  FWF__customValues_nameWithoutPrefix__
  /**/
  /*if! class_customValues_isProtocol*/
  __name__
  /**/
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mock__class_customValues_nameWithoutPrefix__ withIdentifier:0];

  FWF__class_customValues_nameWithoutPrefix__HostApiImpl *hostApi =
      [[FWF__class_customValues_nameWithoutPrefix__HostApiImpl alloc] initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi __customValues_objcName__
  /*iterate :end=1 parameters parameter*/
  :aValue
  /**/
  /*iterate :start=1 parameters parameter*/
  __name__:aValue
  /**/
  error:&error];
  OCMVerify([mockWebView __name__:
  /*iterate :end=1 parameters parameter*/
  :aValue
  /**/
  /*iterate :start=1 parameters parameter*/
  __name__:aValue
  /**/
  ]);
  XCTAssertNil(error);
}
/**/
@end
/**/