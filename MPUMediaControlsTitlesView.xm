//
//  MPUMediaControlsTitlesView.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWAcapella.h"

#import "MPUSystemMediaControlsViewController.h"

#import "libsw/libSluthware/SWPrefs.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface MPUMediaControlsTitlesView : UIView //MPUNowPlayingTitlesView
{
}

@end





%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)arg1
{
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    //dont override if we dont have an acapella (disabled in this section)
    //TODO: Localization
    if (arg1.count == 0) {
        
        BOOL shouldOverride = (acapella != nil);
        
        if (!shouldOverride) { //sometimes acapella will be nil, so we will drill up
            
            NSString *prefKeyPrefix = [%c(MPUSystemMediaControlsViewController) prefKeyPrefixByDrillingUp:self];
            
            if (prefKeyPrefix) {
                
                NSString *enabledKey = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"enabled"];
                id enabled = [SWPrefs valueForKey:enabledKey application:PREF_APPLICATION];
                shouldOverride = [enabled boolValue];
                
            }
            
        }
        
        if (shouldOverride) {
            arg1 = @{@"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
                     @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play"};
        }
        
    }
    
    %orig(arg1);
    
    if (acapella) {
        [acapella finishWrapAround];
    }
}

%end




