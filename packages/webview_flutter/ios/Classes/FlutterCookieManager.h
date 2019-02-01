#import <Flutter/Flutter.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterCookieManager : NSObject

- (instancetype)init:(NSObject<FlutterBinaryMessenger>*)messenger;
@end

NS_ASSUME_NONNULL_END
