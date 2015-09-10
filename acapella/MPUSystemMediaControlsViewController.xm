
#import "SWAcapella.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWAppLauncher.h"
#import "libsw/SWPrefs.h"

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


@interface MPUSystemMediaControlsViewController : UIViewController
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;
- (NSString *)acapellaPrefKeyPrefix;

- (MPUSystemMediaControlsView *)mediaControlsView;

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2;

@end





%hook MPUSystemMediaControlsViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

%new
- (NSString *)acapellaPrefKeyPrefix
{
    return [SWAcapella prefKeyByDrillingUpFromView:self.view];
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
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];;
    
    //NSLog(@"Acapella Preference Key Prefix %@", prefKeyPrefix);
    
    if (!self.acapella){
        
        if (prefKeyPrefix != nil){
            
            NSString *enabledKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"enabled"];
            
            if ([[SWPrefs valueForKey:enabledKey fallbackValue:@YES application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
                
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
        
        [self.acapella.tap addTarget:self action:@selector(onTap:)];
        [self.acapella.press addTarget:self action:@selector(onPress:)];
        
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
        
        NSString *progressKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"progressSlider_enabled"];
        NSString *volumeKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"volumeSlider_enabled"];
        
        
        if (![[SWPrefs valueForKey:progressKey fallbackValue:@YES application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            self.mediaControlsView.timeInformationView.layer.opacity = 0.0;
        } else {
            self.mediaControlsView.timeInformationView.layer.opacity = 1.0;
        }
        if (![[SWPrefs valueForKey:volumeKey fallbackValue:@YES application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
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

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.acapella){
        
        if (self.acapella.pan == gestureRecognizer || self.acapella.tap == gestureRecognizer){
            
            BOOL isControl = [touch.view isKindOfClass:[UIControl class]];
            
            if (isControl){
                return !((UIControl *)touch.view).enabled; //we can accept this touch if the control is enabled
            }
            
            return !isControl; //not a control, recieve the touch
            
        }
        
    }
    
    return YES;
}

%new
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.acapella){
        
        if (self.acapella.pan == gestureRecognizer){
            
            CGPoint panVelocity = [self.acapella.pan velocityInView:self.acapella.pan.view];
            return (fabs(panVelocity.x) > fabs(panVelocity.y)); //only accept horizontal pans
            
        }
        
    }
    
    return YES;
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
    
    NSString *prefKeyPrefix = [SWAcapella prefKeyByDrillingUpFromView:self.view];
    
    if (prefKeyPrefix != nil){
    
        NSString *key_Heart = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_heart_enabled"];
        if (arg2 == 6 && ![[SWPrefs valueForKey:key_Heart fallbackValue:@YES application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            return nil;
        }
        
        NSString *key_PrevTrack = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_previoustrack_enabled"];
        if (arg2 == 1 && ![[SWPrefs valueForKey:key_PrevTrack fallbackValue:@NO application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            return nil;
        }
        
        NSString *key_IntervalRewind = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_intervalrewind_enabled"];
        if (arg2 == 2 && ![[SWPrefs valueForKey:key_IntervalRewind fallbackValue:@NO application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            return nil;
        }
        
        NSString *key_PlayPause = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_play/pause_enabled"];
        if (arg2 == 3 && ![[SWPrefs valueForKey:key_PlayPause fallbackValue:@NO application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            return nil;
        }
        
        NSString *key_NextTrack = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_nextTrack_enabled"];
        if (arg2 == 4 && ![[SWPrefs valueForKey:key_NextTrack fallbackValue:@NO application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            return nil;
        }
        
        NSString *key_IntervalForward = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_intervalforward_enabled"];
        if (arg2 == 5 && ![[SWPrefs valueForKey:key_IntervalForward fallbackValue:@NO application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            return nil;
        }
        
        NSString *key_Share = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_share_enabled"];
        if (arg2 == 8 && ![[SWPrefs valueForKey:key_Share fallbackValue:@YES application:@"com.patsluth.AcapellaPrefs2"] boolValue]){
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

%new
- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (self.acapella){
        
        CGFloat xPercentage = [tap locationInView:tap.view].x / CGRectGetWidth(tap.view.bounds);
        //CGFloat yPercentage = [tap locationInView:tap.view].y / CGRectGetHeight(tap.view.bounds);
        SEL sel = nil;
        
        if (xPercentage <= 0.25){
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapleft"];
            NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_decreasevolume" application:@"com.patsluth.AcapellaPrefs2"];
            sel = NSSelectorFromString(selString);
            
        } else if (xPercentage > 0.75){
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapright"];
            NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_increasevolume" application:@"com.patsluth.AcapellaPrefs2"];
            sel = NSSelectorFromString(selString);
            
        } else {
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapcentre"];
            NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_playpause" application:@"com.patsluth.AcapellaPrefs2"];
            sel = NSSelectorFromString(selString);
            
        }
        

        if (sel && [self respondsToSelector:sel]){
            [self performSelectorOnMainThread:sel withObject:nil waitUntilDone:NO];
        }
        
    }
}

%new
- (void)onPress:(UILongPressGestureRecognizer *)press
{
    if (self.acapella){
        
        CGFloat xPercentage = [press locationInView:press.view].x / CGRectGetWidth(press.view.bounds);
        //CGFloat yPercentage = [press locationInView:press.view].y / CGRectGetHeight(press.view.bounds);
        SEL sel = nil;
        
        if (press.state == UIGestureRecognizerStateBegan){
            
            if (xPercentage <= 0.25){
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_pressleft"];
                NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_intervalrewind" application:@"com.patsluth.AcapellaPrefs2"];
                sel = NSSelectorFromString(selString);
                
            } else if (xPercentage > 0.75){
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_pressright"];
                NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_intervalforward" application:@"com.patsluth.AcapellaPrefs2"];
                sel = NSSelectorFromString(selString);
                
            } else {
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_presscentre"];
                NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_openapp" application:@"com.patsluth.AcapellaPrefs2"];
                sel = NSSelectorFromString(selString);
                
            }
            
        }
        
//        else if (press.state == UIGestureRecognizerStateEnded){
//            
//            //SEEK BEGIN
//            //[self transportControlsView:self.mediaControlsView.transportControlsView longPressBeginOnControlType:1];
//            //[self transportControlsView:self.mediaControlsView.transportControlsView longPressBeginOnControlType:4];
//            //SEEK END
//            //[self transportControlsView:self.mediaControlsView.transportControlsView longPressEndOnControlType:1];
//            //[self transportControlsView:self.mediaControlsView.transportControlsView longPressEndOnControlType:4];
//            
//        }
        
        if (sel && [self respondsToSelector:sel]){
            [self performSelectorOnMainThread:sel withObject:nil waitUntilDone:NO];
        }
        
    }
}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    SEL sel = nil;
    
    if ([direction integerValue] < 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_swipeleft"];
        NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_nexttrack" application:@"com.patsluth.AcapellaPrefs2"];
        sel = NSSelectorFromString(selString);
        
    } else if ([direction integerValue] > 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_swiperight"];
        NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_previoustrack" application:@"com.patsluth.AcapellaPrefs2"];
        sel = NSSelectorFromString(selString);
        
    }
    
    
    if (sel && [self respondsToSelector:sel]){
        [self performSelectorOnMainThread:sel withObject:nil waitUntilDone:NO];
    }
    
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
        }
        
        curView = curView.superview;
        
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





#pragma mark - logos

%ctor
{
    
    //TODO: REMOVE in the next 2 versions
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.patsluth.AcapellaPrefs2.plist"];
                           
    if (prefs){
        for (id key in prefs){
            
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefs valueForKey:key],
                                     (__bridge CFStringRef)@"com.apple.Music");
        }
        CFPreferencesAppSynchronize((__bridge CFStringRef)@"com.apple.Music");
    }
}




