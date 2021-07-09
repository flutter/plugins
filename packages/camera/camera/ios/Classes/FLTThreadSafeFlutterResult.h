//
//  Header.h
//  camera
//
//  Created by Rene Floor on 07/07/2021.
//

#import <Flutter/Flutter.h>

@interface FLTThreadSafeFlutterResult : NSObject
- (id _Nonnull)initWithResult:(FlutterResult _Nonnull)result;
- (void)success;
- (void)successWithData:(id _Nonnull)data;
- (void)error:(NSError* _Nonnull)error;
- (void)notImplemented;
- (void)errorWithCode:(NSString* _Nonnull)code
              message:(NSString* _Nullable)message
              details:(id _Nullable)details;
@end
