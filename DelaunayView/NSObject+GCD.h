//
//  NSObject+GCD.h
//

#import <Foundation/Foundation.h>


@interface NSObject (GCD)



- (void)performOnMainThread:(void(^)(void))block wait:(BOOL)wait;

- (void)performAsynchronous:(void(^)(void))block;

- (void)performAfter:(NSTimeInterval)seconds block:(void(^)(void))block;



@end
