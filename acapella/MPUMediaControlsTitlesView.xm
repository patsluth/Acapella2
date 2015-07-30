
#import "SWAcapella.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface MPUMediaControlsTitlesView : UIView
{
}

@end





%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)arg1
{
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    //dont override if we dont have an acapella (disabled in this section)
    //TODO: Localization
    if (acapella && arg1.count == 0){
        arg1 = @{@"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
                 @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play"};
    }
    
    %orig(arg1);
    
    if (acapella){
        [acapella finishWrapAround];
    }
}

%end




