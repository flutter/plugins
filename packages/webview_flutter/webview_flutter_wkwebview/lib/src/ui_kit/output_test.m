
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFScrollViewHostApiTests : XCTestCase
@end

@implementation FWFScrollViewHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFScrollViewHostApiImpl *hostApi =
      [[FWFScrollViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
      
      UIScrollView                                                          
          * scrollView
      = (
          
              
              UIScrollView 
                  *)[instanceManager instanceForIdentifier:0];
  
  
  XCTAssertTrue(
      [scrollView isKindOfClass:[UIScrollView
                                                                                          class]]);
  
  XCTAssertNil(error);
}


- (void)test GetContentOffset {
  
    
    UIScrollView
     *mockScrollView = OCMClassMock([
  
  
  UIScrollView
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockScrollView withIdentifier:0];

  FWFScrollViewHostApiImpl *hostApi =
      [[FWFScrollViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi contentOffsetForScrollViewWithIdentifier:@0
                            
                               error:&error];
  OCMVerify([mockScrollView getContentOffset

      
  ]);
  XCTAssertNil(error);
}

- (void)test ScrollBy {
  
    
    UIScrollView
     *mockScrollView = OCMClassMock([
  
  
  UIScrollView
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockScrollView withIdentifier:0];

  FWFScrollViewHostApiImpl *hostApi =
      [[FWFScrollViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi scrollByForScrollViewWithIdentifier:@0
                            
                            offset:aValue
                               
                               error:&error];
  OCMVerify([mockScrollView scrollBy

:aValue
      
      
  ]);
  XCTAssertNil(error);
}

- (void)test SetContentOffset {
  
    
    UIScrollView
     *mockScrollView = OCMClassMock([
  
  
  UIScrollView
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockScrollView withIdentifier:0];

  FWFScrollViewHostApiImpl *hostApi =
      [[FWFScrollViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setContentOffsetForScrollViewWithIdentifier:@0
                            
                            offset:aValue
                               
                               error:&error];
  OCMVerify([mockScrollView setContentOffset

:aValue
      
      
  ]);
  XCTAssertNil(error);
}

@end

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import Flutter;
@import XCTest;
@import webview_flutter_wkwebview;

#import <OCMock/OCMock.h>

@interface FWFUIViewHostApiTests : XCTestCase
@end

@implementation FWFUIViewHostApiTests
- (void)testCreateWithIdentifier {
  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  FWFUIViewHostApiImpl *hostApi =
      [[FWFUIViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi createWithIdentifier:@0 error:&error];
  
      
      UIView                                                          
          * uIView
      = (
          
              
              UIView 
                  *)[instanceManager instanceForIdentifier:0];
  
  
  XCTAssertTrue(
      [uIView isKindOfClass:[UIView
                                                                                          class]]);
  
  XCTAssertNil(error);
}


- (void)test SetBackgroundColor {
  
    
    UIView
     *mockUIView = OCMClassMock([
  
  
  UIView
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUIView withIdentifier:0];

  FWFUIViewHostApiImpl *hostApi =
      [[FWFUIViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setBackgroundColorForViewWithIdentifier:@0
                            
                            color:aValue
                               
                               error:&error];
  OCMVerify([mockUIView setBackgroundColor

:aValue
      
      
  ]);
  XCTAssertNil(error);
}

- (void)test SetOpaque {
  
    
    UIView
     *mockUIView = OCMClassMock([
  
  
  UIView
  
 class]);

  FWFInstanceManager *instanceManager = [[FWFInstanceManager alloc] init];
  [instanceManager addInstance:mockUIView withIdentifier:0];

  FWFUIViewHostApiImpl *hostApi =
      [[FWFUIViewHostApiImpl alloc]
          initWithInstanceManager:instanceManager];

  FlutterError *error;
  [hostApi setOpaqueForViewWithIdentifier:@0
                            
                            opaque:aValue
                               
                               error:&error];
  OCMVerify([mockUIView setOpaque

:aValue
      
      
  ]);
  XCTAssertNil(error);
}

@end
