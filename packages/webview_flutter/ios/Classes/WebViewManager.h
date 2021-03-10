//
//  WebViewManager.h
//  webview_flutter
//
//  Created by Peter Stojanowski on 24/02/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FLTWKWebView;

@interface WebViewManager : NSObject

+ (id)sharedManager;

- (void)updateMaxCachedTabs:(NSNumber *)maxCachedTabs;
- (FLTWKWebView *)webViewForId:(NSString *)webViewId;
- (void)cacheWebView:(FLTWKWebView *)webView forId:(NSString *)webViewId;
- (void)clearAll;

@end

NS_ASSUME_NONNULL_END
