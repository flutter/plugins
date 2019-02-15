#import "ImagePickerPlugin.h"
#import <XCTest/XCTest.h>

@interface ImagePickerTests : XCTestCase @end

static CGSize SwappedSize(CGSize size) {
  return CGSizeMake(size.height, size.width);
}

static CGRect SwappedRect(CGRect rect) {
  return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

@implementation ImagePickerTests

- (void)doCheckOriginalSize:(CGSize)originalSize
                   maxWidth:(NSNumber*)maxWidth
                  maxHeight:(NSNumber*)maxHeight
                       crop:(BOOL)crop
                       size:(CGSize)expectedSize
                   drawRect:(CGRect)expectedDrawRect
{
  {
    CGSize size;
    CGRect drawRect;
    [FLTImagePickerPlugin getSize:&size
                         drawRect:&drawRect
                     originalSize:originalSize
                         maxWidth:maxWidth
                        maxHeight:maxHeight
                             crop:crop];
    XCTAssertEqual(size.width, expectedSize.width);
    XCTAssertEqual(size.height, expectedSize.height);
    XCTAssertEqual(drawRect.origin.x, expectedDrawRect.origin.x);
    XCTAssertEqual(drawRect.origin.y, expectedDrawRect.origin.y);
    XCTAssertEqual(drawRect.size.width, expectedDrawRect.size.width);
    XCTAssertEqual(drawRect.size.height, expectedDrawRect.size.height);
  }
}

- (void)checkOriginalSize:(CGSize)originalSize
                 maxWidth:(NSNumber*)maxWidth
                maxHeight:(NSNumber*)maxHeight
                     crop:(BOOL)crop
                     size:(CGSize)expectedSize
                 drawRect:(CGRect)expectedDrawRect
{
  [self doCheckOriginalSize:originalSize
                   maxWidth:maxWidth
                  maxHeight:maxHeight
                       crop:crop
                       size:expectedSize
                   drawRect:expectedDrawRect];
  
  [self doCheckOriginalSize:SwappedSize(originalSize)
                   maxWidth:maxHeight
                  maxHeight:maxWidth
                       crop:crop
                       size:SwappedSize(expectedSize)
                   drawRect:SwappedRect(expectedDrawRect)];
}

- (void)checkOriginalSize:(CGSize)originalSize
                 maxWidth:(NSNumber*)maxWidth
                maxHeight:(NSNumber*)maxHeight
                     size:(CGSize)expectedSize
                 drawRect:(CGRect)expectedDrawRect {
  [self checkOriginalSize:originalSize
                 maxWidth:maxWidth
                maxHeight:maxHeight
                     crop:NO
                     size:expectedSize
                 drawRect:expectedDrawRect];
  [self checkOriginalSize:originalSize
                 maxWidth:maxWidth
                maxHeight:maxHeight
                     crop:YES
                     size:expectedSize
                 drawRect:expectedDrawRect];
}

- (void)testEmpty {
  [self checkOriginalSize:CGSizeMake(0, 0)
                 maxWidth:nil
                maxHeight:nil
                     size:CGSizeMake(0, 0)
                 drawRect:CGRectMake(0, 0, 0, 0)];
  [self checkOriginalSize:CGSizeMake(50, 0)
                 maxWidth:nil
                maxHeight:nil
                     size:CGSizeMake(50, 0)
                 drawRect:CGRectMake(0, 0, 50, 0)];
  [self checkOriginalSize:CGSizeMake(0, 0)
                 maxWidth:@50
                maxHeight:nil
                     size:CGSizeMake(0, 0)
                 drawRect:CGRectMake(0, 0, 0, 0)];
  [self checkOriginalSize:CGSizeMake(100, 0)
                 maxWidth:@50
                maxHeight:nil
                     size:CGSizeMake(50, 0)
                 drawRect:CGRectMake(0, 0, 50, 0)];
}

- (void)testNoLimits {
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:nil
                maxHeight:nil
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
}

- (void)testOnlyWidth {
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@220
                maxHeight:nil
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@200
                maxHeight:nil
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@100
                maxHeight:nil
                     size:CGSizeMake(100, 150)
                 drawRect:CGRectMake(0, 0, 100, 150)];
}

- (void)testOnlyHeight {
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:nil
                maxHeight:@320
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:nil
                maxHeight:@300
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:nil
                maxHeight:@100
                     size:CGSizeMake(67, 100)
                 drawRect:CGRectMake(0, 0, 67, 100)];
}

- (void)testLoose {
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@220
                maxHeight:@320
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@200
                maxHeight:@320
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@220
                maxHeight:@300
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@200
                maxHeight:@300
                     size:CGSizeMake(200, 300)
                 drawRect:CGRectMake(0, 0, 200, 300)];
}

- (void)testFit {
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@200
                maxHeight:@250
                     crop:NO
                     size:CGSizeMake(167, 250)
                 drawRect:CGRectMake(0, 0, 167, 250)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@100
                maxHeight:@250
                     crop:NO
                     size:CGSizeMake(100, 150)
                 drawRect:CGRectMake(0, 0, 100, 150)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@150
                maxHeight:@100
                     crop:NO
                     size:CGSizeMake(67, 100)
                 drawRect:CGRectMake(0, 0, 67, 100)];
}

- (void)testCrop {
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@200
                maxHeight:@250
                     crop:YES
                     size:CGSizeMake(200, 250)
                 drawRect:CGRectMake(0, -25, 200, 300)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@100
                maxHeight:@250
                     crop:YES
                     size:CGSizeMake(100, 250)
                 drawRect:CGRectMake(-33.5, 0, 167, 250)];
  [self checkOriginalSize:CGSizeMake(200, 300)
                 maxWidth:@150
                maxHeight:@100
                     crop:YES
                     size:CGSizeMake(150, 100)
                 drawRect:CGRectMake(0, -62.5, 150, 225)];
}

@end
