#import "FirebaseMlVisionPlugin.h"

@implementation TextDetector
static FIRVisionTextDetector *textDetector;

+ (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result {
  if (textDetector == nil) {
    FIRVision *vision = [FIRVision vision];
    textDetector = [vision textDetector];
  }

  [textDetector
      detectInImage:image
         completion:^(NSArray<id<FIRVisionText>> *_Nullable features, NSError *_Nullable error) {
           if (error) {
             [FLTFirebaseMlVisionPlugin handleError:error result:result];
             return;
           } else if (!features) {
             result(@[]);
             return;
           }

           NSMutableArray *blocks = [NSMutableArray array];
           for (id<FIRVisionText> feature in features) {
             NSMutableDictionary *blockData = [NSMutableDictionary dictionary];
             if ([feature isKindOfClass:[FIRVisionTextBlock class]]) {
               FIRVisionTextBlock *block = (FIRVisionTextBlock *)feature;

               [blockData addEntriesFromDictionary:[self getTextData:block.frame
                                                        cornerPoints:block.cornerPoints
                                                                text:block.text]];
               blockData[@"lines"] = [self getLineData:block.lines];
             } else if ([feature isKindOfClass:[FIRVisionTextLine class]]) {
               // We structure the return data to have the line be inside a FIRVisionTextBlock.
               FIRVisionTextLine *line = (FIRVisionTextLine *)feature;

               [blockData addEntriesFromDictionary:[self getTextData:line.frame
                                                        cornerPoints:line.cornerPoints
                                                                text:line.text]];
               NSArray<FIRVisionTextLine *> *lines = @[ line ];
               blockData[@"lines"] = [self getLineData:lines];
             } else if ([feature isKindOfClass:[FIRVisionTextElement class]]) {
               // We structure the return data to have the element inside a FIRVisionTextLine
               // that is inside a FIRVisionTextBlock.
               FIRVisionTextElement *element = (FIRVisionTextElement *)feature;

               [blockData addEntriesFromDictionary:[self getTextData:element.frame
                                                        cornerPoints:element.cornerPoints
                                                                text:element.text]];

               NSMutableDictionary *lineData = [NSMutableDictionary dictionary];
               [lineData addEntriesFromDictionary:[self getTextData:element.frame
                                                       cornerPoints:element.cornerPoints
                                                               text:element.text]];

               NSArray<FIRVisionTextElement *> *elements = @[ element ];
               lineData[@"elements"] = [self getElementData:elements];

               blockData[@"lines"] = lineData;
             }

             [blocks addObject:blockData];
           }

           result(blocks);
         }];
}

+ (void)close {
  textDetector = nil;
}

+ (NSDictionary *)getTextData:(CGRect)frame
                 cornerPoints:(NSArray<NSValue *> *)cornerPoints
                         text:(NSString *)text {
  __block NSMutableArray<NSArray *> *points = [NSMutableArray array];

  for (NSValue *point in points) {
    [points addObject:@[ @(((__bridge CGPoint *)point)->x), @(((__bridge CGPoint *)point)->y) ]];
  }

  return @{
    @"text" : text,
    @"left" : @((int)frame.origin.x),
    @"top" : @((int)frame.origin.y),
    @"width" : @((int)frame.size.width),
    @"height" : @((int)frame.size.height),
    @"points" : points,
  };
}

+ (NSMutableArray *)getLineData:(NSArray<FIRVisionTextLine *> *)lines {
  NSMutableArray *lineDataArray = [NSMutableArray array];

  for (FIRVisionTextLine *line in lines) {
    NSMutableDictionary *lineData = [NSMutableDictionary dictionary];
    [lineData addEntriesFromDictionary:[self getTextData:line.frame
                                            cornerPoints:line.cornerPoints
                                                    text:line.text]];
    lineData[@"elements"] = [self getElementData:line.elements];
    [lineDataArray addObject:lineData];
  }

  return lineDataArray;
}

+ (NSMutableArray *)getElementData:(NSArray<FIRVisionTextElement *> *)elements {
  NSMutableArray *elementDataArray = [NSMutableArray array];

  for (FIRVisionTextElement *element in elements) {
    [elementDataArray addObject:[self getTextData:element.frame
                                     cornerPoints:element.cornerPoints
                                             text:element.text]];
  }

  return elementDataArray;
}
@end
