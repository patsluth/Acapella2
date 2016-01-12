//
//  MPUTransportControlsView.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "MPUTransportControlsView+SW.h"





%hook MPUTransportControlsView

//return YES if any subviews arent hidden
%new
- (BOOL)acapella_hidden
{
    BOOL controlVisible = NO;
    
    for (UIView *v in self.subviews) {
        controlVisible = (controlVisible || !v.hidden);
    }
    
    return !controlVisible;
}

%end




