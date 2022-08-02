// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import file_selector_ios;
@import file_selector_ios.Test;
@import XCTest;

#import <OCMock/OCMock.h>

@interface FileSelectorTests : XCTestCase

@end

@implementation FileSelectorTests

- (void)testPickerPresents {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  id mockPresentingVC = OCMClassMock([UIViewController class]);
  plugin.documentPickerViewControllerOverride = picker;
  plugin.presentingViewControllerOverride = mockPresentingVC;

  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:nil
                                                     allowMultiSelection:@NO]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error){
                          }];

  XCTAssertEqualObjects(picker.delegate, plugin);
  OCMVerify(times(1), [mockPresentingVC presentViewController:picker
                                                     animated:[OCMArg any]
                                                   completion:[OCMArg any]]);
}

- (void)testReturnsPickedFiles {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  XCTestExpectation *completionWasCalled = [[XCTestExpectation alloc] init];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:nil
                                                     allowMultiSelection:@YES]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error) {
                            NSArray *expectedPaths = @[ @"/file1.txt", @"/file2.txt" ];
                            XCTAssertEqualObjects(paths, expectedPaths);
                            [completionWasCalled fulfill];
                          }];
  [plugin documentPicker:picker
      didPickDocumentsAtURLs:@[
        [NSURL URLWithString:@"file:///file1.txt"], [NSURL URLWithString:@"file:///file2.txt"]
      ]];
  [self waitForExpectations:@[ completionWasCalled ] timeout:1.0];
  XCTAssertNil(plugin.pendingCompletion);
}

- (void)testReturnsPickedFileLegacy {
  // Tests that it handles the pre iOS 11 UIDocumentPickerDelegate method.
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  XCTestExpectation *completionWasCalled = [[XCTestExpectation alloc] init];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  plugin.documentPickerViewControllerOverride = picker;
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:nil
                                                     allowMultiSelection:@NO]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error) {
                            NSArray *expectedPaths = @[ @"/file1.txt" ];
                            XCTAssertEqualObjects(paths, expectedPaths);
                            [completionWasCalled fulfill];
                          }];
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
  [plugin documentPicker:picker didPickDocumentAtURL:[NSURL URLWithString:@"file:///file1.txt"]];
#pragma GCC diagnostic pop
  [self waitForExpectations:@[ completionWasCalled ] timeout:1.0];
  XCTAssertNil(plugin.pendingCompletion);
}

- (void)testCancellingPickerReturnsNil {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  plugin.documentPickerViewControllerOverride = picker;

  XCTestExpectation *completionWasCalled = [[XCTestExpectation alloc] init];
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:nil
                                                     allowMultiSelection:@NO]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error) {
                            XCTAssertEqual(paths.count, 0);
                            [completionWasCalled fulfill];
                          }];
  [plugin documentPickerWasCancelled:picker];
  [self waitForExpectations:@[ completionWasCalled ] timeout:1.0];
  XCTAssertNil(plugin.pendingCompletion);
}

- (void)testOpenFileSelectorWithPendingCompletionReturnsError {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  plugin.pendingCompletion = ^(NSArray<NSString *> *paths, FlutterError *error) {
  };

  XCTestExpectation *completionWasCalled =
      [[XCTestExpectation alloc] initWithDescription:@"Completion was called"];
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:nil
                                                     allowMultiSelection:@NO]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error) {
                            XCTAssertNotNil(error);
                            [completionWasCalled fulfill];
                          }];

  [self waitForExpectations:@[ completionWasCalled ] timeout:1.0];
}

@end
