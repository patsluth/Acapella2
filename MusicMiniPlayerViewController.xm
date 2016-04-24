//
//  MusicMiniPlayerViewController.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "MusicMiniPlayerViewController+SW.h"
#import "MPUTransportControlsView+SW.h"

#import "SWAcapella.h"
#import "SWAcapellaPrefs.h"
//#import "SWAcapellaMediaItemPreviewViewController.h"

#import "libsw/libSluthware/libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MusicTabBarController.h"

#define MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER MSHookIvar<MPUTransportControlMediaRemoteController \
                                                            *>(self, "_transportControlMediaRemoteController")





#pragma mark - MusicMiniPlayerViewController

%hook MusicMiniPlayerViewController

#pragma mark - Init

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
    
    // Initialize prefs for this instance
    if (self.acapellaKeyPrefix) {
        self.acapellaPrefs = [[SWAcapellaPrefs alloc] initWithKeyPrefix:self.acapellaKeyPrefix];
    }
    
    
    //Reload our transport buttons
    //See [self transportControlsView:arg1 buttonForControlType:arg2];
    
    //LEFT SECTION
    [self.transportControlsView reloadTransportButtonWithControlType:1];
    [self.transportControlsView reloadTransportButtonWithControlType:3];
    [self.transportControlsView reloadTransportButtonWithControlType:4];
    
    //RIGHT SECTION
    [self.secondaryTransportControlsView reloadTransportButtonWithControlType:7];
    [self.secondaryTransportControlsView reloadTransportButtonWithControlType:11];
    
    [self viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    
    // special case where the pref key prefix is not ready in viewWillAppear, but it will always be ready here
    if (!self.acapellaPrefs) {
        [self viewWillAppear:NO];
    }
    
    
    if (!self.acapella) {
        
        if (self.acapellaPrefs.enabled) {
            
            [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                          preInitializeAction:^(SWAcapella *a) {
                                                              
                                                              a.owner = self;
                                                              a.titles = self.titlesView;
                                                              
                                                          }]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
        }
        
    }
    
    if (self.acapella) {
        
        [self.nowPlayingPresentationPanRecognizer requireGestureRecognizerToFail:self.acapella.pan];
        
    }
    
    [self viewDidLayoutSubviews];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    self.acapellaPrefs = nil;
    
    %orig(animated);
}

- (void)viewDidLayoutSubviews
{
	%orig();
	
	
	// Show/Hide progress slider
	if (self.acapellaPrefs && self.acapellaPrefs.enabled && !self.acapellaPrefs.progressslider) {
		self.playbackProgressView.layer.opacity = 0.0;
	} else {
		self.playbackProgressView.layer.opacity = 1.0;
	}
	
	
	// Update titles constraints
    CGRect titlesFrame = self.titlesView.frame;
    
    //intelligently calcualate titles frame based on visible transport controls
    if ([self.transportControlsView acapella_hidden]) {
        titlesFrame.origin.x = 0.0;
        titlesFrame.size.width = self.secondaryTransportControlsView.frame.origin.x;
    }
    
    if ([self.secondaryTransportControlsView acapella_hidden]) {
        titlesFrame.size.width = CGRectGetWidth(self.titlesView.superview.bounds) - titlesFrame.origin.x;
    }
	
	self.titlesView.frame = titlesFrame;
	
}

#pragma mark - Acapella(Helper)

%new
- (NSString *)acapellaKeyPrefix
{
	@autoreleasepool {
//		UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
//		
//		if (%c(MusicTabBarController) && [rootVC class] == %c(MusicTabBarController)) { // Music App
			return @"musicmini";
//		} else if (%c(MTMusicTabController) && [rootVC class] == %c(MTMusicTabController)) { // Podcast App
//			return @"podcastsmini";
//		}
//		
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
    //THESE CODES ARE DIFFERENT FROM THE MEDIA COMMANDS
    
    //LEFT SECTION
    //1 rewind (IPAD)
    //3 play/pause
    //4 forward (IPAD)
    
    //RIGHT SECTION
    //7 present up next (IPAD)
    //11 contextual
	
	
	// Sometimes this won't be ready until the view has appeared, so return nil so the buttons don't flash
	// once if acapella is enabled
	if (!self.acapellaPrefs) {
		return nil;
	}
	
	
    if (self.acapellaPrefs.enabled) {
        
        //LEFT SECTION
        if (arg2 == 1 && !self.acapellaPrefs.transport_previoustrack) {
            return nil;
        }
        
        if (arg2 == 3 && !self.acapellaPrefs.transport_playpause) {
            return nil;
        }
        
        if (arg2 == 4 && !self.acapellaPrefs.transport_nexttrack) {
            return nil;
        }
        
        //RIGHT SECTION
        if (arg2 == 7 && !self.acapellaPrefs.transport_upnext) {
            return nil;
        }
        
        if (arg2 == 11 && !self.acapellaPrefs.transport_contextual) {
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

- (void)_panRecognized:(id)arg1
{
//	if (self.acapella && self.acapella.blockingGestures) {
//		return;
//	}
	
	%orig(arg1);
}

- (void)_tapRecognized:(id)arg1
{
    if (!self.acapella) {
        %orig(arg1);
    }
}

#pragma mark - Acaplla(Actions)

%new
- (void)action_nil:(id)arg1
{
    //if tap and action is set to nil, perform the original tap action
    if (arg1 && [arg1 isKindOfClass:[UITapGestureRecognizer class]]) {
        [(MusicTabBarController *)self.parentViewController presentNowPlayingViewController];
    }
}

%new
- (void)action_heart:(id)arg1
{
}

%new
- (void)action_upnext:(id)arg1
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:7];
        
    } else {
        
        UIViewController<SWAcapellaDelegate> *nowPlayingViewController;
        nowPlayingViewController = [(MusicTabBarController *)self.parentViewController nowPlayingViewController];
        
        [self.parentViewController presentViewController:nowPlayingViewController
                                                animated:YES
                                              completion:^() {
                                                  
                                                  [nowPlayingViewController action_upnext:nil];
                                                  
                                              }];
        
    }
}

%new
- (void)action_previoustrack:(id)arg1
{
    [self transportControlsView:self.transportControlsView tapOnControlType:1];
}

%new
- (void)action_nexttrack:(id)arg1
{
    [self transportControlsView:self.transportControlsView tapOnControlType:4];
}

%new
- (void)action_intervalrewind:(id)arg1
{
     [self transportControlsView:self.transportControlsView tapOnControlType:2];
}

%new
- (void)action_intervalforward:(id)arg1
{
    [self transportControlsView:self.transportControlsView tapOnControlType:5];
}

%new
- (void)action_seekrewind:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressBeginOnControlType:1];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:1];
    }
}

%new
- (void)action_seekforward:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressBeginOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:self.transportControlsView longPressEndOnControlType:4];
    }
}

%new
- (void)action_playpause:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControlsView longPressEndOnControlType:1];
    [self transportControlsView:self.transportControlsView longPressEndOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    //if the 2 commands are different, then something happened when we told the transportControlView to
    //stop seeking, meaning we were seeking
    if (originalLPCommand == newLPCommand) {
        [self transportControlsView:self.transportControlsView tapOnControlType:3];
    }
    
    [self.acapella pulseAnimateView];
}

%new
- (void)action_share:(id)arg1
{
}

%new
- (void)action_toggleshuffle:(id)arg1
{
}

%new
- (void)action_togglerepeat:(id)arg1
{
}

%new
- (void)action_contextual:(id)arg1
{
    [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:11];
}

%new
- (void)action_openapp:(id)arg1
{
}

%new
- (void)action_showratings:(id)arg1
{
}

%new
- (void)action_decreasevolume:(id)arg1
{
}

%new
- (void)action_increasevolume:(id)arg1
{
}

%new
- (void)action_equalizereverywhere:(id)arg1
{
}

//#pragma mark - UIViewControllerPreviewing
//
//%new // peek
//- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
//{
//    if (!self.acapella || self.presentedViewController) {
//        return nil;
//    }
//    
//    SWAcapellaMediaItemPreviewViewController *previewViewController = [[SWAcapellaMediaItemPreviewViewController alloc] initWithDelegate:self];
//    [previewViewController configureWithCurrentNowPlayingInfo];
//    
//    
//    CGFloat xPercentage = location.x / CGRectGetWidth(self.view.bounds);
//    
//    if (xPercentage <= 0.25) { // left
//        
//        previewViewController.popAction = self.acapellaPrefs.gestures_popactionleft;
//        previewViewController.acapellaPreviewActionItems = @[[previewViewController intervalRewindAction],
//                                                             [previewViewController seekRewindAction]];
//        
//    } else if (xPercentage > 0.75) { // right
//        
//        previewViewController.popAction = self.acapellaPrefs.gestures_popactionright;
//        previewViewController.acapellaPreviewActionItems = @[[previewViewController intervalForwardAction],
//                                                             [previewViewController seekForwardAction]];
//        
//    } else { // centre
//        
//        previewViewController.popAction = self.acapellaPrefs.gestures_popactioncentre;
//        previewViewController.acapellaPreviewActionItems = @[[previewViewController upNextAction],
//                                                             [previewViewController contextualAction]];
//        
//    }
//    
//    
//    return previewViewController;
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

#pragma mark - logos

%group preiOS9 //add these if pre iOS 9 so we dont crash calling them

%new
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2
{
}

%new
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2
{
}

%end

%end






%ctor
{
    %init(_ungrouped);
    
    if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
        %init(preiOS9);
    }
    
}




