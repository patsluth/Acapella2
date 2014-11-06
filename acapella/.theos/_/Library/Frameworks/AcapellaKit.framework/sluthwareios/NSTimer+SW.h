//
//  NSTimer+SW.h
//  sluthwareioslibrary
//
//  Created by Pat Sluth on 2014-11-02.
//  Copyright (c) 2014 Pat Sluth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer(SW)

+ (id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())block repeats:(BOOL)repeats;
+ (id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())block repeats:(BOOL)repeats;

@end




