//
//  WebViewManager.m
//  webview_flutter
//
//  Created by Peter Stojanowski on 24/02/2021.
//

#import "WebViewManager.h"
#import "FlutterWebView.h"

@interface WebViewData : NSObject

@property (nonatomic, strong, readonly) FLTWKWebView *webView;
@property (nonatomic, strong, readonly) NSDate *cachedDate;
@property (nonatomic, strong, readonly) NSString *webViewId;

@end

@implementation WebViewData

- (instancetype)initWithWebView:(FLTWKWebView *)webView webViewId:(NSString *)webViewId {
    if (self = [super init]) {
        _webView = webView;
        _webViewId = webViewId;
        _cachedDate = [NSDate date];
    }
    return self;
}

- (void)updateDate {
    _cachedDate = [NSDate date];
}

@end


@interface WebViewManager()

@property (nonatomic, strong) NSNumber *maxCachedTabs;
@property (nonatomic, strong) NSMutableDictionary<NSString*, WebViewData*> *cache;

@end

@implementation WebViewManager

+ (id)sharedManager {
    static WebViewManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _cache = [[NSMutableDictionary alloc] init];
        _maxCachedTabs = @0;
    }
    return self;
}

- (void)updateMaxCachedTabs:(NSNumber *)maxCachedTabs {
    _maxCachedTabs = maxCachedTabs;
}

- (FLTWKWebView *)webViewForId:(NSString *)webViewId {
    WebViewData* data = self.cache[webViewId];
    if (data) {
        [data updateDate];
    }
    return data.webView;
}

- (void)cacheWebView:(FLTWKWebView *)webView forId:(NSString *)webViewId {
    WebViewData *data = [[WebViewData alloc] initWithWebView:webView webViewId:webViewId];
    self.cache[webViewId] = data;
    [self removeOldTabsIfNeeded];
}

- (void)clearAll {
    [self.cache removeAllObjects];
}

- (void)removeOldTabsIfNeeded {
    // Cache not supported
    if ([self.maxCachedTabs intValue] <= 0) {
        [self clearAll];
        return;
    }
    
    // Sort cache values in descending order
    NSArray *sortedCacheValues = [self.cache.allValues sortedArrayUsingComparator:^NSComparisonResult(WebViewData *obj1, WebViewData *obj2) {
        return [obj2.cachedDate compare:obj1.cachedDate];
    }];
    
    // Remove old tabs if cache contains more tabs than `maxCachedTabs`
    if (sortedCacheValues.count > [self.maxCachedTabs intValue]) {
        NSMutableArray *keysToRemove = [[NSMutableArray alloc] init];
        for (int i=[self.maxCachedTabs intValue]; i<sortedCacheValues.count; i++) {
            WebViewData *data = sortedCacheValues[i];
            [keysToRemove addObject:data.webViewId];
        }
        [self.cache removeObjectsForKeys:keysToRemove];
    }
}

@end
