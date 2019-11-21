//
//  UIView+TYSnapshot.h
//  TYSnapshotScrollDemo
//
//  Created by TonyReet on 2019/3/26.
//  Copyright © 2019 TonyReet. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TYSnapshot)

- (void )screenSnapshot:(void(^)(UIImage *snapShotImage))finishBlock;

@end

NS_ASSUME_NONNULL_END
