//
//  TYSnapshotScroll.m
//  TYSnapshotScroll
//
//  Created by apple on 16/12/28.
//  Copyright © 2016年 TonyReet. All rights reserved.
//

#import "TYSnapshotScroll.h"
#import "WKWebView+TYSnapshot.h"
#import "UIScrollView+TYSnapshot.h"
#import "UIView+TYSnapshot.h"

@implementation TYSnapshotScroll

+ (void )screenSnapshot:(UIView *)snapshotView finishBlock:(void(^)(UIImage *snapShotImage))finishBlock{
    UIView *snapshotFinalView = snapshotView;
    
    if([snapshotView isKindOfClass:[WKWebView class]]){
        //WKWebView
        snapshotFinalView = (WKWebView *)snapshotView;
        
    }else if([snapshotView isKindOfClass:[UIWebView class]]){
        
        //UIWebView
        UIWebView *webView = (UIWebView *)snapshotView;
        snapshotFinalView = webView.scrollView;
    }else if([snapshotView isKindOfClass:[UIScrollView class]] ||
             [snapshotView isKindOfClass:[UITableView class]] ||
             [snapshotView isKindOfClass:[UICollectionView class]]
             ){
        //ScrollView
        snapshotFinalView = (UIScrollView *)snapshotView;
    }else{
        NSLog(@"不支持的类型");
    }
    
    [snapshotFinalView screenSnapshot:^(UIImage *snapShotImage) {
        if (snapShotImage != nil && finishBlock) {
            finishBlock(snapShotImage);
        }
    }];
}


@end
