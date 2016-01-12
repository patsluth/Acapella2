//
//  SBLockScreenHintManager.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





%hook SBLockScreenHintManager

- (BOOL)presentingController:(id)arg1 gestureRecognizer:(UIGestureRecognizer *)arg2 shouldReceiveTouch:(UITouch *)arg3
{
    if ([arg3.view isKindOfClass:%c(MPUSystemMediaControlsView)]) {
        return NO;
    }
    
    return %orig(arg1, arg2, arg3);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)arg1 shouldReceiveTouch:(UITouch *)arg2
{
    if ([arg2.view isKindOfClass:%c(MPUSystemMediaControlsView)]) {
        return NO;
    }
    
    return %orig(arg1, arg2);
}

%end




%ctor //syncronize acapella default prefs
{
    NSLog(@"PAT TEST %@", %c(SBLockScreenHintManager));
}
