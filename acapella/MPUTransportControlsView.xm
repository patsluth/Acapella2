
#import "MPUTransportControlsView.h"





%hook MPUTransportControlsView

//return YES if any subviews arent hidden
%new
- (BOOL)hidden_acapella
{
    BOOL controlVisible = NO;
    
    for (UIView *v in self.subviews){
        controlVisible = (controlVisible || !v.hidden);
    }
    
    return !controlVisible;
}

%end




