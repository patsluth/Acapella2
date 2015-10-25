
#import "MPUSystemMediaControlsViewController.h"

#import "SWAcapella.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWAppLauncher.h"
#import "libsw/libSluthware/SWPrefs.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"

#import "substrate.h"





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
    //    HBLogInfo(@"Acapella System Media Controls Log %@-%@-%@", a, b, c);
    
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

%new
- (MPUSystemMediaControlsView *)mediaControlsView
{
    return MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView");
}

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
    //Reload our transport buttons
    //See [self transportControlsView:arg1 buttonForControlType:arg2];
    [self.mediaControlsView.transportControlsView reloadTransportButtonWithControlType:6];
    [self.mediaControlsView.transportControlsView reloadTransportButtonWithControlType:1];
    [self.mediaControlsView.transportControlsView reloadTransportButtonWithControlType:2];
    [self.mediaControlsView.transportControlsView reloadTransportButtonWithControlType:3];
    [self.mediaControlsView.transportControlsView reloadTransportButtonWithControlType:4];
    [self.mediaControlsView.transportControlsView reloadTransportButtonWithControlType:5];
    [self.mediaControlsView.transportControlsView reloadTransportButtonWithControlType:8];
    
    [self.mediaControlsView layoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    NSString *prefKeyPrefix = PREF_KEY_PREFIX;
    
    //HBLogInfo(@"Acapella Preference Key Prefix %@", prefKeyPrefix);
    
    if (!self.acapella){
        
        if (prefKeyPrefix != nil){
            
            NSString *enabledKey = [NSString stringWithFormat:@"%@_%@", prefKeyPrefix, @"enabled"];
            
            if ([[SWPrefs valueForKey:enabledKey application:PREF_APPLICATION] boolValue]){
                
                [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                              preInitializeAction:^(SWAcapella *a){
                                                                  a.owner = self;
                                                                  a.titles = self.mediaControlsView.trackInformationView;
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
            self.mediaControlsView.timeInformationView.layer.opacity = 0.0;
        } else {
            self.mediaControlsView.timeInformationView.layer.opacity = 1.0;
        }
        if (![[SWPrefs valueForKey:volumeKey application:PREF_APPLICATION] boolValue]){
            self.mediaControlsView.volumeView.layer.opacity = 0.0;
        } else {
            self.mediaControlsView.volumeView.layer.opacity = 1.0;
        }
        
    } else {
        
        self.mediaControlsView.timeInformationView.layer.opacity = 1.0;
        self.mediaControlsView.volumeView.layer.opacity = 1.0;
        
    }
    
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
- (void)action_none
{
}

%new
- (void)action_heart
{
    [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:6];
}

%new
- (void)action_previoustrack
{
    [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:1];
    
    MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
    
    if (![t.nowPlayingInfo valueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]){ //wrap around instantly if nothing is playing
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]){
            [self.acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
    }
}

%new
- (void)action_intervalrewind
{
    [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:2];
}

%new
- (void)action_playpause
{
    [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:3];
    [self.acapella pulseAnimateView:self.acapella.referenceView];
}

%new
- (void)action_nexttrack
{
    [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:4];
    
    MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
    
    if (![t.nowPlayingInfo valueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]){ //wrap around instantly if nothing is playing
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]){
            [self.acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
    }
}

%new
- (void)action_intervalforward
{
    [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:5];
}

%new
- (void)action_upnext
{
}

%new
- (void)action_share
{
    [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:8];
}

%new
- (void)action_toggleshuffle
{
}

%new
- (void)action_togglerepeat
{
}

%new
- (void)action_contextual
{
}

%new
- (void)action_openapp
{
    id x = [self valueForKey:@"_nowPlayingController"]; //MPUNowPlayingController
    id y = [x valueForKey:@"_currentNowPlayingAppDisplayID"]; //NSString
    [%c(SWAppLauncher) launchAppWithBundleIDLockscreenFriendly:y];
}

%new
- (void)action_showratings
{
}

%new
- (void)action_increasevolume
{
    id vc = [self.mediaControlsView.volumeView valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(1) afterDelay:0.0];
}

%new
- (void)action_decreasevolume
{
    id vc = [self.mediaControlsView.volumeView valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(-1) afterDelay:0.0];
}

%new
- (void)action_equalizereverywhere
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




