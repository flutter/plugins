#import "WebViewFlutterPlugin.h"
#import "FlutterWebView.h"
#import "FLTCookieManager.h"

@implementation FLTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTWebViewFactory* webviewFactory =
      [[FLTWebViewFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.flutter.io/webview"];
  FLTCookieManager* cookieManager = [[FLTCookieManager alloc] init:registrar.messenger];
}

@end
