//
//  Header.h
//  camera
//
//  Created by Rene Floor on 07/07/2021.
//

#import <Flutter/Flutter.h>

@interface FLTThreadSafeFlutterResult : NSObject
- (id)initWithResult:(FlutterResult)result;
- (void)successWithData:(id _Nullable)data;
- (void)error:(NSError*)error;
- (void)notImplemented;
- (void)errorWithCode:(NSString*)code
              message:(NSString* _Nullable)message
              details:(id _Nullable)details;
@end
