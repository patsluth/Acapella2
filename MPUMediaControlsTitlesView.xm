//
//  MPUMediaControlsTitlesView.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

@import UIKit;
@import Foundation;

#import "SWAcapella.h"
#import "SWAcapellaPrefs.h"

#import "MPUMediaControlsTitlesView+SW.h"











%hook MPUMediaControlsTitlesView

#pragma mark - MPUMediaControlsTitlesView

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)arg1
{
	// Dont override if we dont have an acapella (disabled in this section)
	// TODO: Localization
	if (arg1.count == 0) {
		
		SWAcapellaPrefs *acapellaPrefs = objc_getAssociatedObject(self, @selector(_acapellaPrefs));
		
		if (acapellaPrefs.enabled) {
			arg1 = @{
					 @"kMRMediaRemoteNowPlayingInfoTitle" : @"Acapella",
					 @"kMRMediaRemoteNowPlayingInfoArtist" : @"Tap To Play",
					 };
		}
		
	}
	
	%orig(arg1);
	
	SWAcapella *acapella = [SWAcapella acapellaForObject:self];
	
	if (acapella) {
		
//		MPUMediaControlsTitlesView *clone = (MPUMediaControlsTitlesView *)acapella.titlesClone;
//		[clone updateTrackInformationWithNowPlayingInfo:arg1];
		
		[NSObject cancelPreviousPerformRequestsWithTarget:acapella selector:@selector(finishWrapAround) object:nil];
		[acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.1];
		
	}
}

#pragma mark - SWAcapellaTitlesProtocol

%new
- (instancetype)acapella_copy
{
	@autoreleasepool {
		
		MPUMediaControlsTitlesView *copy = [[[self class] alloc] initWithMediaControlsStyle:self.mediaControlsStyle];
		copy.translatesAutoresizingMaskIntoConstraints = NO;
		copy.userInteractionEnabled = NO;
		
		copy._titleLabel.textColor = self._titleLabel.textColor;
		copy._detailLabel.textColor = self._detailLabel.textColor;
		copy.explicitImage = self.explicitImage;
		[copy setExplicit:[self isExplicit]];
		
		
		NSMutableDictionary *nowPlayingInfo = [NSMutableDictionary new];
		
		if (self.titleText) {
			[nowPlayingInfo setObject:self.titleText forKey:@"kMRMediaRemoteNowPlayingInfoTitle"];
		}
		if (self.artistText) {
			[nowPlayingInfo setObject:self.artistText forKey:@"kMRMediaRemoteNowPlayingInfoArtist"];
		}
		if (self.albumText) {
			[nowPlayingInfo setObject:self.albumText forKey:@"kMRMediaRemoteNowPlayingInfoAlbum"];
		}
		
		[copy updateTrackInformationWithNowPlayingInfo:[nowPlayingInfo copy]];
		
		return copy;
		
	}
}

%end




