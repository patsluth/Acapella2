
#import "MPUSystemMediaControlsViewController.h"

#import "SWAcapella.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWAppLauncher.h"
#import "libsw/libSluthware/SWPrefs.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"

#define MPU_SYSTEM_MEDIA_CONTROLS_VIEW MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView")
#define MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController")





@interface MPUSystemMediaControlsView : UIView
{
}

- (UIView *)timeInformationView;
- (UIView *)trackInformationView;
- (MPUTransportControlsView *)transportControlsView;
- (UIView *)volumeView;

@end





%hook MPUSystemMediaControlsViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

%new
+ (NSString *)prefKeyPrefixByDrillingUp:(UIView *)view
{
    //    id a = NSStringFromClass([self.view.superview class]);
    //    id b = NSStringFromClass([self.view.superview.superview class]);
    //    id c = NSStringFromClass([self.view.window.rootViewController class]);
    //    NSLogInfo(@"Acapella System Media Controls Log %@-%@-%@", a, b, c);
    
    UIView *curView = view.superview;
    
    while (curView){
        
        //Control Centre
        if ([NSStringFromClass([curView class]) isEqualToString:@"SBControlCenterRootView"]){
            return @"cc";
        }
        
        //Lock Screen
        if ([NSStringFromClass([curView class]) isEqualToString:@"SBLockScreenView"]){
            return @"ls";
        }
        
        //OnTapMusic - class will be null if tweak is not installed
        if (objc_getClass("OTMView") && [NSStringFromClass([curView class]) isEqualToString:@"OTMView"]){
            return @"otm";
        }
        
        //Auxo LE - class will be null if tweak is not installed
        if (objc_getClass("AuxoCollectionView") && [NSStringFromClass([curView class]) isEqualToString:@"AuxoCollectionView"]){
            return @"auxo";
        }
        
        //Vertex - Vertex has no classes ?
        if ([NSStringFromClass([curView class]) isEqualToString:@"SBAppSwitcherContainer"]){
            return @"vertex";
        }
        
        curView = curView.superview;
        
    }
    
    return @"undefined";
}

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
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
    
    NSString *prefKeyPrefix = PREF_KEY_PREFIX;
    
    if (!self.acapella){
        
        if (prefKeyPrefix != nil){
            
            NSString *enabledKey = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"enabled"];
            
            if ([[SWPrefs valueForKey:enabledKey application:PREF_APPLICATION] boolValue]){
                
                [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                              preInitializeAction:^(SWAcapella *a){
                                                                  a.owner = self;
                                                                  a.titles = MPU_SYSTEM_MEDIA_CONTROLS_VIEW.trackInformationView;
                                                              }]
                              ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
                
            }
            
        }
        
    }
    
    
    if (self.acapella){
        
        self.acapella.prefKeyPrefix = prefKeyPrefix;
        self.acapella.prefApplication = PREF_APPLICATION;
        
        for (UIView *v in self.acapella.titles.subviews){ //button that handles titles tap
            if ([v isKindOfClass:[UIButton class]]){
                UIButton *b = (UIButton *)v;
                b.enabled = NO;
            }
        }
        
    } else { //restore original state
        
        for (UIView *v in self.acapella.titles.subviews){ //button that handles titles tap
            if ([v isKindOfClass:[UIButton class]]){
                UIButton *b = (UIButton *)v;
                b.enabled = YES;
            }
        }
        
    }
    
    
    if (prefKeyPrefix != nil){
        
        NSString *progressKey = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"progressslider"];
        NSString *volumeKey = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"volumeslider"];
        
        if (![[SWPrefs valueForKey:progressKey application:PREF_APPLICATION] boolValue]){
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.timeInformationView.layer.opacity = 0.0;
        } else {
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.timeInformationView.layer.opacity = 1.0;
        }
        if (![[SWPrefs valueForKey:volumeKey application:PREF_APPLICATION] boolValue]){
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView.layer.opacity = 0.0;
        } else {
            MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView.layer.opacity = 1.0;
        }
        
    } else {
        
        MPU_SYSTEM_MEDIA_CONTROLS_VIEW.timeInformationView.layer.opacity = 1.0;
        MPU_SYSTEM_MEDIA_CONTROLS_VIEW.volumeView.layer.opacity = 1.0;
        
    }
    
    [MPU_SYSTEM_MEDIA_CONTROLS_VIEW layoutSubviews];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    
    %orig(animated);
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
    
    NSString *prefKeyPrefix = PREF_KEY_PREFIX;
    
    if (prefKeyPrefix != nil){
    
        NSString *key_Heart = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_heart"];
        if (arg2 == 6 && ![[SWPrefs valueForKey:key_Heart application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_PrevTrack = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_previoustrack"];
        if (arg2 == 1 && ![[SWPrefs valueForKey:key_PrevTrack application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_IntervalRewind = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_intervalrewind"];
        if (arg2 == 2 && ![[SWPrefs valueForKey:key_IntervalRewind application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_PlayPause = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_playpause"];
        if (arg2 == 3 && ![[SWPrefs valueForKey:key_PlayPause application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_NextTrack = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_nexttrack"];
        if (arg2 == 4 && ![[SWPrefs valueForKey:key_NextTrack application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_IntervalForward = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_intervalforward"];
        if (arg2 == 5 && ![[SWPrefs valueForKey:key_IntervalForward application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
        NSString *key_Share = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"transport_share"];
        if (arg2 == 8 && ![[SWPrefs valueForKey:key_Share application:PREF_APPLICATION] boolValue]){
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

#pragma mark - Actions

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
    
    if (![t.nowPlayingInfo valueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]){ //wrap around instantly if nothing is playing
        
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]){
            [self.acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
        
    }
}

%new
- (void)action_nexttrack:(id)arg1
{
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView tapOnControlType:4];
    
    MPUTransportControlMediaRemoteController *t = MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER;
    
    if (![t.nowPlayingInfo valueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]){ //wrap around instantly if nothing is playing
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]){
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
    
    if (originalLPCommand == newLPCommand){ //if the commands havent changed we are seeking, so we should stop seeking
        [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressEndOnControlType:1];
    }
}

%new
- (void)action_seekforward:(id)arg1
{
    unsigned int originalLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    [self transportControlsView:MPU_SYSTEM_MEDIA_CONTROLS_VIEW.transportControlsView longPressBeginOnControlType:4];
    
    unsigned int newLPCommand = MSHookIvar<unsigned int>(MPU_TRANSPORT_MEDIA_REMOTE_CONTROLLER, "_runningLongPressCommand");
    
    if (originalLPCommand == newLPCommand){ //if the commands havent changed we are seeking, so we should stop seeking
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
    if (originalLPCommand == newLPCommand){
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
    
    while(curView){
        
        if ([curView isKindOfClass:NSClassFromString(@"SBEqualizerScrollView")]){
            UIScrollView *ee = (UIScrollView *)curView;
            [ee setContentOffset:CGPointMake(CGRectGetWidth(ee.frame), 0.0) animated:YES];
            curView = nil;
        } else {
            curView = curView.superview;
        }
        
    }
}

%end





%hook MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();
    
    //intelligently calcualate centre based on visible controls
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad){
        
        CGFloat topGuideline = 0;
        
        if (self.timeInformationView.layer.opacity > 0.0){ //visible
            topGuideline += CGRectGetMaxY(self.timeInformationView.frame);
        }
        
        
        CGFloat bottomGuideline = CGRectGetMaxY(self.bounds);
        
        if (![self.transportControlsView hidden_acapella]){
            bottomGuideline = CGRectGetMinY(self.transportControlsView.frame);
        } else {
            if (self.volumeView.layer.opacity > 0.0){ //visible
                bottomGuideline = CGRectGetMinY(self.volumeView.frame);
            }
        }
        
        
        //the midpoint between the currently visible views. This is where we will place our titles
        NSInteger midPoint = (topGuideline + (fabs(topGuideline - bottomGuideline) / 2.0));
        self.trackInformationView.center = CGPointMake(self.trackInformationView.center.x, midPoint);
        
    }
}

%end




