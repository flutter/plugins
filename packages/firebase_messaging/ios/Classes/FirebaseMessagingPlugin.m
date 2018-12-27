// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FirebaseMessagingPlugin.h"

#import "Firebase/Firebase.h"

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface FLTFirebaseMessagingPlugin () <FIRMessagingDelegate>
@end
#endif

@implementation FLTFirebaseMessagingPlugin {
  FlutterMethodChannel *_channel;
  NSDictionary *_launchNotification;
  BOOL _resumingFromBackground;
    
  /// used for UNAuthorizationOptions(>= iOS 10) or older UIUserNotificationTypes(< iOS 10)
  NSDictionary<NSString*, NSNumber*> *_authorizationOptions;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  FlutterMethodChannel *channel =
      [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/firebase_messaging"
                                  binaryMessenger:[registrar messenger]];
  FLTFirebaseMessagingPlugin *instance =
      [[FLTFirebaseMessagingPlugin alloc] initWithChannel:channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
  self = [super init];

  if (self) {
    _channel = channel;
    _resumingFromBackground = NO;
      
     if (@available(iOS 10, *)) {
        _authorizationOptions = @{
                              @"sound": @(UNAuthorizationOptionSound),
                              @"alert": @(UNAuthorizationOptionAlert),
                              @"badge": @(UNAuthorizationOptionBadge)
                              };
     } else {
         _authorizationOptions = @{
                                   @"sound" : @(UIUserNotificationTypeSound),
                                   @"badge" : @(UIUserNotificationTypeBadge),
                                   @"alert" : @(UIUserNotificationTypeAlert)
                                   };
     }
      
    if (![FIRApp defaultApp]) {
      [FIRApp configure];
    }
    [FIRMessaging messaging].delegate = self;
  }
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
  NSString *method = call.method;
  if ([@"requestNotificationPermissions" isEqualToString:method]) {
      [self requestNotificationPermissions:call result:result];
  } else if ([@"configure" isEqualToString:method]) {
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    if (_launchNotification != nil) {
      [_channel invokeMethod:@"onLaunch" arguments:_launchNotification];
    }
    result(nil);
  } else if ([@"subscribeToTopic" isEqualToString:method]) {
    NSString *topic = call.arguments;
    [[FIRMessaging messaging] subscribeToTopic:topic];
    result(nil);
  } else if ([@"unsubscribeFromTopic" isEqualToString:method]) {
    NSString *topic = call.arguments;
    [[FIRMessaging messaging] unsubscribeFromTopic:topic];
    result(nil);
  } else if ([@"getToken" isEqualToString:method]) {
    [[FIRInstanceID instanceID]
        instanceIDWithHandler:^(FIRInstanceIDResult *_Nullable instanceIDResult,
                                NSError *_Nullable error) {
          if (error != nil) {
            NSLog(@"getToken, error fetching instanceID: %@", error);
            result(nil);
          } else {
            result(instanceIDResult.token);
          }
        }];
  } else if ([@"deleteInstanceID" isEqualToString:method]) {
    [[FIRInstanceID instanceID] deleteIDWithHandler:^void(NSError *_Nullable error) {
      if (error.code != 0) {
        NSLog(@"deleteInstanceID, error: %@", error);
        result([NSNumber numberWithBool:NO]);
      } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        result([NSNumber numberWithBool:YES]);
      }
    }];
  } else if ([@"autoInitEnabled" isEqualToString:method]) {
    BOOL *value = [[FIRMessaging messaging] isAutoInitEnabled];
    result([NSNumber numberWithBool:value]);
  } else if ([@"setAutoInitEnabled" isEqualToString:method]) {
    NSNumber *value = call.arguments;
    [FIRMessaging messaging].autoInitEnabled = value.boolValue;
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)requestNotificationPermissions:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSDictionary *arguments = call.arguments;
    
    if (@available(iOS 10, *)) {
      UNAuthorizationOptions authorizationOptions = [self mapAuthorizationOptions:arguments];
      [UNUserNotificationCenter.currentNotificationCenter
       requestAuthorizationWithOptions: authorizationOptions
       completionHandler:^(BOOL granted, NSError * _Nullable error) {
           
        if (granted) {
          [self->_channel invokeMethod:@"onIosSettingsRegistered"
                             arguments:[self authorizationOptionsStringRepresentation: authorizationOptions]];
          } else {
               // there is no callback for failed notification permission requests
          }

          result(nil);
       }];
    } else {
      UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                              settingsForTypes:[self mapNotificationTypes:arguments]
                                              categories:nil];
      [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
      result(nil);
  }
}

- (NSDictionary *)authorizationOptionsStringRepresentation:(UNAuthorizationOptions)options API_AVAILABLE(ios(10)) {
    __block NSMutableDictionary<NSString*, NSNumber*> *authorizationOptionsDic = [[NSMutableDictionary<NSString*, NSNumber*> alloc] initWithCapacity:_authorizationOptions.allKeys.count];
    
    [_authorizationOptions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull authOptionKey, NSNumber * _Nonnull authOption, BOOL * _Nonnull stop) {
        authorizationOptionsDic[authOptionKey] = [NSNumber numberWithBool: options & authOption.unsignedIntegerValue];
    }];
    
    return [authorizationOptionsDic copy];
}

- (NSDictionary<NSString*, NSNumber*> *)notificationTypeStringRepresentation:(UIUserNotificationType)notificationTypes {
    __block NSMutableDictionary<NSString*, NSNumber*> *notificationTypeDic = [[NSMutableDictionary<NSString*, NSNumber*> alloc] initWithCapacity:_authorizationOptions.allKeys.count];

    [_authorizationOptions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull notificationTypeKey, NSNumber * _Nonnull notificationType, BOOL * _Nonnull stop) {
        // notificationTypeDic[notificationTypeKey] = @(notificationTypes & notificationType.unsignedIntegerValue);
        notificationTypeDic[notificationTypeKey] = [NSNumber numberWithBool: notificationTypes & notificationType.unsignedIntegerValue];

    }];

    return [notificationTypeDic copy];
}

- (UIUserNotificationType)mapNotificationTypes:(nullable NSDictionary *)arguments {
    __block UIUserNotificationType notificationTypes = 0;

    [_authorizationOptions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull notificationTypeKey, NSNumber * _Nonnull notificationType, BOOL * _Nonnull stop) {
      if ([arguments[notificationTypeKey] boolValue]) {
        notificationTypes |= notificationType.unsignedIntegerValue;
      }
    }];

    return notificationTypes;
}

- (UNAuthorizationOptions)mapAuthorizationOptions:(nullable NSDictionary *)arguments API_AVAILABLE(ios(10)) {
    __block UNAuthorizationOptions options = 0;
    
    [_authorizationOptions enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull authOptionKey, NSNumber * _Nonnull authOption, BOOL * _Nonnull stop) {
      if ([arguments[authOptionKey] boolValue]) {
        options |= authOption.unsignedIntegerValue;
      }
    }];
    
    return options;
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Receive data message on iOS 10 devices while app is in the foreground.
- (void)applicationReceivedRemoteMessage:(FIRMessagingRemoteMessage *)remoteMessage {
  [self didReceiveRemoteNotification:remoteMessage.appData];
}
#endif

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
  if (_resumingFromBackground) {
    [_channel invokeMethod:@"onResume" arguments:userInfo];
  } else {
    [_channel invokeMethod:@"onMessage" arguments:userInfo];
  }
}

#pragma mark - AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  if (launchOptions != nil) {
    _launchNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
  }
  return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  _resumingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  _resumingFromBackground = NO;
  // Clears push notifications from the notification center, with the
  // side effect of resetting the badge count. We need to clear notifications
  // because otherwise the user could tap notifications in the notification
  // center while the app is in the foreground, and we wouldn't be able to
  // distinguish that case from the case where a message came in and the
  // user dismissed the notification center without tapping anything.
  // TODO(goderbauer): Revisit this behavior once we provide an API for managing
  // the badge number, or if we add support for running Dart in the background.
  // Setting badgeNumber to 0 is a no-op (= notifications will not be cleared)
  // if it is already 0,
  // therefore the next line is setting it to 1 first before clearing it again
  // to remove all
  // notifications.
  application.applicationIconBadgeNumber = 1;
  application.applicationIconBadgeNumber = 0;
}

- (bool)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
  [self didReceiveRemoteNotification:userInfo];
  completionHandler(UIBackgroundFetchResultNoData);
  return YES;
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
#ifdef DEBUG
  [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeSandbox];
#else
  [[FIRMessaging messaging] setAPNSToken:deviceToken type:FIRMessagingAPNSTokenTypeProd];
#endif

  [_channel invokeMethod:@"onToken" arguments:[[FIRInstanceID instanceID] token]];
}

#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// UNUserNotificationCenter with completion handler is used instead
#else
- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings API_UNAVAILABLE(ios(10)) {

    [_channel invokeMethod:@"onIosSettingsRegistered"
               arguments:[self notificationTypeStringRepresentation: notificationSettings.types]];
}
#endif

- (void)messaging:(nonnull FIRMessaging *)messaging
    didReceiveRegistrationToken:(nonnull NSString *)fcmToken {
  [_channel invokeMethod:@"onToken" arguments:fcmToken];
}

@end
