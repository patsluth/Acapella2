//
//  MPUMediaControlsTitlesView.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

@import UIKit;
@import Foundation;

#import "SWAcapella.h"
#import "SWAcapellaPrefs.h"

#import "MPUSystemMediaControlsViewController+SW.h"





@interface MPUMediaControlsTitlesView : UIView //MPUNowPlayingTitlesView
{
}

@end





%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)arg1
{
    // Dont override if we dont have an acapella (disabled in this section)
    // TODO: Localization
    if (arg1.count == 0) {
        
        SWAcapellaPrefs *acapellaPrefs = objc_getAssociatedObject(self, @selector(_acapellaPrefs));
        
        if (acapellaPrefs.enabled) {
            arg1 = @{@"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
                     @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play"};
        }
        
    }
    
    %orig(arg1);
    
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    if (acapella) {
		[acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.1];
    }
}

%end




