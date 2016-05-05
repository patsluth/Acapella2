//
//  MusicNowPlayingViewController.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "MusicNowPlayingViewController+SW.h"
#import "MPUTransportControlsView+SW.h"

#import "SWAcapella.h"
#import "SWAcapellaPrefs.h"
//#import "SWAcapellaMediaItemPreviewViewController.h"

#import "libsw/libSluthware/libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"

#define MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER MSHookIvar<MPUTransportControlMediaRemoteController \
                                                            *>(self, "_transportControlMediaRemoteController")





#pragma mark - MusicNowPlayingViewController

%hook MusicNowPlayingViewController

#pragma mark - Init

- (void)viewWillAppear:(BOOL)animated
{
	%orig(animated);
    
    
    // Initialize prefs for this instance
    if (self.acapellaKeyPrefix) {
        self.acapellaPrefs = [[SWAcapellaPrefs alloc] initWithKeyPrefix:self.acapellaKeyPrefix];
    }
    
    
    // Reload our transport buttons
    // See [self transportControlsView:arg1 buttonForControlType:arg2];
    
    // TOP ROW
    [self.transportControls reloadTransportButtonWithControlType:6];
    [self.transportControls reloadTransportButtonWithControlType:1];
    [self.transportControls reloadTransportButtonWithControlType:2];
    [self.transportControls reloadTransportButtonWithControlType:3];
    [self.transportControls reloadTransportButtonWithControlType:4];
    [self.transportControls reloadTransportButtonWithControlType:5];
    [self.transportControls reloadTransportButtonWithControlType:7];
    
    // BOTTOM ROW
    [self.secondaryTransportControls reloadTransportButtonWithControlType:8];
    [self.secondaryTransportControls reloadTransportButtonWithControlType:10];
    [self.secondaryTransportControls reloadTransportButtonWithControlType:9];
    [self.secondaryTransportControls reloadTransportButtonWithControlType:11];
    
    // PODCAST TOP ROW
    [self.transportControls reloadTransportButtonWithControlType:12];
    // PODCAST BOTTOM ROW
    [self.secondaryTransportControls reloadTransportButtonWithControlType:13];
    
    [self viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    
    // Special case where the pref key prefix is not ready in viewWillAppear, but it will always be ready here
    if (!self.acapellaPrefs) {
        [self viewWillAppear:NO];
    }
    
    
    if (!self.acapella) {
        
        if (self.acapellaPrefs.enabled) {
            
			[SWAcapella setAcapella:[[SWAcapella alloc] initWithOwner:self
														referenceView:self.titlesView.superview
															   titles:self.titlesView]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
        }
        
    }
	
//	if (self.acapella) {
//	}
	[self viewDidLayoutSubviews];
	
}

- (void)viewDidDisappear:(BOOL)animated
{
	%orig(animated);
	
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    self.acapellaPrefs = nil;
}

- (void)viewDidLayoutSubviews
{
	%orig();
	
	
    BOOL progressVisible = YES;
    BOOL volumeVisible = YES;
    
    if (self.acapellaPrefs && self.acapellaPrefs.enabled) {
        progressVisible = self.acapellaPrefs.progressslider;
		volumeVisible = self.acapellaPrefs.volumeslider;
		self.dismissButton.hidden = YES;
	} else {
		self.dismissButton.hidden = NO;
	}
		
    // Show/Hide sliders
    self.playbackProgressSliderView.layer.opacity = progressVisible ? 1.0 : 0.0;
    self.volumeSlider.layer.opacity = volumeVisible ? 1.0 : 0.0;
    
    // Pinnning views responsible for drawing knobs
    for (UIView *subview in self.vibrantEffectView.subviews) {
        if (%c(MPUPinningView) && [subview isKindOfClass:%c(MPUPinningView)]) {
            
            id pinningSourceLayer = [subview valueForKey:@"pinningSourceLayer"];
            id progressLayer = [[self.playbackProgressSliderView valueForKey:@"_playbackProgressSlider"] valueForKey:@"layer"];
            
            if (pinningSourceLayer == progressLayer) {
                subview.hidden = !progressVisible;
            } else if (pinningSourceLayer == self.volumeSlider.layer) {
                subview.hidden = !volumeVisible;
            }
            
        }
    }
    
    
    
    // Intelligently calcualate centre based on visible controls, which we dont want to do on iPAD
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) { return; }
    
    
    CGFloat topGuideline = CGRectGetMinY(self.playbackProgressSliderView.frame);
    
    if (self.playbackProgressSliderView.layer.opacity > 0.0) { // Visible
        topGuideline += CGRectGetHeight(self.playbackProgressSliderView.bounds);
    }
    
    
    CGFloat bottomGuideline = CGRectGetMinY(self.transportControls.frame); // Top of primary transport controls
    
    
    if ([self.transportControls acapella_hidden]) {
        
        bottomGuideline = CGRectGetMinY(self.volumeSlider.frame); // Top of volume slider
        
        if (self.volumeSlider.layer.opacity <= 0.0) { // Hidden
            
            bottomGuideline = CGRectGetMinY(self.secondaryTransportControls.frame); // Top of transport secondary controls
            
            if ([self.secondaryTransportControls acapella_hidden]) {
                bottomGuideline = CGRectGetMaxY(self.titlesView.superview.bounds); // Bottom of screen
            }
            
        }
        
    }
	
	
	// The midpoint between the currently visible views. This is where we will place our titles
	NSInteger midPoint = (topGuideline + (fabs(topGuideline - bottomGuideline) / 2.0));
	self.titlesView.center = CGPointMake(self.titlesView.center.x, midPoint);
	
}

#pragma mark - Acapella(Helper)

%new
- (NSString *)acapellaKeyPrefix
{
	@autoreleasepool {
//
//		UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//		
//		if (%c(MusicTabBarController) && [rootVC class] == %c(MusicTabBarController)) { // Music App
			return @"musicnowplaying";
//		} else if (%c(MTMusicTabController) && [rootVC class] == %c(MTMusicTabController)) { // Podcast App
//			return @"podcastsnowplaying";
//		}
//		
	}

    return nil;
}

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    // TRANSPORT CONTROL TYPES
    // THESE CODES ARE DIFFERENT FROM THE MEDIA COMMANDS
    
    // TOP ROW
    // 6 like/ban
    // 1 rewind
    // 2 interval rewind
    // 3 play/pause
    // 4 forward
    // 5 interval forward
    // 7 present up next
    
    // BOTTOM ROW
    // 8 share
    // 10 shuffle
    // 9 repeat
    // 11 contextual
    
    // PODCAST TOP ROW
    // 12 playback rate (1x, 2x etc. )
    // PODCAST BOTTOM ROW
    // 13 sleep timer
	
	
	// Sometimes this won't be ready until the view has appeared, so return nil so the buttons don't flash
	// once if acapella is enabled
	if (!self.acapellaPrefs) {
		return nil;
	}
	
    
    if (self.acapellaPrefs.enabled) {
        
        // TOP ROW
        if (arg2 == 6 && !self.acapellaPrefs.transport_heart) {
            return nil;
        }
        
        if (arg2 == 1 && !self.acapellaPrefs.transport_previoustrack) {
            return nil;
        }
        
        if (arg2 == 2 && !self.acapellaPrefs.transport_intervalrewind) {
            return nil;
        }
        
        if (arg2 == 3 && !self.acapellaPrefs.transport_playpause) {
            return nil;
        }
        
        if (arg2 == 4 && !self.acapellaPrefs.transport_nexttrack) {
            return nil;
        }
        
        if (arg2 == 5 && !self.acapellaPrefs.transport_intervalforward) {
            return nil;
        }
        
        if (arg2 == 7 && !self.acapellaPrefs.transport_upnext) {
            return nil;
        }
        
        // BOTTOM ROW
        if (arg2 == 8 && !self.acapellaPrefs.transport_share) {
            return nil;
        }
        
        if (arg2 == 10 && !self.acapellaPrefs.transport_shuffle) {
            return nil;
        }
        
        if (arg2 == 9 && !self.acapellaPrefs.transport_repeat) {
            return nil;
        }
        
        if (arg2 == 11 && !self.acapellaPrefs.transport_contextual) {
            return nil;
        }
        
        // PODCAST TOP ROW
        if (arg2 == 12 && !self.acapellaPrefs.transport_playbackrate) {
            return nil;
        }

        // PODCAST BOTTOM ROW
        if (arg2 == 13 && !self.acapellaPrefs.transport_sleeptimer) {
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

- (void)_handleTapGestureRecognizerAction:(UITapGestureRecognizer *)arg1 //tap on artwork
{
	if (self.acapella) {
		
		// touch is on the artwork view
		if (![[arg1.view hitTest:[arg1 locationInView:arg1.view] withEvent:nil] isDescendantOfView:self.currentItemViewControllerContainerView]) {
			return;
		}
	}
	
	%orig(arg1);
}

/**
 *  Called when dismissing the UpNext view controller
 *
 *  @param arg1
 */
- (void)dismissDetailViewController:(id)arg1
{
	%orig(arg1);
	
	[self _setRatingsVisible:NO];
}

- (void)_showUpNext
{
	if (self.acapella) {
		self.acapella.titlesClone.hidden = YES;
		self.acapella.titles.layer.opacity = 0.0;
	}
	
    %orig();
}

- (void)_showUpNext:(id)arg1
{
	if (self.acapella) {
		self.acapella.titlesClone.hidden = YES;
		self.acapella.titles.layer.opacity = 0.0;
	}
	
	%orig(arg1);
}

- (void)_setRatingsVisible:(BOOL)arg1
{
	%orig(arg1);
	
	if (self.acapella) {
		self.acapella.titlesClone.hidden = arg1;
		self.acapella.titles.layer.opacity = self.acapella.titlesClone.hidden ? 1.0 : 0.0;
	}
}

#pragma mark - Acaplla(Actions)

%new
- (void)action_nil:(id)arg1
{
}

%new
- (void)action_heart:(id)arg1
{
    [self transportControlsView:self.transportControls tapOnControlType:6];
}

%new
- (void)action_upnext:(id)arg1
{
    [self transportControlsView:self.transportControls tapOnControlType:7];
}

%new
- (void)action_previoustrack:(id)arg1
{
    [self transportControlsView:self.transportControls tapOnControlType:1];
}

%new
- (void)action_nexttrack:(id)arg1
{
    [self transportControlsView:self.transportControls tapOnControlType:4];
}

%new
- (void)action_intervalrewind:(id)arg1
{
    [self transportControlsView:self.transportControls tapOnControlType:2];
}

%new
- (void)action_intervalforward:(id)arg1
{
    [self transportControlsView:self.transportControls tapOnControlType:5];
}

%new
- (void)action_seekrewind:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControls longPressBeginOnControlType:1];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControls longPressEndOnControlType:1];
    }
}

%new
- (void)action_seekforward:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControls longPressBeginOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControls longPressEndOnControlType:4];
    }
}

%new
- (void)action_playpause:(id)arg1
{
//    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
//    
//    [self transportControlsView:self.transportControls longPressEndOnControlType:1];
//    [self transportControlsView:self.transportControls longPressEndOnControlType:4];
//    
//    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
//    
//    //if the 2 commands are different, then something happened when we told the transportControlView to
//    //stop seeking, meaning we were seeking
//    if (originalLPCommand == newLPCommand) {
        [self transportControlsView:self.transportControls tapOnControlType:3];
    //}
    
    [self.acapella pulse];
}

%new
- (void)action_share:(id)arg1
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:8];
}

%new
- (void)action_toggleshuffle:(id)arg1
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:10];
}

%new
- (void)action_togglerepeat:(id)arg1
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:9];
}

%new
- (void)action_contextual:(id)arg1
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:11];
}

%new
- (void)action_openapp:(id)arg1
{
}

%new
- (void)action_showratings:(id)arg1
{
    [self _setRatingsVisible:self.ratingControl.hidden];
}

%new
- (void)action_decreasevolume:(id)arg1
{
    id vc = [self.volumeSlider valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(-1) afterDelay:0.0];
}

%new
- (void)action_increasevolume:(id)arg1
{
    id vc = [self.volumeSlider valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(1) afterDelay:0.0];
}

%new
- (void)action_equalizereverywhere:(id)arg1
{
}

#pragma mark - UIViewControllerPreviewing

//%new // peek
//- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
//{
//    if (!self.acapella || self.presentedViewController) {
//        return nil;
//    }
//    
//    // Show the entire media control area as the source rect, not just the titles view
//    CGRect sourceRect = self.playbackProgressSliderView.frame;
//    sourceRect.size.height = CGRectGetHeight(self.view.bounds) - sourceRect.origin.y;
//    previewingContext.sourceRect = sourceRect;
//    
//    if (CGRectContainsPoint(sourceRect, location)) { // Don't allow previewing if outside the media control area
//        
//        SWAcapellaMediaItemPreviewViewController *previewViewController = [[SWAcapellaMediaItemPreviewViewController alloc] initWithDelegate:self];
//        [previewViewController configureWithCurrentNowPlayingInfo];
//        
//        
//        CGFloat xPercentage = location.x / CGRectGetWidth(self.view.bounds);
//        
//        if (xPercentage <= 0.25) { // left
//            
//            previewViewController.popAction = self.acapellaPrefs.gestures_popactionleft;
//            previewViewController.acapellaPreviewActionItems = @[[previewViewController intervalRewindAction],
//                                                                 [previewViewController seekRewindAction]];
//            
//        } else if (xPercentage > 0.75) { // right
//            
//            previewViewController.popAction = self.acapellaPrefs.gestures_popactionright;
//            previewViewController.acapellaPreviewActionItems = @[[previewViewController intervalForwardAction],
//                                                                 [previewViewController seekForwardAction]];
//            
//        } else { // centre
//            
//            previewViewController.popAction = self.acapellaPrefs.gestures_popactioncentre;
//            previewViewController.acapellaPreviewActionItems = @[[previewViewController heartAction],
//                                                                 [previewViewController upNextAction],
//                                                                 [previewViewController shareAction],
//                                                                 [previewViewController contextualAction],
//                                                                 [previewViewController showRatingsAction]];
//            
//        }
//        
//        
//        return previewViewController;
//        
//    }
//    
//    
//    return nil;
//}
//
//%new // pop
//- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
//commitViewController:(SWAcapellaMediaItemPreviewViewController *)viewControllerToCommit
//{
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        
//        SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@:", viewControllerToCommit.popAction]);
//        
//        if (sel && [self respondsToSelector:sel]) {
//            [self performSelectorOnMainThread:sel withObject:nil waitUntilDone:NO];
//        }
//        
//    });
//}

#pragma mark - Associated Objects

%new
- (SWAcapellaPrefs *)acapellaPrefs
{
    return objc_getAssociatedObject(self, @selector(_acapellaPrefs));
}

%new
- (void)setAcapellaPrefs:(SWAcapellaPrefs *)acapellaPrefs
{
    objc_setAssociatedObject(self, @selector(_acapellaPrefs), acapellaPrefs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Testing

//- (void)_setRatingsVisible:(BOOL)arg1
//{
//	%orig(arg1);
//}

%end




