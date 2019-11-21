//
//  WKWebView+TYSnapshot.h
//  TYSnapshotScroll
//
//  Created by apple on 16/12/28.
//  Copyright © 2016年 TonyReet. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (TYSnapshot)

- (void )screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock;

@end
