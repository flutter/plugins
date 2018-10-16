#import "FirebaseMlVisionPlugin.h"

@implementation CloudDocumentTextRecognizer
static FIRVisionDocumentTextRecognizer *recognizer;

+ (void)handleDetection:(FIRVisionImage *)image
                options:(NSDictionary *)options
                 result:(FlutterResult)result {
  FIRVision *vision = [FIRVision vision];
  recognizer = [vision
      cloudDocumentTextRecognizerWithOptions:[CloudDocumentTextRecognizer parseOptions:options]];

  [recognizer
      processImage:image
        completion:^(FIRVisionDocumentText *_Nullable documentText, NSError *_Nullable error) {
          if (error) {
            [FLTFirebaseMlVisionPlugin handleError:error result:result];
            return;
          } else if (!documentText) {
            result(@[]);
            return;
          }

          NSMutableDictionary *documentData = [NSMutableDictionary dictionary];
          documentData[@"text"] = documentText.text;

          NSMutableArray *allBlockData = [NSMutableArray array];
          // TODO(bmparr): Add block style parameter when it is available on android.
          for (FIRVisionDocumentTextBlock *block in documentText.blocks) {
            NSMutableDictionary *blockData = [NSMutableDictionary dictionary];

            [self addData:blockData
                confidence:block.confidence
                     frame:block.frame
                 languages:block.recognizedLanguages
                      text:block.text];

            NSMutableArray *allParagraphData = [NSMutableArray array];
            for (FIRVisionDocumentTextParagraph *paragraph in block.paragraphs) {
              NSMutableDictionary *paragraphData = [NSMutableDictionary dictionary];

              [self addData:paragraphData
                  confidence:paragraph.confidence
                       frame:paragraph.frame
                   languages:paragraph.recognizedLanguages
                        text:paragraph.text];

              NSMutableArray *allWordData = [NSMutableArray array];
              for (FIRVisionDocumentTextWord *word in paragraph.words) {
                NSMutableDictionary *wordData = [NSMutableDictionary dictionary];

                [self addData:wordData
                    confidence:word.confidence
                         frame:word.frame
                     languages:word.recognizedLanguages
                          text:word.text];

                NSMutableArray *allSymbolData = [NSMutableArray array];
                for (FIRVisionDocumentTextSymbol *symbol in word.symbols) {
                  NSMutableDictionary *symbolData = [NSMutableDictionary dictionary];

                  [self addData:symbolData
                      confidence:symbol.confidence
                           frame:symbol.frame
                       languages:symbol.recognizedLanguages
                            text:symbol.text];

                  [allSymbolData addObject:symbolData];
                }

                wordData[@"symbols"] = allSymbolData;
                [allWordData addObject:wordData];
              }

              paragraphData[@"words"] = allWordData;
              [allParagraphData addObject:paragraphData];
            }

            blockData[@"paragraphs"] = allParagraphData;
            [allBlockData addObject:blockData];
          }

          documentData[@"blocks"] = allBlockData;
          result(documentData);
        }];
}

+ (void)addData:(NSMutableDictionary *)addTo
     confidence:(NSNumber *)confidence
          frame:(CGRect)frame
      languages:(NSArray<FIRVisionTextRecognizedLanguage *> *)languages
           text:(NSString *)text {
  __block NSMutableArray<NSDictionary *> *allLanguageData = [NSMutableArray array];
  for (FIRVisionTextRecognizedLanguage *language in languages) {
    [allLanguageData addObject:@{@"languageCode" : language.languageCode}];
  }
  [addTo addEntriesFromDictionary:@{
    @"confidence" : confidence ? confidence : [NSNull null],
    @"left" : @((int)frame.origin.x),
    @"top" : @((int)frame.origin.y),
    @"width" : @((int)frame.size.width),
    @"height" : @((int)frame.size.height),
    @"recognizedLanguages" : allLanguageData,
    @"text" : text,
  }];
}

+ (FIRVisionCloudDocumentTextRecognizerOptions *)parseOptions:(NSDictionary *)optionsData {
  FIRVisionCloudTextRecognizerOptions *options = [[FIRVisionCloudTextRecognizerOptions alloc] init];

  options.APIKeyOverride = optionsData[@"apiKeyOverride"];
  options.languageHints = optionsData[@"hintedLanguages"];

  return options;
}
@end
