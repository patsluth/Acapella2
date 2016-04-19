//
//  MusicNowPlayingTitlesView.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWAcapella.h"

@import UIKit;
@import Foundation;





@interface MusicNowPlayingTitlesView : UIView
{
}

@end





%hook MusicNowPlayingTitlesView

- (void)setAttributedTexts:(id)arg1
{
    %orig(arg1);
    
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    if (acapella) {
		[acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.1];
    }
}

%end




