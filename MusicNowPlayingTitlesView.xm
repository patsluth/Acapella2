//
//  MusicNowPlayingTitlesView.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

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
    
    if (acapella) {
        [acapella finishWrapAround];
    }
}

%end




