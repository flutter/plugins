#import "WebViewFlutterPlugin.h"
#import "FLTCookieManager.h"
#import "FlutterWebView.h"

@implementation FLTWebViewFlutterPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTWebViewFactory* webviewFactory =
      [[FLTWebViewFactory alloc] initWithMessenger:registrar.messenger];
  [registrar registerViewFactory:webviewFactory withId:@"plugins.flutter.io/webview"];
  [FLTCookieManager registerWithRegistrar:registrar];
}

@end
