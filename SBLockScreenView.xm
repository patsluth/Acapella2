
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





%hook SBLockScreenHintManager

- (BOOL)presentingController:(id)arg1 gestureRecognizer:(UIGestureRecognizer *)arg2 shouldReceiveTouch:(UITouch *)arg3
{
    NSString *x = NSStringFromClass([arg3.view class]);
    NSString *y = NSStringFromClass(%c(MPUSystemMediaControlsView));
    
    if ([x isEqualToString:y]) {
        return NO;
    }
    
    return %orig(arg1, arg2, arg3);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)arg1 shouldReceiveTouch:(UITouch *)arg2
{
    NSString *x = NSStringFromClass([arg2.view class]);
    NSString *y = NSStringFromClass(%c(MPUSystemMediaControlsView));
    
    if ([x isEqualToString:y]) {
        return NO;
    }
    
    return %orig(arg1, arg2);
}

%end
