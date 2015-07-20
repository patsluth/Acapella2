
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface SBLockScreenView : UIView
{
}

@end




%hook SBLockScreenView

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    NSString *classString = NSStringFromClass([gestureRecognizer class]);
    
    if ([classString isEqualToString:@"SBLockScreenHintTapGestureRecognizer"] ||
        [classString isEqualToString:@"SBLockScreenHintLongPressGestureRecognizer"]){
        return;
    }
    
    %orig(gestureRecognizer);
}

- (BOOL)_disallowScrollingInTouchedView:(UIView *)view
{
    NSLog(@"PAT DISSALLOW SCROLLING %@", view);
    return YES;
}

%end

%hook SBLockScreenScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"PAT TOUCH ME %@", gestureRecognizer);
    return NO;
}

%end




