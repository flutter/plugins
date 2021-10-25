//
//  PickerSaveImageToPathOperationTests.m
//  RunnerTests
//
//  Created by Giang Long Tran on 25.10.21.
//  Copyright © 2021 The Flutter Authors. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@import image_picker;

@interface PickerSaveImageToPathOperationTests : XCTestCase

@end

@implementation PickerSaveImageToPathOperationTests

- (void)testSaveWebPImage API_AVAILABLE(ios(14));  {
    // Read item from bundle
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"webpImage" withExtension:@"webp"]];
    
    PHPickerResult *result = [self createPickerResult:itemProvider withIdentifier:UTTypeWebP.identifier];
    
    [self testOperationWithPickerResult:result];
}

- (PHPickerResult *)createPickerResult:(NSItemProvider*)itemProvider withIdentifier:(NSString*)identifier API_AVAILABLE(ios(14)); {
    PHPickerResult *result = OCMClassMock([PHPickerResult class]);
    
    OCMStub([result itemProvider]).andReturn(itemProvider);
    OCMStub([result assetIdentifier]).andReturn(identifier);
    
    return result;
}

- (void)testOperationWithPickerResult:(PHPickerResult *)result API_AVAILABLE(ios(14)); {
    XCTestExpectation *pathExpectation = [self expectationWithDescription:@"Path was created"];
    
    FLTPHPickerSaveImageToPathOperation *operation = [[FLTPHPickerSaveImageToPathOperation alloc]
                                                      initWithResult:result
                                                      maxHeight:@100
                                                      maxWidth:@100
                                                      desiredImageQuality:@100
                                                      savedPathBlock:^(NSString *savedPath) {
        if (savedPath != nil) {
            [pathExpectation fulfill];
        }
    }];
    
    [operation start];
    [self waitForExpectations:@[pathExpectation] timeout:30];
}

@end
