
#import "SWAcapella.h"

#import "libsw/SWPrefs.h"

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
    if (arg1.count == 0){
        
        BOOL shouldOverride = (acapella != nil);
        
        if (!shouldOverride){ //sometimes acapella will be nil, so we will drill up
            
            NSString *prefKeyPrefix = [SWAcapella prefKeyByDrillingUpFromView:self];
            
            if (prefKeyPrefix){
                
                NSString *enabledKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"enabled"];
                id enabled = [SWPrefs valueForKey:enabledKey fallbackValue:@YES application:@"com.patsluth.AcapellaPrefs2"];
                shouldOverride = [enabled boolValue];
                
            }
            
        }
        
        if (shouldOverride){
            arg1 = @{@"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
                     @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play"};
        }
        
    }
    
    %orig(arg1);
    
    if (acapella){
        [acapella finishWrapAround];
    }
}

%end




