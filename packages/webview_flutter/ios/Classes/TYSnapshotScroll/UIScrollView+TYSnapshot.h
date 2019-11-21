//
//  UIScrollView+TYSnapshot.h
//  UITableViewSnapshotTest
//
//  Created by Tony on 2016/7/11.
//  Copyright © 2016年 TonyReet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (TYSnapshot)

- (void )screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock;

+(UIImage *)screenSnapshotWithSnapshotView:(UIView *)snapshotView;

+(UIImage *)screenSnapshotWithSnapshotView:(UIView *)snapshotView snapshotSize:(CGSize )snapshotSize;
@end

