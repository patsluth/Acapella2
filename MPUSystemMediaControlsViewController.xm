//
//  MPUSystemMediaControlsViewController.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "MPUSystemMediaControlsViewController+SW.h"
#import "MPUTransportControlsView+SW.h"

#import "SWAcapella.h"
#import "SWAcapellaPrefs.h"
//#import "SWAcapellaMediaItemPreviewViewController.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWAppLauncher.h"

#import "MPUTransportControlMediaRemoteController.h"


#define MPU_SYSTEM_MEDIA_CONTROLS_VIEW MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView")
#define MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER MSHookIvar<MPUTransportControlMediaRemoteController \
                                                            *>(self, "_transportControlMediaRemoteController")





#pragma mark - MPUSystemMediaControlsView

@interface MPUSystemMediaControlsView : UIView
{
}

- (UIView *)timeInformationView;
- (UIView *)trackInformationView;
- (MPUTransportControlsView *)transportControlsView;
- (UIView *)volumeView;

@end





#pragma mark - MPUSystemMediaControlsViewController

%hook MPUSystemMediaControlsViewController

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
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView reloadTransportButtonWithControlType:6];
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView reloadTransportButtonWithControlType:1];
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView reloadTransportButtonWithControlType:2];
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView reloadTransportButtonWithControlType:3];
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView reloadTransportButtonWithControlType:4];
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView reloadTransportButtonWithControlType:5];
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView reloadTransportButtonWithControlType:8];
    
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW layoutSubviews];
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
                                                              a.titles = MPU_SYSTEM_MEDIA_CONTROLS_VIEW.trackInformationView;
                                                              
                                                          }]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
        }
        
    }
    
    
    if (self.acapella) {
        
        
        for (UIView *v in self.acapella.titles.subviews) { //button that handles titles tap
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton *b = (UIButton *)v;
                b.enabled = NO;
            }
        }
        
        // Show/Hide progress slider
        if (self.acapellaPrefs.enabled && !self.acapellaPrefs.progressslider) {
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.timeInformationView.layer.opacity = 0.0;
        } else {
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.timeInformationView.layer.opacity = 1.0;
        }
        
        //Show/Hide volume slider
        if (self.acapellaPrefs.enabled && !self.acapellaPrefs.volumeslider) {
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView.layer.opacity = 0.0;
        } else {
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView.layer.opacity = 1.0;
        }
        
        
    } else { //restore original state
        
        for (UIView *v in self.acapella.titles.subviews) { //button that handles titles tap
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton *b = (UIButton *)v;
                b.enabled = YES;
            }
        }
        
        MPU_SYSTEM_MEDIA_CONTROLS_VIEW.timeInformationView.layer.opacity = 1.0;
        MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView.layer.opacity = 1.0;
        
    }
    
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW layoutSubviews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    self.acapellaPrefs = nil;
    
    %orig(animated);
}

#pragma mark - Acapella(Helper)

%new
- (NSString *)acapellaKeyPrefix
{
    UIView *curView = self.view.superview;
    
    while (curView) {
        
#ifdef DEBUG
        id a = NSStringFromClass([curView class]);
        id b = NSStringFromClass([curView.superview class]);
        id c = NSStringFromClass([curView.window.rootViewController class]);
        NSLog(@"Acapella System Media Controls Log %@-%@-%@", a, b, c);
#endif
        
        @autoreleasepool {
            
            // Control Centre
            if (
                (%c(SBControlCenterRootView) && [curView class] == %c(SBControlCenterRootView)) ||
                //(%c(SBControlCenterSectionView) && [curView class] == %c(SBControlCenterSectionView)) || // Interfering with seng
                (%c(SBControlCenterContentView) && [curView class] == %c(SBControlCenterContentView))
                ) {
                return @"cc";
            }
            
            // Lock Screen
            if (%c(SBLockScreenView) && ([curView class] == %c(SBLockScreenView) ||
                                         [curView class] == %c(SBLockScreenScrollView))) {
                return @"ls";
            }
            
            // OnTapMusic - class will be null if tweak is not installed
            if (%c(OTMView) && [curView class] == %c(OTMView)) {
                return @"otm";
            }
            
            // Auxo LE - class will be null if tweak is not installed
            if (%c(AuxoCollectionView) && [curView class] == %c(AuxoCollectionView)) {
                return @"auxo";
            }
            
            // Vertex - Vertex has no classes ?
            if (%c(SBAppSwitcherContainer) && [curView class] == %c(SBAppSwitcherContainer)) {
                return @"vertex";
            }
            
            // Seng
            if ((%c(SengMediaSectionView) && [curView class] == %c(SengMediaSectionView)) ||
                (%c(SengMediaTitlesSectionView) && [curView class] == %c(SengMediaTitlesSectionView))) {
                return @"seng";
            }
            
        }
        
        curView = curView.superview;
        
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
    //6 like/ban
    //1 rewind
    //2 interval rewind
    //3 play/pause
    //4 forward
    //5 interval forward
    //8 share
    
    if (self.acapellaPrefs.enabled) {
    
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
        
        if (arg2 == 8 && !self.acapellaPrefs.transport_share) {
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

#pragma mark - Acapella(Actions)

%new
- (void)action_nil:(id)arg1
{
}

%new
- (void)action_heart:(id)arg1
{
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:6];
}

%new
- (void)action_upnext:(id)arg1
{
}

%new
- (void)action_previoustrack:(id)arg1
{
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:1];
    
    MPUTransportControlMediaRemoteController *t = MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER;
    
    if (![t.nowPlayingInfo valueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]) { //wrap around instantly if nothing is playing
        
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]) {
            [self.acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
        
    }
}

%new
- (void)action_nexttrack:(id)arg1
{
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:4];
    
    MPUTransportControlMediaRemoteController *t = MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER;
    
    if (![t.nowPlayingInfo valueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]) { //wrap around instantly if nothing is playing
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]) {
            [self.acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
    }
}

%new
- (void)action_intervalrewind:(id)arg1
{
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:2];
}

%new
- (void)action_intervalforward:(id)arg1
{
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:5];
}

%new
- (void)action_seekrewind:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressBeginOnControlType:1];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressEndOnControlType:1];
    }
}

%new
- (void)action_seekforward:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressBeginOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand) { //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressEndOnControlType:4];
    }
}

%new
- (void)action_playpause:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressEndOnControlType:1];
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressEndOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    //if the 2 commands are different, then something happened when we told the transportControlView to
    //stop seeking, meaning we were seeking
    if (originalLPCommand == newLPCommand) {
        [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:3];
    }
    
    [self.acapella pulseAnimateView];
}

%new
- (void)action_share:(id)arg1
{
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:8];
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
}

%new
- (void)action_openapp:(id)arg1
{
	return;
    id x = [self valueForKey:@"_nowPlayingController"]; //MPUNowPlayingController
    id y = [x valueForKey:@"_currentNowPlayingAppDisplayID"]; //NSString
    [%c(SWAppLauncher) launchAppWithBundleIDLockscreenFriendly:y];
}

%new
- (void)action_showratings:(id)arg1
{
}

%new
- (void)action_decreasevolume:(id)arg1
{
    id vc = [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(-1) afterDelay:0.0];

}

%new
- (void)action_increasevolume:(id)arg1
{
    id vc = [MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(1) afterDelay:0.0];
    
}

%new
- (void)action_equalizereverywhere:(id)arg1
{
    UIView *curView = self.acapella.referenceView.superview;
    
    while(curView) {
        
        if ([curView isKindOfClass:NSClassFromString(@"SBEqualizerScrollView")]) {
            UIScrollView *ee = (UIScrollView *)curView;
            [ee setContentOffset:CGPointMake(CGRectGetWidth(ee.frame), 0.0) animated:YES];
            curView = nil;
        } else {
            curView = curView.superview;
        }
        
    }
}

//#pragma mark - UIViewControllerPreviewing
//
//%new // peek
//- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
//{
//    @autoreleasepool {
//        
//    if (!self.acapella || self.presentedViewController) {
//        return nil;
//    }
//    
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
//        previewViewController.acapellaPreviewActionItems = @[[previewViewController heartAction],
//                                                             [previewViewController shareAction],
//                                                             [previewViewController openAppAction],
//                                                             [previewViewController equalizerEverywhereAction]];
//        
//    }
//    
//    
//    return previewViewController;
//        
//    }
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
//            
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^(void) {
//                [self performSelector:sel];
//            }];
//            
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
    // Keep a weak reference so our titles view can access our prefs
    objc_setAssociatedObject(MPU_SYSTEM_MEDIA_CONTROLS_VIEW.trackInformationView, @selector(_acapellaPrefs), acapellaPrefs, OBJC_ASSOCIATION_ASSIGN);
}

%end





#pragma mark - MPUSystemMediaControlsView

%hook MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();
    
    //intelligently calcualate centre based on visible controls
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        
        CGFloat topGuideline = 0;
        
        if (self.timeInformationView.layer.opacity > 0.0) { //visible
            topGuideline += CGRectGetMaxY(self.timeInformationView.frame);
        }
        
        
        CGFloat bottomGuideline = CGRectGetMaxY(self.bounds);
        
        if (![self.transportControlsView acapella_hidden]) {
            bottomGuideline = CGRectGetMinY(self.transportControlsView.frame);
        } else {
            if (self.volumeView.layer.opacity > 0.0) { //visible
                bottomGuideline = CGRectGetMinY(self.volumeView.frame);
            }
        }
        
        
        //the midpoint between the currently visible views. This is where we will place our titles
        NSInteger midPoint = (topGuideline + (fabs(topGuideline - bottomGuideline) / 2.0));
        self.trackInformationView.center = CGPointMake(self.trackInformationView.center.x, midPoint);
        
    }
}

%end




