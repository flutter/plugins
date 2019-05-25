#import "FirebaseMlkitLanguagePlugin.h"

@import FirebaseMLCommon;

@implementation DeleteModel

+ (void)handleEvent:(NSString *)text result:(FlutterResult)result {
  FIRTranslateLanguage modelName = FIRTranslateLanguageForLanguageCode(text);

  NSSet<FIRTranslateRemoteModel *> *localModels =
      [[FIRModelManager modelManager] availableTranslateModelsWithApp:FIRApp.defaultApp];

  Boolean isModelPresent = [localModels
      containsObject:[FIRTranslateRemoteModel translateRemoteModelWithLanguage:modelName]];

  if (isModelPresent) {
    [[FIRModelManager modelManager]
        deleteDownloadedTranslateModel:[FIRTranslateRemoteModel
                                           translateRemoteModelWithLanguage:modelName]
                            completion:^(NSError *_Nullable error) {
                              if (error != nil) {
                                [FLTFirebaseMlkitLanguagePlugin handleError:error result:result];
                                return;
                              }
                              result(@"Deleted");
                            }];
  } else {
    result(@"Model not downloaded");
  }
}

@end
