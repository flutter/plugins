//
//  Debounce.h
//  Pods
//
//  Created by Peter Stojanowski on 09/08/2021.
//

@interface NSObject (Debounce)

- (void)debounce:(SEL)action delay:(NSTimeInterval)delay;

@end
