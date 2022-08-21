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

  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:@[]
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
  XCTestExpectation *completionWasCalled = [self expectationWithDescription:@"completion"];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  plugin.documentPickerViewControllerOverride = picker;
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:@[]
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
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testReturnsPickedFileLegacy {
  // Tests that it handles the pre iOS 11 UIDocumentPickerDelegate method.
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  XCTestExpectation *completionWasCalled = [self expectationWithDescription:@"completion"];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  plugin.documentPickerViewControllerOverride = picker;
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:@[]
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
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)testCancellingPickerReturnsNil {
  FFSFileSelectorPlugin *plugin = [[FFSFileSelectorPlugin alloc] init];
  UIDocumentPickerViewController *picker =
      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[]
                                                             inMode:UIDocumentPickerModeImport];
  plugin.documentPickerViewControllerOverride = picker;

  XCTestExpectation *completionWasCalled = [self expectationWithDescription:@"completion"];
  [plugin openFileSelectorWithConfig:[FFSFileSelectorConfig makeWithUtis:@[]
                                                     allowMultiSelection:@NO]
                          completion:^(NSArray<NSString *> *paths, FlutterError *error) {
                            XCTAssertEqual(paths.count, 0);
                            [completionWasCalled fulfill];
                          }];
  [plugin documentPickerWasCancelled:picker];
  [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

@end
