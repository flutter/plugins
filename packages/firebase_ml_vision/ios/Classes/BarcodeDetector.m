#import "FirebaseMlVisionPlugin.h"

@implementation BarcodeDetector
static FIRVisionBarcodeDetector *barcodeDetector;

+ (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result {
  if (barcodeDetector == nil) {
    FIRVision *vision = [FIRVision vision];
    barcodeDetector = [vision barcodeDetector];
  }
  
  [barcodeDetector
   detectInImage:image
   completion:^(NSArray<FIRVisionBarcode *> * _Nullable barcodes, NSError * _Nullable error) {
     if (error) {
       [FLTFirebaseMlVisionPlugin handleError:error result:result];
       return;
     } else if (!barcodes) {
       result(@[]);
       return;
     }
     
     NSMutableArray *blocks = [NSMutableArray array];
     for (FIRVisionBarcode *barcode in barcodes) {
       NSDictionary *barcodeData = [BarcodeDetector getBarcodeData:barcode];
       [blocks addObject:barcodeData];
     }
     
     result(blocks);
   }];
}

+ (void)close {
  barcodeDetector = nil;
}


+ (NSDictionary *)getBarcodeData:(FIRVisionBarcode *)barcode {
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
