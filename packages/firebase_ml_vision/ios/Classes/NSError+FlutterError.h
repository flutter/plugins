//
//  NSError+FlutterError.h
//  firebase_ml_vision
//
//  Created by Dustin Graham on 7/19/18.
//
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>

@interface NSError (FlutterError)
@property(readonly, nonatomic) FlutterError *flutterError;
@end
