//
//  NSError+FlutterError.m
//  firebase_ml_vision
//
//  Created by Dustin Graham on 7/19/18.
//

#import "NSError+FlutterError.h"

@implementation NSError (FlutterError)
- (FlutterError *)flutterError {
  return [FlutterError errorWithCode:[NSString stringWithFormat:@"Error %d", (int)self.code]
                             message:self.domain
                             details:self.localizedDescription];
}
@end
