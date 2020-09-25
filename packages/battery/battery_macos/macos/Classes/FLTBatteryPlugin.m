// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "FLTBatteryPlugin.h"
#import <IOKit/ps/IOPowerSources.h>

@interface FLTBatteryPlugin () <FlutterStreamHandler>
@end

@implementation FLTBatteryPlugin {
    FlutterEventSink _eventSink;
}
CFRunLoopSourceRef source;


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FLTBatteryPlugin* instance = [[FLTBatteryPlugin alloc] init];
    
    FlutterMethodChannel* channel =
    [FlutterMethodChannel methodChannelWithName:@"plugins.flutter.io/battery"
                                binaryMessenger:[registrar messenger]];
    
    [registrar addMethodCallDelegate:instance channel:channel];
    FlutterEventChannel* chargingChannel =
    [FlutterEventChannel eventChannelWithName:@"plugins.flutter.io/charging"
                              binaryMessenger:[registrar messenger]];
    [chargingChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getBatteryLevel" isEqualToString:call.method]) {
        int batteryLevel = [self getBatteryLevel];
        if (batteryLevel == -1) {
            result([FlutterError errorWithCode:@"UNAVAILABLE"
                                       message:@"Battery info unavailable"
                                       details:nil]);
        } else {
            result(@(batteryLevel));
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)onBatteryStateDidChange:(NSNotification*)notification {
    [self sendBatteryStateEvent];
}

- (void)sendBatteryStateEvent {
    if (!_eventSink) return;
    NSDictionary * ps =   getBatteryDictionary();
    if(ps ==NULL)
        _eventSink([FlutterError errorWithCode:@"UNAVAILABLE"
                                       message:@"Charging status unavailable"
                                       details:nil]);
    else  if([[ps objectForKey:@"Is Charged"] integerValue]==1)
        _eventSink(@"full");
    else if([[ps objectForKey:@"Is Charging"] integerValue] ==1 )
        _eventSink(@"charging");
    else
        _eventSink(@"discharging");
}
NSDictionary* getBatteryDictionary(){
    CFTypeRef powerSourceRef=  IOPSCopyPowerSourcesInfo();
    if(powerSourceRef ==NULL)
        return NULL;
    CFArrayRef powerSourceArrayRef =  IOPSCopyPowerSourcesList(powerSourceRef);
    if(powerSourceArrayRef ==NULL)
        return NULL;
    NSArray *powerSourceArray = (__bridge NSArray *)(powerSourceArrayRef);
    if([powerSourceArray count] ==0)
        return NULL;
    NSDictionary * powerSourceDictionary =   (NSDictionary *) CFArrayGetValueAtIndex(powerSourceArrayRef,0);
    return powerSourceDictionary;
    
}
- (int)getBatteryLevel {
    
    NSDictionary * ps =   getBatteryDictionary();
    if(ps==NULL)
        return -1;
    return (int) [[ps objectForKey:@"Current Capacity"]integerValue];
    
    
}

#pragma mark FlutterStreamHandler impl

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    _eventSink = eventSink;
    source = IOPSNotificationCreateRunLoopSource(powerSourceChange,(__bridge void *)(self));
    CFRunLoopAddSource(CFRunLoopGetCurrent(),source,kCFRunLoopDefaultMode);
    
    [ self sendBatteryStateEvent ];
    
    return nil;
}
void powerSourceChange(void* context ){
    
    FLTBatteryPlugin* controller = (__bridge FLTBatteryPlugin *)context;
    [controller sendBatteryStateEvent];
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    _eventSink = nil;
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(),source,kCFRunLoopDefaultMode);
    
    return nil;
}

@end
