#import "FirebaseMlkitLanguagePlugin.h"

@import FirebaseMLCommon;

@implementation LanguageIdentifier

+ (void)handleEvent:(NSString *)text options:(NSDictionary *)options result:(FlutterResult)result {
  FIRNaturalLanguage *naturalLanguage = [FIRNaturalLanguage naturalLanguage];
  FIRLanguageIdentification *languageId =
      [naturalLanguage languageIdentificationWithOptions:[LanguageIdentifier parseOptions:options]];

  [languageId
      identifyPossibleLanguagesForText:text
                            completion:^(
                                NSArray<FIRIdentifiedLanguage *> *_Nonnull identifiedLanguages,
                                NSError *_Nullable error) {
                              if (error) {
                                [FLTFirebaseMlkitLanguagePlugin handleError:error result:result];
                                return;
                              } else if (!identifiedLanguages) {
                                result(@[]);
                              }
                              NSMutableArray *languageData = [NSMutableArray array];
                              for (FIRIdentifiedLanguage *language in identifiedLanguages) {
                                NSDictionary *data = @{
                                  @"confidence" : [NSNumber numberWithFloat:language.confidence],
                                  @"languageCode" : language.languageCode,
                                };
                                [languageData addObject:data];
                              }

                              result(languageData);
                            }];
}

+ (FIRLanguageIdentificationOptions *)parseOptions:(NSDictionary *)optionsData {
  NSNumber *conf = optionsData[@"confidenceThreshold"];
  FIRLanguageIdentificationOptions *options =
      [[FIRLanguageIdentificationOptions alloc] initWithConfidenceThreshold:[conf floatValue]];
  return options;
}

@end
