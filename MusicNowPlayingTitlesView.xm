//
//  MusicNowPlayingTitlesView.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

@import UIKit;
@import Foundation;

#import "SWAcapella.h"

#import "MusicNowPlayingTitlesView+SW.h"





%hook MusicNowPlayingTitlesView

#pragma mark - MusicNowPlayingTitlesView

- (void)setAttributedTexts:(id)arg1
{
	%orig(arg1);
	
	SWAcapella *acapella = [SWAcapella acapellaForObject:self];
	
	if (acapella) {
		
		[NSObject cancelPreviousPerformRequestsWithTarget:acapella selector:@selector(finishWrapAround) object:nil];
		[acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.1];
		
	}
}

%end




