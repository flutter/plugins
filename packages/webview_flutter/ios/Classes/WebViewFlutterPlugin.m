#import "WebViewFlutterPlugin.h"
#import "FlutterWebView.h"
#import "FlutterCookieManager.h"

@implementation FLTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTWebViewFactory* webviewFactory =
      [[FLTWebViewFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.flutter.io/webview"];
  FlutterCookieManager* cookieManager = [[FlutterCookieManager alloc] init:registrar.messenger];
}

@end
