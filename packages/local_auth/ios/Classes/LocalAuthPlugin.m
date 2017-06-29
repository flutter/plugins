// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
#import <LocalAuthentication/LocalAuthentication.h>

#import "LocalAuthPlugin.h"

@implementation LocalAuthPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/local_auth"
                                  binaryMessenger:[registrar messenger]];
  LocalAuthPlugin *instance = [[LocalAuthPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  if ([@"authenticateWithBiometrics" isEqualToString:call.method]) {
    [self authenticateWithBiometrics:call.arguments withFlutterResult:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

#pragma mark Private Methods

- (void)alertMessage:(NSString *)message
         firstButton:(NSString *)firstButton
       flutterResult:(FlutterResult)result
    additionalButton:(NSString *)secondButton {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:@""
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:firstButton
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
                                                          result(@NO);
                                                        }];

  [alert addAction:defaultAction];
  if (secondButton != nil) {
    UIAlertAction *additionalAction = [UIAlertAction
        actionWithTitle:secondButton
                  style:UIAlertActionStyleDefault
                handler:^(UIAlertAction *action) {
                  if (&UIApplicationOpenSettingsURLString != NULL) {
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                    result(@NO);
                  }
                }];
    [alert addAction:additionalAction];
  }
  [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert
                                                                                     animated:YES
                                                                                   completion:nil];
}

- (void)authenticateWithBiometrics:(NSDictionary *)arguments
                 withFlutterResult:(FlutterResult)result {
  LAContext *context = [[LAContext alloc] init];
  NSError *authError = nil;
  context.localizedFallbackTitle = @"";

  if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                           error:&authError]) {
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:arguments[@"localizedReason"]
                      reply:^(BOOL success, NSError *error) {
                        if (success) {
                          result(@YES);
                        } else {
                          switch (error.code) {
                            case LAErrorPasscodeNotSet:
                            case LAErrorTouchIDNotAvailable:
                            case LAErrorTouchIDNotEnrolled:
                            case LAErrorTouchIDLockout:
                              [self handleErrors:error
                                   flutterArguments:arguments
                                  withFlutterResult:result];
                              return;
                          }
                          result(@NO);
                        }
                      }];
  } else {
    [self handleErrors:authError flutterArguments:arguments withFlutterResult:result];
  }
}

- (void)handleErrors:(NSError *)authError
     flutterArguments:(NSDictionary *)arguments
    withFlutterResult:(FlutterResult)result {
  NSString *errorCode = @"NotAvailable";
  switch (authError.code) {
    case LAErrorPasscodeNotSet:
    case LAErrorTouchIDNotEnrolled:
      if (arguments[@"useErrorDialogs"]) {
        [self alertMessage:arguments[@"goToSettingDescriptionIOS"]
                 firstButton:arguments[@"okButton"]
               flutterResult:result
            additionalButton:arguments[@"goToSetting"]];
        return;
      }
      errorCode = authError.code == LAErrorPasscodeNotSet ? @"PasscodeNotSet" : @"NotEnrolled";
      break;
    case LAErrorTouchIDLockout:
      [self alertMessage:arguments[@"lockOut"]
               firstButton:arguments[@"okButton"]
             flutterResult:result
          additionalButton:nil];
      return;
  }
  result([FlutterError errorWithCode:errorCode
                             message:authError.localizedDescription
                             details:authError.domain]);
}

@end
