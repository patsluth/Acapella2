
#import "SWAcapella.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>





@interface MusicNowPlayingTitlesView : UIView
{
}

@end





%hook MusicNowPlayingTitlesView

- (void)layoutSubviews
{
    %orig();
    
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    if (acapella){
        if ([acapella respondsToSelector:@selector(refreshTitleClones)]){
            [acapella performSelector:@selector(refreshTitleClones) withObject:nil afterDelay:0.0];
        }
    }
}

- (void)setAttributedTexts:(id)arg1
{
    %orig(arg1);
    
    SWAcapella *acapella = [SWAcapella acapellaForObject:self];
    
    if (acapella){
        if ([acapella respondsToSelector:@selector(finishWrapAround)]){
            [acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
    }
}

%end




