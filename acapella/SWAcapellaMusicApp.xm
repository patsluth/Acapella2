

#import <AcapellaKit/AcapellaKit.h>
#import <libsw/sluthwareios/sluthwareios.h>
#import "SWAcapellaSharingFormatter.h"
#import "SWAcapellaPrefsBridge.h"

#import <MediaRemote/MediaRemote.h>

#import "MusicNowPlayingViewController+SW.h"
#import "MPAVController.h"
#import "MPAVItem.h"
#import "MPUNowPlayingTitlesView.h"
#import "MPDetailSlider.h"
#import "MPVolumeSlider.h"
#import "AVSystemController+SW.h"

#import "substrate.h"
#import <objc/runtime.h>





#pragma mark MusicNowPlayingViewController

static SWAcapellaBase *_acapella;
static UIActivityViewController *_acapellaSharingActivityView;





@interface MusicNowPlayingViewController()
{
}

@property (strong, nonatomic) UIActivityViewController *acapellaSharingActivityView;

- (void)startRatingShouldHideTimer;
- (void)hideRatingControlWithTimer;

@end





%hook MusicNowPlayingViewController

#pragma mark Helper

%new
- (UIView *)playbackControlsView
{
	return MSHookIvar<UIView *>(self, "_playbackControlsView");
}

%new
- (MPAVController *)player
{
	if ([self playbackControlsView]){
    	return MSHookIvar<MPAVController *>([self playbackControlsView], "_player");
	}
	
	return nil;
}

%new
- (UISlider *)progressControl
{
    if ([self playbackControlsView]){
    	return MSHookIvar<UISlider *>([self playbackControlsView], "_progressControl");
	}
	
	return nil;
}

%new
- (UIView *)transportControls
{
    if ([self playbackControlsView]){
    	return MSHookIvar<UIView *>([self playbackControlsView], "_transportControls");
	}
	
	return nil;
}

%new
- (UISlider *)volumeSlider
{
    if ([self playbackControlsView]){
    	return MSHookIvar<UISlider *>([self playbackControlsView], "_volumeSlider");
	}
	
	return nil;
}

%new
- (UIView *)ratingControl
{
	return MSHookIvar<UIView *>(self, "_ratingControl");
}

%new
- (UIView *)titlesView
{
	return MSHookIvar<UIView *>(self, "_titlesView");
}

%new
- (UIView *)repeatButton
{
    if ([self playbackControlsView]){
    	return MSHookIvar<UIView *>([self playbackControlsView], "_repeatButton");
	}
	
	return nil;
}

%new
- (UIImageView *)artworkView
{
	UIView *artwork = MSHookIvar<UIView *>(self, "_contentView");
    
    if (artwork && [artwork isKindOfClass:[UIImageView class]]){
        return (UIImageView *)artwork;
    }
    
    return nil;
}

%new
- (MPAVItem *)mpavItem
{
	return MSHookIvar<MPAVItem *>(self, "_item");
}

%new
- (UIButton *)likeOrBanButton
{
	if ([self transportControls]){
    	return MSHookIvar<UIButton *>([self transportControls], "_likeOrBanButton");
	}
	
	return nil;
}

%new
- (SWAcapellaBase *)acapella
{
    return objc_getAssociatedObject(self, &_acapella);
}

%new
- (void)setAcapella:(SWAcapellaBase *)acapella
{
    objc_setAssociatedObject(self, &_acapella, acapella, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (UIActivityViewController *)acapellaSharingActivityView
{
    return objc_getAssociatedObject(self, &_acapellaSharingActivityView);
}

%new
- (void)setAcapellaSharingActivityView:(UIActivityViewController *)acapellaSharingActivityView
{
    objc_setAssociatedObject(self, &_acapellaSharingActivityView, acapellaSharingActivityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark Init

- (void)viewDidLoad
{
    %orig();
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    if ([self playbackControlsView]){
    
		if ([self progressControl] && [self progressControl].superview == [self playbackControlsView]){
            [[self progressControl] removeFromSuperview];
        }
        
        if ([self transportControls] && [self transportControls].superview == [self playbackControlsView]){
            [[self transportControls] removeFromSuperview];
        }
        
        if ([self volumeSlider] && [self volumeSlider].superview == [self playbackControlsView]){
            [[self volumeSlider] removeFromSuperview];
        }
        
        if ([self titlesView] && [self titlesView].superview && ![[self titlesView].superview isKindOfClass:[UIScrollView class]]){
            [[self titlesView] removeFromSuperview];
        }
        
        if ([self artworkView]){
    
			if (!self.acapella){
                self.acapella = [[%c(SWAcapellaBase) alloc] init];
                self.acapella.delegateAcapella = self;
            }
            
			if (([self progressControl] && [self progressControl].isTracking) || ([self volumeSlider] && [self volumeSlider].isTracking)){
	            return;
            }
            
			CGFloat artworkBottomYOrigin = [self artworkView].frame.origin.y + [self artworkView].frame.size.height;
            //set the bottom acapella origin to the top of the repeat button. Set it to the bottom of the view if repeat button hasnt been set up yet.
            CGFloat bottomAcapellaYOrigin = (([self repeatButton].frame.origin.y <= 0.0) ?
                                             [self playbackControlsView].frame.origin.y + [self playbackControlsView].frame.size.height :
                                             [self repeatButton].frame.origin.y)
                                                                                 - artworkBottomYOrigin;
            
            self.acapella.frame = CGRectMake([self playbackControlsView].frame.origin.x,
                                             artworkBottomYOrigin,
                                             //the space between the bottom of the artowrk and the bottom of the screen
                                             [self playbackControlsView].frame.size.width,
                                             bottomAcapellaYOrigin);
        
            if ([self ratingControl]){
				[self ratingControl].frame = self.acapella.frame;
            }                         
            
            [[self playbackControlsView] addSubview:self.acapella];
            
            if ([self progressControl].frame.size.height * 1.5 != self.acapella.acapellaTopAccessoryHeight){
                self.acapella.acapellaTopAccessoryHeight = [self progressControl].frame.size.height * 1.5;
            }
            
            if ([self volumeSlider].frame.size.height * 2.0 != self.acapella.acapellaBottomAccessoryHeight){
                self.acapella.acapellaBottomAccessoryHeight = [self volumeSlider].frame.size.height * 2.0;
            }
            
        }
    }
}

- (void)viewWillAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
    
	if (self.acapella){
        if (self.acapella.tableview){
            [self.acapella.tableview resetContentOffset:NO];
        }
        if (self.acapella.scrollview){
            [self.acapella.scrollview resetContentOffset:NO];
        }
    }
}

- (void)viewDidAppear:(BOOL)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
    
	if (self.acapella){
        if (self.acapella.tableview){
            [self.acapella.tableview resetContentOffset:NO];
        }
        if (self.acapella.scrollview){
            [self.acapella.scrollview resetContentOffset:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)arg1
{
    %orig(arg1);
    
    //make sure we clean this up, so we can display it again later
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:^{
    	if (self.acapellaSharingActivityView){
    		self.acapellaSharingActivityView.completionHandler = nil;
        	self.acapellaSharingActivityView = nil;
		}
    }];
}

- (void)viewDidDisappear:(BOOL)arg1
{
    %orig(arg1);
}

/*
- (void)willAnimateRotationToInterfaceOrientation:(int)arg1 duration:(double)arg2
{
    %orig(arg1, arg2);
    
    [self viewDidLayoutSubviews];
}

- (void)didRotateFromInterfaceOrientation:(int)arg1
{
    %orig(arg1);
    
    [self viewDidLayoutSubviews];
}
*/

#pragma mark SWAcapellaDelegate


%new
- (void)swAcapella:(SWAcapellaBase *)view onTap:(UITapGestureRecognizer *)tap percentage:(CGPoint)percentage
{
	if (tap.state == UIGestureRecognizerStateEnded){
        
        CGFloat percentBoundaries = 0.25;
        
        if (percentage.x <= percentBoundaries){ //left
            [%c(AVSystemController) acapellaChangeVolume:-1];
        } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
            
            if (self.player){
                [self.player togglePlayback];
            }
            
            [UIView animateWithDuration:0.1
                             animations:^{
                                 view.tableview.transform = CGAffineTransformMakeScale(0.9, 0.9);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      view.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      view.tableview.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }];
                             }];
            
        } else if (percentage.x > (1.0 - percentBoundaries)){ //right
            [%c(AVSystemController) acapellaChangeVolume:1];
        }
        
    }
}

%new
- (void)swAcapella:(id<SWAcapellaScrollViewProtocol>)view onSwipe:(SW_SCROLL_DIRECTION)direction
{
	if (direction == SW_SCROLL_DIR_LEFT || direction == SW_SCROLL_DIR_RIGHT){
        
        if (self.player){
            
            [view stopWrapAroundFallback]; //we will finish the animation manually once the songs has changed and the UI has been updated
            
            long skipDirection = (direction == SW_SCROLL_DIR_LEFT) ? -1 : 1;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.player changePlaybackIndexBy:(int)skipDirection deltaType:0 ignoreElapsedTime:NO allowSkippingUnskippableContent:YES];
            }];
            
        } else {
            [view finishWrapAroundAnimation];
        }
        
    } else {
    
        [view stopWrapAroundFallback];
        
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(CFDictionaryRef result){
    		if (result){
    		
    			NSDictionary *resultDict = (__bridge NSDictionary *)result;
    		
    			NSString *mediaTitle = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
    			NSString *mediaArtist = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
    			NSData *mediaArtworkData = [resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtworkData];
    			NSString *sharingHashtag = [%c(SWAcapellaPrefsBridge) valueForKey:@"sharingHashtag"];
    			
    			if (!sharingHashtag || [sharingHashtag isEqualToString:@""]){
        			sharingHashtag = @"acapella";
    			}
    			
				NSArray *shareData = [%c(SWAcapellaSharingFormatter) formattedShareArrayWithMediaTitle:mediaTitle
																							mediaArtist:mediaArtist
																							mediaArtworkData:mediaArtworkData
																							sharingHashtag:sharingHashtag];
																							
				if (shareData){
					[[NSOperationQueue mainQueue] addOperationWithBlock:^{
    		
						self.acapellaSharingActivityView = [[UIActivityViewController alloc] initWithActivityItems:shareData applicationActivities:nil];
						[self presentViewController:self.acapellaSharingActivityView animated:YES completion:nil];
						self.acapellaSharingActivityView.completionHandler = ^(NSString *activityType, BOOL completed){
							[view finishWrapAroundAnimation];
						};
    				
					}];
				} else {
					[view finishWrapAroundAnimation];
				}
    		
    		} else {
        		[view finishWrapAroundAnimation];
    		}
    	});
    }
}

%new
- (void)swAcapella:(SWAcapellaBase *)view onLongPress:(UILongPressGestureRecognizer *)longPress percentage:(CGPoint)percentage
{
 	CGFloat percentBoundaries = 0.25;
    
    if (percentage.x <= percentBoundaries){ //left
        
        if (longPress.state == UIGestureRecognizerStateBegan){
            MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(CFDictionaryRef result){
	    		if (result){
	    			NSDictionary *resultDict = (__bridge NSDictionary *)result;
	    			double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
	    			MRMediaRemoteSetElapsedTime(mediaCurrentElapsedDuration - 20.0);
	    		}
	    	});
        }
        
    } else if (percentage.x > percentBoundaries && percentage.x <= (1.0 - percentBoundaries)){ //centre
        
        if (longPress.state == UIGestureRecognizerStateBegan){
        
        	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				if ([self mpavItem] && [self mpavItem].isRadioItem){
	        
					if ([self likeOrBanButton]){
						[[self likeOrBanButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
					}
	        
				} else {
					[self _setShowingRatings:YES animated:YES];
				}
			}];
        
        }
        
    } else if (percentage.x > (1.0 - percentBoundaries)){ //right
        
		if (longPress.state == UIGestureRecognizerStateBegan){
            MRMediaRemoteGetNowPlayingInfo(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^(CFDictionaryRef result){
	    		if (result){
	    			NSDictionary *resultDict = (__bridge NSDictionary *)result;
	    			double mediaCurrentElapsedDuration = [[resultDict valueForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];
	    			MRMediaRemoteSetElapsedTime(mediaCurrentElapsedDuration + 20.0);
	    		}
	    	});
        }
        
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if ([self playbackControlsView]){
        
        if (indexPath.section == 0){
            switch (indexPath.row) {
                case 0:
                    
                    break;
                    
                case 1:
                    
                    if ([self volumeSlider]){
                        [[self volumeSlider] removeFromSuperview];
                    }
                    
                    if ([self progressControl]){
                        [cell addSubview:[self progressControl]];
                        [[self progressControl] setFrame:[self progressControl].frame]; //update our frame because are forcing centre in setRect:
                    }
                    
                    break;
                    
                case 2:
                    
                    [view.scrollview addSubview:[self titlesView]];
                    [[self titlesView] setFrame:[self titlesView].frame]; //update our frame because are forcing centre in setRect:
                    
                    break;
                    
                case 3:
                    
                    if ([self progressControl]){
                        [[self progressControl] removeFromSuperview];
                    }
                    
                    if ([self volumeSlider]){
                        [cell addSubview:[self volumeSlider]];
                        [[self volumeSlider] setFrame:[self volumeSlider].frame]; //update our frame because are forcing centre in setRect:
                    }
                    
                    break;
                    
                case 4:
                    
                    break;
                    
                default:
                    break;
            }
        }
        
    }
}

%new
- (void)swAcapalle:(SWAcapellaBase *)view didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark Other

/*
- (void)_updateForCurrentItemAnimated:(BOOL)arg1
{
	NSLog(@"PAT TEST %@--%@", self, SW_STRING_FROM_BOOL(arg1));
    %orig(NO); //for some reason if we animate our scroll view while the album art change is animating, it is very jumpy
}
*/

#pragma mark Rating

static BOOL _didTouchRatingControl = NO;
static NSTimer *_hideRatingTimer;

- (void)_setShowingRatings:(BOOL)arg1 animated:(BOOL)arg2
{
    %orig(arg1, arg2);
    
	if (arg1){
        [self startRatingShouldHideTimer];
    } else {
        if (_hideRatingTimer){
            [_hideRatingTimer invalidate];
            _hideRatingTimer = nil;
        }
    }
}

%new
- (void)startRatingShouldHideTimer
{
	BOOL isShowingRating = MSHookIvar<BOOL>(self, "_isShowingRatings");
    
    if (_hideRatingTimer){
        [_hideRatingTimer invalidate];
        _hideRatingTimer = nil;
    }
    
    if (!isShowingRating){
        return;
    }
    
    _hideRatingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                       target:self
                                                     selector:@selector(hideRatingControlWithTimer)
                                                     userInfo:nil
                                                      repeats:NO];
}

%new
- (void)hideRatingControlWithTimer
{
	BOOL isShowingRating = MSHookIvar<BOOL>(self, "_isShowingRatings");
    
    if (!isShowingRating){
        _didTouchRatingControl = NO;
        return;
    }
    
    if (_didTouchRatingControl){
        _didTouchRatingControl = NO;
        [self startRatingShouldHideTimer];
        return;
    }
    
    [self _setShowingRatings:NO animated:YES];
    _didTouchRatingControl = NO;
}

%end




%hook MPURatingControl //keep track of touches and delay our hide timer

- (void)_handlePanGesture:(id)arg1
{
    %orig(arg1);
    
    _didTouchRatingControl = YES;
}

- (void)_handleTapGesture:(id)arg1
{
    %orig(arg1);
    
    _didTouchRatingControl = YES;
}

%end





%hook MPDetailSlider

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
	if (self.superview && ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





%hook MPVolumeSlider

- (void)setFrame:(CGRect)frame
{
    //iOS 7 superview is a UITableViewCellScrollView iOS 8 is UITableViewCell :$
	if (self.superview && ([self.superview isKindOfClass:[UITableViewCell class]] || [self.superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")])){
        
        %orig(CGRectMake((self.superview.frame.size.width / 2) - (frame.size.width / 2),
                         (self.superview.frame.size.height / 2) - (frame.size.height / 2),
                         frame.size.width,
                         frame.size.height));
        
        return;
        
    }
    
    %orig(frame);
}

%end





#pragma mark logos

%ctor
{
    NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/Frameworks/AcapellaKit.framework"];
    [bundle load];
}