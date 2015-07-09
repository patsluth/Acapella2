
#import "AcapellaKit.h"
#import "SWAcapellaPrefsBridge.h"

#import "UIColor+SW.h"

#import "MPUNowPlayingTitlesView.h"
#import "MPUMediaControlsTitlesView.h"
#import "MusicNowPlayingTitlesView.h"

#import <MediaRemote/MediaRemote.h>



%hook MPUMediaControlsTitlesView //springboard specific

- (void)setTitleText:(NSString *)arg1
{
    %orig(arg1);
    
    if ([self.superview isKindOfClass:%c(SWAcapellaScrollView)]){
        
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(CFDictionaryRef result){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!result){
                    
                    [self setArtistText:@"Tap to Play"];
                    [self setAlbumText:@"Acapella"];
                    
                    [self setNeedsDisplay];
                    
                }
            });
        });
    }
}

%end




