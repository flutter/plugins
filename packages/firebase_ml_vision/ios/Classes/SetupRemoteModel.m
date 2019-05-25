#import "FirebaseMlVisionPlugin.h"

@import FirebaseMLCommon;

@implementation SetupRemoteModel

+ (void)modelName:(NSString *)modelName result:(FlutterResult)result {
  FIRRemoteModel *remoteModel = [[FIRModelManager modelManager] remoteModelWithName:modelName];
  if (remoteModel == nil) {
    FIRModelDownloadConditions *conditions =
        [[FIRModelDownloadConditions alloc] initWithAllowsCellularAccess:YES
                                             allowsBackgroundDownloading:YES];
    FIRRemoteModel *remoteModel = [[FIRRemoteModel alloc] initWithName:modelName
                                                    allowsModelUpdates:YES
                                                     initialConditions:conditions
                                                      updateConditions:conditions];
    [[FIRModelManager modelManager] registerRemoteModel:remoteModel];
    [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
  } else {
    Boolean isModelDownloaded =
        [[FIRModelManager modelManager] isRemoteModelDownloaded:remoteModel];
    if (isModelDownloaded == true) {
      result(@"Model Already Setup");
    } else {
      [[FIRModelManager modelManager] downloadRemoteModel:remoteModel];
      result(@"Model Setup Complete");
    }
  }
}

@end
