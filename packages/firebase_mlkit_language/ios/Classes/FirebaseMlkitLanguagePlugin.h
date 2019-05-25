#import <Flutter/Flutter.h>

#import "Firebase/Firebase.h"

@interface FLTFirebaseMlkitLanguagePlugin : NSObject <FlutterPlugin>
+ (void)handleError:(NSError *)error result:(FlutterResult)result;
@end

@protocol LangAgent
@required
+ (void)handleEvent:(NSString *)text options:(NSDictionary *)options result:(FlutterResult)result;
@optional
@end

@protocol ModelAgent
@required
+ (void)handleEvent:(NSString *)text result:(FlutterResult)result;
@optional
@end

@protocol ViewModelAgent
@required
+ (void)result:(FlutterResult)result;
@optional
@end

@interface LanguageIdentifier : NSObject <LangAgent>
@end

@interface LanguageTranslator : NSObject <LangAgent>
@end

@interface DeleteModel : NSObject <ModelAgent>
@end

@interface ViewModels : NSObject <ViewModelAgent>
@end

@interface DownloadModel : NSObject <ModelAgent>
@end
