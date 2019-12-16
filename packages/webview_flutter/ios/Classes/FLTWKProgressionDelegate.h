//
//  FLTWKProgressionDelegate.h
//  webview_flutter
//
//  Created by Jérémie Vincke on 03/10/2019.
//

#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FLTWKProgressionDelegate : NSObject

- (instancetype)initWithWebView:(WKWebView *)webView channel:(FlutterMethodChannel *)channel;

- (void)stopObservingProgress:(WKWebView *)webView;

@end

NS_ASSUME_NONNULL_END
