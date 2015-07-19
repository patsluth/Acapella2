
#import "SWAcapella.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface MPUMediaControlsTitlesView : UIView
{
}

@end





%hook MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)info
{
    if (info.count == 0){
        info = @{@"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
                 @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play"};
    }
    
    %orig(info);
    
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    if (acapella){
        if ([acapella respondsToSelector:@selector(finishWrapAround)]){
            [acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
    }
    
}

%end




