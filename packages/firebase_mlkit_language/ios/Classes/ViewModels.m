#import "FirebaseMlkitLanguagePlugin.h"

@import FirebaseMLCommon;

@implementation ViewModels

+ (void)result:(FlutterResult)result {
  NSSet<FIRTranslateRemoteModel *> *localModels =
      [[FIRModelManager modelManager] availableTranslateModelsWithApp:FIRApp.defaultApp];

  NSArray *array = localModels.allObjects;

  NSMutableArray *arr = [NSMutableArray array];
  for (FIRTranslateRemoteModel *model in array) {
    NSString *languageCode = FIRTranslateLanguageCodeForLanguage(model.language);
    [arr addObject:languageCode];
  }

  result(arr);
}

@end
