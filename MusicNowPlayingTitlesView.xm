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
	
	if (acapella && acapella.titlesClone) {
		
		MusicNowPlayingTitlesView *clone = (MusicNowPlayingTitlesView *)acapella.titlesClone;
		[clone setAttributedTexts:self.attributedTexts];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:acapella selector:@selector(finishWrapAround) object:nil];
		[acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.1];
		
	}
}

#pragma mark - SWAcapellaTitlesProtocol

%new
- (instancetype)acapella_copy
{
	MusicNowPlayingTitlesView *copy = [[[self class] alloc] initWithFrame:self.frame];
	copy.translatesAutoresizingMaskIntoConstraints = NO;
	copy.userInteractionEnabled = NO;
	[copy setAttributedTexts:self.attributedTexts];
	return copy;
}

%end




