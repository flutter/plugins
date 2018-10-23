#import "FirebaseMlVisionPlugin.h"

@implementation TextRecognizer
static FIRVisionTextRecognizer *recognizer;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRVision *vision = [FIRVision vision];
  recognizer = [vision onDeviceTextRecognizer];

  [recognizer processImage:image
                completion:^(FIRVisionText *_Nullable visionText, NSError *_Nullable error) {
                  if (error) {
                    [FLTFirebaseMlVisionPlugin handleError:error result:result];
                    return;
                  } else if (!visionText) {
                    result(@[]);
                    return;
                  }

                  NSMutableDictionary *visionTextData = [NSMutableDictionary dictionary];
                  visionTextData[@"text"] = visionText.text;

                  NSMutableArray *allBlockData = [NSMutableArray array];
                  for (FIRVisionTextBlock *block in visionText.blocks) {
                    NSMutableDictionary *blockData = [NSMutableDictionary dictionary];

                    [self addData:blockData
                          confidence:block.confidence
                        cornerPoints:block.cornerPoints
                               frame:block.frame
                           languages:block.recognizedLanguages
                                text:block.text];

                    NSMutableArray *allLineData = [NSMutableArray array];
                    for (FIRVisionTextLine *line in block.lines) {
                      NSMutableDictionary *lineData = [NSMutableDictionary dictionary];

                      [self addData:lineData
                            confidence:line.confidence
                          cornerPoints:line.cornerPoints
                                 frame:line.frame
                             languages:line.recognizedLanguages
                                  text:line.text];

                      NSMutableArray *allElementData = [NSMutableArray array];
                      for (FIRVisionTextElement *element in line.elements) {
                        NSMutableDictionary *elementData = [NSMutableDictionary dictionary];

                        [self addData:elementData
                              confidence:element.confidence
                            cornerPoints:element.cornerPoints
                                   frame:element.frame
                               languages:element.recognizedLanguages
                                    text:element.text];

                        [allElementData addObject:elementData];
                      }

                      lineData[@"elements"] = allElementData;
                      [allLineData addObject:lineData];
                    }

                    blockData[@"lines"] = allLineData;
                    [allBlockData addObject:blockData];
                  }

                  visionTextData[@"blocks"] = allBlockData;
                  result(visionTextData);
                }];
}

+ (void)addData:(NSMutableDictionary *)addTo
      confidence:(NSNumber *)confidence
    cornerPoints:(NSArray<NSValue *> *)cornerPoints
           frame:(CGRect)frame
       languages:(NSArray<FIRVisionTextRecognizedLanguage *> *)languages
            text:(NSString *)text {
  __block NSMutableArray<NSArray *> *points = [NSMutableArray array];

  for (NSValue *point in points) {
    [points addObject:@[ @(((__bridge CGPoint *)point)->x), @(((__bridge CGPoint *)point)->y) ]];
  }

  __block NSMutableArray<NSDictionary *> *allLanguageData = [NSMutableArray array];
  for (FIRVisionTextRecognizedLanguage *language in languages) {
    [allLanguageData addObject:@{@"languageCode" : language.languageCode}];
  }

  [addTo addEntriesFromDictionary:@{
    @"confidence" : confidence ? confidence : [NSNull null],
    @"points" : points,
    @"left" : @((int)frame.origin.x),
    @"top" : @((int)frame.origin.y),
    @"width" : @((int)frame.size.width),
    @"height" : @((int)frame.size.height),
    @"recognizedLanguages" : allLanguageData,
    @"text" : text,
  }];
}
@end
