//
//  UIScrollView+TYSnapshot.m
//  UITableViewSnapshotTest
//
//  Created by Tony on 2016/7/11.
//  Copyright © 2016年 TonyReet. All rights reserved.
//

#import "UIScrollView+TYSnapshot.h"
#import "UIView+TYSnapshot.h"
#import "UIImage+TYSnapshot.h"

@implementation UIScrollView (TYSnapshot)

- (void )screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock{
    if (!finishBlock)return;
    
    __block UIImage* snapshotImage = nil;
    
    //保存offset
    CGPoint oldContentOffset = self.contentOffset;
    //保存frame
    CGRect oldFrame = self.frame;
    
    if (self.contentSize.height > self.frame.size.height) {
        self.contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
    }
    self.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    //延迟0.3秒，避免有时候渲染不出来的情况
    [NSThread sleepForTimeInterval:0.3];
    
    self.contentOffset = CGPointZero;
    @autoreleasepool{
        UIGraphicsBeginImageContextWithOptions(self.bounds.size,NO,[UIScreen mainScreen].scale);

        CGContextRef context = UIGraphicsGetCurrentContext();

        [self.layer renderInContext:context];
        
//        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
        
        snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
    }
    
    self.frame = oldFrame;
    //还原
    self.contentOffset = oldContentOffset;
    
    if (snapshotImage != nil) {
        finishBlock(snapshotImage);
    }
}

#pragma mark - 获取屏幕快照
/*
 *  snapshotView:需要截取的view
 */
+(UIImage *)screenSnapshotWithSnapshotView:(UIView *)snapshotView
{
    return [self screenSnapshotWithSnapshotView:snapshotView snapshotSize:CGSizeZero];
}

/*
 *  snapshotView:需要截取的view
 *  snapshotSize:需要截取的size
 */
+(UIImage *)screenSnapshotWithSnapshotView:(UIView *)snapshotView snapshotSize:(CGSize )snapshotSize
{
    UIImage *snapshotImg;

    @autoreleasepool{
        if (snapshotSize.height == 0|| snapshotSize.width == 0) {//宽高为0的时候没有意义
            snapshotSize = snapshotView.bounds.size;
        }
        
        //创建
        UIGraphicsBeginImageContextWithOptions(snapshotSize,NO,[UIScreen mainScreen].scale);
        
        CGContextRef context = UIGraphicsGetCurrentContext();

        [snapshotView.layer renderInContext:context];
//        [snapshotView drawViewHierarchyInRect:snapshotView.bounds afterScreenUpdates:NO];
        
        //获取图片
        snapshotImg = UIGraphicsGetImageFromCurrentImageContext();
        
        //关闭
        UIGraphicsEndImageContext();
    }
    return snapshotImg;
}


@end

