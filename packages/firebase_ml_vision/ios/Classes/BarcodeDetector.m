#import "FirebaseMlVisionPlugin.h"

@implementation BarcodeDetector
static FIRVisionBarcodeDetector *barcodeDetector;

+ (id)sharedInstance {
  static BarcodeDetector *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (void)respondToCallback:(OperationFinishedCallback)callback withData:(id _Nullable) data {
  callback(data, @"barcode");
}

- (void)handleDetection:(FIRVisionImage *)image finishedCallback:(OperationFinishedCallback)callback errorCallback:(OperationErrorCallback)errorCallback {
  if (barcodeDetector == nil) {
    FIRVision *vision = [FIRVision vision];
    barcodeDetector = [vision barcodeDetector];
  }
  
  [barcodeDetector
   detectInImage:image
   completion:^(NSArray<FIRVisionBarcode *> * _Nullable barcodes, NSError * _Nullable error) {
     if (error) {
       [FLTFirebaseMlVisionPlugin handleError:error finishedCallback:errorCallback];
       return;
     } else if (!barcodes) {
       [self respondToCallback:callback withData:@[]];
       return;
     }
     
     NSMutableArray *blocks = [NSMutableArray array];
     for (FIRVisionBarcode *barcode in barcodes) {
       NSDictionary *barcodeData = [self getBarcodeData:barcode];
       [blocks addObject:barcodeData];
     }
     [self respondToCallback:callback withData:blocks];
   }];
}

- (void)close {
  barcodeDetector = nil;
}

- (NSDictionary *)getBarcodeData:(FIRVisionBarcode *)barcode {
  CGRect frame = barcode.frame;
  NSString *displayValue = barcode.displayValue == nil ? @"" : barcode.displayValue;
  NSString *rawValue = barcode.rawValue == nil ? @"" : barcode.rawValue;
  return @{
    @"left" : @((int)frame.origin.x),
    @"top" : @((int)frame.origin.y),
    @"width" : @((int)frame.size.width),
    @"height" : @((int)frame.size.height),
    @"barcode_display_value" : displayValue,
    @"barcode_raw_value" : rawValue
  };
}
@end
