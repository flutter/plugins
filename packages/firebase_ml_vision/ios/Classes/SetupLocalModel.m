#import "FirebaseMlVisionPlugin.h"

@import FirebaseMLCommon;

@implementation SetupLocalModel

+ (void)modelName:(NSString *)modelName result:(FlutterResult)result {
  FIRLocalModel *localModel = [[FIRModelManager modelManager] localModelWithName:modelName];
  if (localModel == nil) {
    NSString *pathStart = @"Frameworks/App.framework/flutter_assets/assets/";
    NSString *datasetAppended = [pathStart stringByAppendingString:modelName];
    NSString *finalPath = [datasetAppended stringByAppendingString:@"/manifest.json"];
    NSString *manifestPath = [[NSBundle mainBundle] pathForResource:finalPath ofType:nil];
    FIRLocalModel *localModel = [[FIRLocalModel alloc] initWithName:modelName path:manifestPath];
    [[FIRModelManager modelManager] registerLocalModel:localModel];
    result(@"Model Setup Complete");
  } else {
    result(@"Model Already Setup");
  }
}

@end
