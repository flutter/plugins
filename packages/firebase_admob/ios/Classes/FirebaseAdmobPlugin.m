#import "FirebaseAdMobPlugin.h"

@implementation FirebaseAdMobPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"firebase_admob"
            binaryMessenger:[registrar messenger]];
  FirebaseAdMobPlugin* instance = [[FirebaseAdMobPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"loadBannerAd"]) {
      NSLog(@"loadBannerAd not implemented");
  } else if ([call.method isEqualToString:@"loadInterstitialAd"]) {
      NSLog(@"loadInterstitialAd not implemented");
  } else if ([call.method isEqualToString:@"showAd"]) {
      NSLog(@"showAd not implemented");
  } else if ([call.method isEqualToString:@"disposeAd"]) {
      NSLog(@"disposeAd not implemented");
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
