
#import "SWAcapella.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface MusicNowPlayingTitlesView : UIView
{
}

@end





%hook MusicNowPlayingTitlesView

- (void)setAttributedTexts:(id)arg1
{
    %orig(arg1);
    
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    if (acapella){
        [acapella finishWrapAround];
    }
}

%end




