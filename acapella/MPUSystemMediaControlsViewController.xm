
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"
#import "libsw/SWAppLauncher.h"

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
//    id a = NSStringFromClass([self.view.superview class]);
//    id b = NSStringFromClass([self.view.superview.superview class]);
//    id c = NSStringFromClass([self.view.window.rootViewController class]);
//    NSLog(@"Acapella System Media Controls Log %@-%@-%@", a, b, c);
    
    
    //Control Center
    NSString *cc1 = @"SBControlCenterSectionView";
    NSString *cc2 = @"SBControlCenterContentView";
    if ([NSStringFromClass([self.view.superview class]) isEqualToString:cc1] &&
        [NSStringFromClass([self.view.superview.superview class]) isEqualToString:cc2]){
        return @"cc_";
    }
    
    
    //Lock Screen
    NSString *ls1 = @"SBMainScreenAlertWindowViewController";
    NSString *ls2 = @"SBInteractionPassThroughView";
    if ([NSStringFromClass([self.view.window.rootViewController class]) isEqualToString:ls1] &&
        [NSStringFromClass([self.view.superview.superview class]) isEqualToString:ls2]){
        return @"ls_";
    }
    
    
    //OnTapMusic
    if (%c(OTMView)){ //if null tweak is not installed
        
        NSString *otm1 = @"OTMView";
        if ([NSStringFromClass([self.view.superview class]) isEqualToString:otm1]){
            return @"otm_";
        }
        
    }
    
    
    //Auxo
    if (%c(AuxoCollectionView)){
        
        //Auxo
        NSString *auxo1 = @"AuxoCollectionView";
        UIView *curView = self.view.superview;
        
        while (curView){ //drill up
            if ([NSStringFromClass([curView class]) isEqualToString:auxo1]){
                return @"auxo_";
            }
            curView = curView.superview;
        }
        
    }
    
    return nil;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
    
    if (!self.acapella){
        
        if (prefKeyPrefix != nil){
            
            NSString *enabledKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"enabled"];
            
            if ([[SWAcapellaPrefsBridge valueForKey:enabledKey defaultValue:@YES] boolValue]){
                
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
        
        if (![[SWAcapellaPrefsBridge valueForKey:progressKey defaultValue:@YES] boolValue]){
            self.mediaControlsView.timeInformationView.layer.opacity = 0.0;
        } else {
            self.mediaControlsView.timeInformationView.layer.opacity = 1.0;
        }
        if (![[SWAcapellaPrefsBridge valueForKey:volumeKey defaultValue:@YES] boolValue]){
            self.mediaControlsView.volumeView.layer.opacity = 0.0;
        } else {
            self.mediaControlsView.volumeView.layer.opacity = 1.0;
        }
        
    } else {
        
        self.mediaControlsView.timeInformationView.layer.opacity = 1.0;
        self.mediaControlsView.volumeView.layer.opacity = 1.0;
        
    }
    
    
    [self.mediaControlsView layoutSubviews];
    
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
            
            BOOL isSlider = [touch.view isKindOfClass:[UISlider class]];
            BOOL isControl = [touch.view isKindOfClass:[UIControl class]];
            
            return !isSlider && !isControl;
            
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
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
    
    if (prefKeyPrefix != nil){
    
        NSString *key_Heart = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_heart_enabled"];
        if (arg2 == 6 && ![[SWAcapellaPrefsBridge valueForKey:key_Heart defaultValue:@YES] boolValue]){
            return nil;
        }
        
        NSString *key_PrevTrack = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_previoustrack_enabled"];
        if (arg2 == 1 && ![[SWAcapellaPrefsBridge valueForKey:key_PrevTrack defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_IntervalRewind = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_intervalrewind_enabled"];
        if (arg2 == 2 && ![[SWAcapellaPrefsBridge valueForKey:key_IntervalRewind defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_PlayPause = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_play/pause_enabled"];
        if (arg2 == 3 && ![[SWAcapellaPrefsBridge valueForKey:key_PlayPause defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_NextTrack = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_nextTrack_enabled"];
        if (arg2 == 4 && ![[SWAcapellaPrefsBridge valueForKey:key_NextTrack defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_IntervalForward = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_intervalforward_enabled"];
        if (arg2 == 5 && ![[SWAcapellaPrefsBridge valueForKey:key_IntervalForward defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_Share = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_share_enabled"];
        if (arg2 == 8 && ![[SWAcapellaPrefsBridge valueForKey:key_Share defaultValue:@YES] boolValue]){
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
        
        if (xPercentage <= 0.25){
            
            id vc = [self.mediaControlsView.volumeView valueForKey:@"volumeController"];
            [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(-1) afterDelay:0.0];
            
        } else if (xPercentage > 0.75){
            
            id vc = [self.mediaControlsView.volumeView valueForKey:@"volumeController"];
            [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(1) afterDelay:0.0];
            
        } else {
            
            MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
            [t handlePushingMediaRemoteCommand:(t.playing) ? 1 : 0];
            
            [self.acapella pulseAnimateView:self.acapella.referenceView];
            
        }
        
    }
}

%new
- (void)onPress:(UILongPressGestureRecognizer *)press
{
    if (self.acapella){
        
        CGFloat xPercentage = [press locationInView:press.view].x / CGRectGetWidth(press.view.bounds);
        //CGFloat yPercentage = [press locationInView:press.view].y / CGRectGetHeight(press.view.bounds);
        
        if (press.state == UIGestureRecognizerStateBegan){
            
            if (xPercentage <= 0.25){
                
                //SEEK
                //[self transportControlsView:self.mediaControlsView.transportControlsView longPressBeginOnControlType:1];
                //INTERVAL
                [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:2];
                
            } else if (xPercentage > 0.75){
                
                //SEEK
                //[self transportControlsView:self.mediaControlsView.transportControlsView longPressBeginOnControlType:4];
                //INTERVAL
                [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:5];
                
            } else {
                
                id x = [self valueForKey:@"_nowPlayingController"]; //MPUNowPlayingController
                id y = [x valueForKey:@"_currentNowPlayingAppDisplayID"]; //NSString
                [%c(SWAppLauncher) launchAppWithBundleIDLockscreenFriendly:y];
                
            }
            
        } else if (press.state == UIGestureRecognizerStateEnded){
            
            //SEEK
            //[self transportControlsView:self.mediaControlsView.transportControlsView longPressEndOnControlType:1];
            //[self transportControlsView:self.mediaControlsView.transportControlsView longPressEndOnControlType:4];
            
        }
        
    }
}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    if ([direction integerValue] < 0){
        [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:4];
    } else if ([direction integerValue] > 0){
        [self transportControlsView:self.mediaControlsView.transportControlsView tapOnControlType:1];
    }
    
    MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
    
    if (![t.nowPlayingInfo valueForKey:@"kMRMediaRemoteNowPlayingInfoTitle"]){ //wrap around instantly if nothing is playing
        if ([self.acapella respondsToSelector:@selector(finishWrapAround)]){
            [self.acapella performSelector:@selector(finishWrapAround) withObject:nil afterDelay:0.0];
        }
    }
}

%end





%hook MPUSystemMediaControlsView

- (void)layoutSubviews
{
    %orig();
    
    SWAcapella *acapella = [SWAcapella acapellaForObject:self.trackInformationView];
    
    if (acapella && (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)){ //center
        
        CGFloat topGuideline = 0;
        
        if (self.timeInformationView.layer.opacity > 0.0){ //visible
            topGuideline += CGRectGetMaxY(self.timeInformationView.frame);
        }
        
        CGFloat bottomGuideline = CGRectGetMaxY(self.bounds);
        
        if (self.transportControlsView.subviews.count > 0){ //visible
            bottomGuideline = CGRectGetMinY(self.transportControlsView.frame);
        } else {
            if (self.volumeView.layer.opacity > 0.0){ //visible
                bottomGuideline = CGRectGetMinY(self.volumeView.frame);
            }
        }
        
        //the midpoint between the currently visible views. This is where we will place our titles
        NSInteger midPoint = (topGuideline + (fabs(topGuideline - bottomGuideline) / 2.0));
        
        self.trackInformationView.center = CGPointMake(CGRectGetMidX(self.bounds), midPoint);
        
    }
}

%end





#pragma mark - logos

%ctor
{
}




