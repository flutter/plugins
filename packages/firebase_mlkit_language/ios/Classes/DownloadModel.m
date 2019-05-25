#import "FirebaseMlkitLanguagePlugin.h"

@import FirebaseMLCommon;

@implementation DownloadModel

+ (void)handleEvent:(NSString *)text result:(FlutterResult)result {
  FIRTranslateLanguage modelName = FIRTranslateLanguageForLanguageCode(text);
  FIRModelDownloadConditions *conditions =
      [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES
                                           allowsBackgroundDownloading:YES];
  FIRTranslateRemoteModel *modelToDownload =
      [FIRTranslateRemoteModel translateRemoteModelForApp:FIRApp.defaultApp
                                                 language:modelName
                                               conditions:conditions];
  if ([[FIRModelManager modelManager] isRemoteModelDownloaded:modelToDownload]) {
    result(@"Already Downloaded");
  } else {
    [[FIRModelManager modelManager] downloadRemoteModel:modelToDownload];
    result(@"Downloaded");
  }
}
@end
