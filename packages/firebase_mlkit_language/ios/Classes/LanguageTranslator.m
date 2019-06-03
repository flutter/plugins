#import "FirebaseMlkitLanguagePlugin.h"

@import FirebaseMLCommon;

@implementation LanguageTranslator

+ (void)handleEvent:(NSString *)text options:(NSDictionary *)options result:(FlutterResult)result {
  FIRTranslateLanguage sourceModel = FIRTranslateLanguageForLanguageCode(options[@"fromLanguage"]);
  FIRTranslateLanguage targetModel = FIRTranslateLanguageForLanguageCode(options[@"toLanguage"]);

  FIRTranslatorOptions *translationOptions =
      [[FIRTranslatorOptions alloc] initWithSourceLanguage:sourceModel targetLanguage:targetModel];
  FIRTranslator *customTranslator =
      [[FIRNaturalLanguage naturalLanguage] translatorWithOptions:translationOptions];

  FIRModelDownloadConditions *conditions =
      [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES
                                           allowsBackgroundDownloading:YES];

  [customTranslator
      downloadModelIfNeededWithConditions:conditions
                               completion:^(NSError *_Nullable error) {
                                 if (error) {
                                   [FLTFirebaseMlkitLanguagePlugin handleError:error result:result];
                                 }
                                 [customTranslator
                                     translateText:text
                                        completion:^(NSString *_Nullable translatedText,
                                                     NSError *_Nullable error) {
                                          if (error != nil || translatedText == nil) {
                                            [FLTFirebaseMlkitLanguagePlugin handleError:error
                                                                                 result:result];
                                          }
                                          result(translatedText);
                                        }];
                               }];
}
@end
