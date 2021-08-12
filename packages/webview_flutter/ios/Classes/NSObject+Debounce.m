//
//  NSObject+Debounce.m
//  webview_flutter
//
//  Created by Peter Stojanowski on 09/08/2021.
//

#import <Foundation/Foundation.h>

@implementation NSObject (Debounce)

- (void)debounce:(SEL)action delay:(NSTimeInterval)delay
{
  __weak typeof(self) weakSelf = self;
  [NSObject cancelPreviousPerformRequestsWithTarget:weakSelf selector:action object:nil];
  [weakSelf performSelector:action withObject:nil afterDelay:delay];
}

@end
