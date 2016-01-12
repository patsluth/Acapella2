//
//  MusicNowPlayingViewController.xm
//  Acapella2
//
//  Created by Pat Sluth on 2015-12-27.
//
//

#import "SWAcapella.h"
#import "SWAcapellaMediaItemPreviewViewController.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/libSluthware/SWPrefs.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"

#define PREF_KEY_PREFIX @"musicnowplaying"
#define PREF_APPLICATION @"com.apple.Music"

#define MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController")





#pragma mark - MusicNowPlayingViewController

@interface MusicNowPlayingViewController : UIViewController <UIGestureRecognizerDelegate, UIViewControllerPreviewingDelegate>
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

//new
- (SWAcapella *)acapella;

- (UIView *)playbackProgressSliderView;
- (UIView *)titlesView;
- (MPUTransportControlsView *)transportControls;
- (MPUTransportControlsView *)secondaryTransportControls;
- (UIView *)volumeSlider;

- (UIView *)vibrantEffectView; //MPUVibrantContentEffectView.h

- (UIView *)ratingControl;
- (void)_setRatingsVisible:(BOOL)arg1;

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2;

@end





%hook MusicNowPlayingViewController

#pragma mark - Init

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
    //Reload our transport buttons
    //See [self transportControlsView:arg1 buttonForControlType:arg2];
    
    //TOP ROW
    [self.transportControls reloadTransportButtonWithControlType:6];
    [self.transportControls reloadTransportButtonWithControlType:1];
    [self.transportControls reloadTransportButtonWithControlType:2];
    [self.transportControls reloadTransportButtonWithControlType:3];
    [self.transportControls reloadTransportButtonWithControlType:4];
    [self.transportControls reloadTransportButtonWithControlType:5];
    [self.transportControls reloadTransportButtonWithControlType:7];
    
    //BOTTOM ROW
    [self.secondaryTransportControls reloadTransportButtonWithControlType:8];
    [self.secondaryTransportControls reloadTransportButtonWithControlType:10];
    [self.secondaryTransportControls reloadTransportButtonWithControlType:9];
    [self.secondaryTransportControls reloadTransportButtonWithControlType:11];
    
    [self viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    if (!self.acapella) {
        
        NSString *enabledKey = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"enabled"];
        
        if ([[SWPrefs valueForKey:enabledKey application:PREF_APPLICATION] boolValue]) {
            
            [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.titlesView.superview
                                                          preInitializeAction:^(SWAcapella *a) {
                                                              a.owner = self;
                                                              a.titles = self.titlesView;
                                                          }]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
        }
        
    }
    
    if (self.acapella) {
        
        self.acapella.prefKeyPrefix = PREF_KEY_PREFIX;
        self.acapella.prefApplication = PREF_APPLICATION;
        
        // Register/Unregister for UIViewControllerPreviewing
        if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
            (self.traitCollection.forceTouchCapability ==  UIForceTouchCapabilityAvailable)) {
            
            [self registerForPreviewingWithDelegate:self sourceView:self.view];
            
        }
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    
    %orig(animated);
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    NSString *progressKey = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"progressslider"];
    NSString *volumeKey = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"volumeslider"];
    
    BOOL progressVisible = [[SWPrefs valueForKey:progressKey application:PREF_APPLICATION] boolValue];
    BOOL volumeVisible = [[SWPrefs valueForKey:volumeKey application:PREF_APPLICATION] boolValue];
    
    //show/hide sliders
    self.playbackProgressSliderView.layer.opacity = progressVisible ? 1.0 : 0.0;
    self.volumeSlider.layer.opacity = volumeVisible ? 1.0 : 0.0;
    
    //Pinnning views responsible for drawing knobs
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
    
    
    
    //intelligently calcualate centre based on visible controls, which we dont want to do on iPAD
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) { return; }
    
    
    CGFloat topGuideline = CGRectGetMinY(self.playbackProgressSliderView.frame);
    
    if (self.playbackProgressSliderView.layer.opacity > 0.0) { //visible
        topGuideline += CGRectGetHeight(self.playbackProgressSliderView.bounds);
    }
    
    
    CGFloat bottomGuideline = CGRectGetMinY(self.transportControls.frame); //top of primary transport controls
    
    
    if ([self.transportControls hidden_acapella]) {
        
        bottomGuideline = CGRectGetMinY(self.volumeSlider.frame); //top of volume slider
        
        if (self.volumeSlider.layer.opacity <= 0.0) { //hidden
            
            bottomGuideline = CGRectGetMinY(self.secondaryTransportControls.frame); //top of transport secondary controls
            
            if ([self.secondaryTransportControls hidden_acapella]) {
                bottomGuideline = CGRectGetMaxY(self.titlesView.superview.bounds); //bottom of screen
            }
            
        }
        
    }
    
    //the midpoint between the currently visible views. This is where we will place our titles
    NSInteger midPoint = (topGuideline + (fabs(topGuideline - bottomGuideline) / 2.0));
    self.titlesView.center = CGPointMake(self.titlesView.center.x, midPoint);
    
}

#pragma mark - Acapella(Helper)

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    //TRANSPORT CONTROL TYPES
    //THESE CODES ARE DIFFERENT FROM THE MEDIA COMMANDS
    
    //TOP ROW
    //6 like/ban
    //1 rewind
    //2 interval rewind
    //3 play/pause
    //4 forward
    //5 interval forward
    //7 present up next
    
    //BOTTOM ROW
    //8 share
    //10 shuffle
    //9 repeat
    //11 contextual
    
    
    //TOP ROW
    NSString *key_Heart = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_heart"];
    if (arg2 == 6 && ![[SWPrefs valueForKey:key_Heart application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_PrevTrack = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_previoustrack"];
    if (arg2 == 1 && ![[SWPrefs valueForKey:key_PrevTrack application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_IntervalRewind = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_intervalrewind"];
    if (arg2 == 2 && ![[SWPrefs valueForKey:key_IntervalRewind application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_PlayPause = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_playpause"];
    if (arg2 == 3 && ![[SWPrefs valueForKey:key_PlayPause application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_NextTrack = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_nexttrack"];
    if (arg2 == 4 && ![[SWPrefs valueForKey:key_NextTrack application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_IntervalForward = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_intervalforward"];
    if (arg2 == 5 && ![[SWPrefs valueForKey:key_IntervalForward application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_UpNext = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_upnext"];
    if (arg2 == 7 && ![[SWPrefs valueForKey:key_UpNext application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    //BOTTOM ROW
    NSString *key_Share = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_share"];
    if (arg2 == 8 && ![[SWPrefs valueForKey:key_Share application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_Shuffle = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_shuffle"];
    if (arg2 == 10 && ![[SWPrefs valueForKey:key_Shuffle application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_Repeat = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_repeat"];
    if (arg2 == 9 && ![[SWPrefs valueForKey:key_Repeat application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    NSString *key_Contextual = [NSString stringWithFormat:@"%@_%@", PREF_KEY_PREFIX, @"transport_contextual"];
    if (arg2 == 11 && ![[SWPrefs valueForKey:key_Contextual application:PREF_APPLICATION] boolValue]) {
        return nil;
    }
    
    
    return %orig(arg1, arg2);
}

//- (void)_handleTapGestureRecognizerAction:(id)arg1 //tap on artwork
//{
//    //if (!self.acapella) {
//        %orig(arg1);
//    //}
//}

- (void)_showUpNext
{
    if (self.acapella) {
        self.acapella.titlesCloneContainer = nil;
    }
    
    %orig();
}

- (void)_showUpNext:(id)arg1
{
    if (self.acapella) {
        self.acapella.titlesCloneContainer = nil;
    }
    
    %orig(arg1);
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
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:self.transportControls longPressEndOnControlType:1];
    [self transportControlsView:self.transportControls longPressEndOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    //if the 2 commands are different, then something happened when we told the transportControlView to
    //stop seeking, meaning we were seeking
    if (originalLPCommand == newLPCommand) {
        [self transportControlsView:self.transportControls tapOnControlType:3];
    }
    
    [self.acapella pulseAnimateView];
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
    self.acapella.titlesCloneContainer = nil;
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

%new // peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    if (self.presentedViewController) {
        return nil;
    }
    
    // Show the entire media control area as the source rect, not just the titles view
    CGRect sourceRect = self.playbackProgressSliderView.frame;
    sourceRect.size.height = CGRectGetHeight(self.view.bounds) - sourceRect.origin.y;
    previewingContext.sourceRect = sourceRect;
    
    if (CGRectContainsPoint(sourceRect, location)) { // Don't allow previewing if outside the media control area
        
        SWAcapellaMediaItemPreviewViewController *previewViewController = [[SWAcapellaMediaItemPreviewViewController alloc] init];
        [previewViewController configureWithCurrentNowPlayingInfo];
        
        return previewViewController;
        
    }
    
    
    return nil;
}

%new // pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
}

%end



