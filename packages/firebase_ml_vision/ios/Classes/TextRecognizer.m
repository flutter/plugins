#import "FirebaseMlVisionPlugin.h"

@interface TextRecognizer ()
@property FIRVisionTextRecognizer *recognizer;
@end

@implementation TextRecognizer
- (instancetype)initWithVision:(FIRVision *)vision options:(NSDictionary *)options {
  self = [super init];
  if (self) {
    if ([@"onDevice" isEqualToString:options[@"modelType"]]) {
      _recognizer = [vision onDeviceTextRecognizer];
    } else if ([@"cloud" isEqualToString:options[@"modelType"]]) {
      _recognizer = [vision cloudTextRecognizer];
    } else {
      NSString *reason =
          [NSString stringWithFormat:@"Invalid model type: %@", options[@"modelType"]];
      @throw [[NSException alloc] initWithName:NSInvalidArgumentException
                                        reason:reason
                                      userInfo:nil];
    }
  }
  return self;
}

- (void)handleDetection:(FIRVisionImage *)image result:(FlutterResult)result {
  [_recognizer processImage:image
                 completion:^(FIRVisionText *_Nullable visionText, NSError *_Nullable error) {
                   if (error) {
                     [FLTFirebaseMlVisionPlugin handleError:error result:result];
                     return;
                   } else if (!visionText) {
                     result(@{@"text" : @"", @"blocks" : @[]});
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

- (void)addData:(NSMutableDictionary *)addTo
      confidence:(NSNumber *)confidence
    cornerPoints:(NSArray<NSValue *> *)cornerPoints
           frame:(CGRect)frame
       languages:(NSArray<FIRVisionTextRecognizedLanguage *> *)languages
            text:(NSString *)text {
  __block NSMutableArray<NSArray *> *points = [NSMutableArray array];

  for (NSValue *point in cornerPoints) {
    [points addObject:@[ @(point.CGPointValue.x), @(point.CGPointValue.y) ]];
  }

  __block NSMutableArray<NSDictionary *> *allLanguageData = [NSMutableArray array];
  for (FIRVisionTextRecognizedLanguage *language in languages) {
    [allLanguageData addObject:@{
      @"languageCode" : language.languageCode ? language.languageCode : [NSNull null]
    }];
  }

  [addTo addEntriesFromDictionary:@{
    @"confidence" : confidence ? confidence : [NSNull null],
    @"points" : points,
    @"left" : @(frame.origin.x),
    @"top" : @(frame.origin.y),
    @"width" : @(frame.size.width),
    @"height" : @(frame.size.height),
    @"recognizedLanguages" : allLanguageData,
    @"text" : text,
  }];
}
@end
