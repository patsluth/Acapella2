
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"
#import "libsw/SWAppLauncher.h"

#import "MPUTransportControlMediaRemoteController.h"

#import "substrate.h"




@interface MPUSystemMediaControlsView : UIView
{
}

- (UIView *)timeInformationView;
- (UIView *)trackInformationView;
- (UIView *)transportControlsView;
- (UIView *)volumeView;

@end


@interface MPUSystemMediaControlsViewController : UIViewController
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;
- (MPUSystemMediaControlsView *)mediaControlsView;

- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2;

@end





%hook MPUSystemMediaControlsViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

%new
- (MPUSystemMediaControlsView *)mediaControlsView
{
    return MSHookIvar<MPUSystemMediaControlsView *>(self, "_mediaControlsView");
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    if (!self.acapella){
        
        BOOL createAcapella = NO;
        
        if (!self.view.window.rootViewController){
            
            if ([self.view.superview isKindOfClass:%c(OTMView)]){ //OnTapMusic
                createAcapella = [[SWAcapellaPrefsBridge valueForKey:@"otm_enabled" defaultValue:@YES] boolValue];
            }
            
        } else {
            
            if ([self.view.window.rootViewController class] == %c(SBControlCenterController)){
                createAcapella = [[SWAcapellaPrefsBridge valueForKey:@"cc_enabled" defaultValue:@YES] boolValue];
            } else { //SBMainScreenAlertWindowViewController -> Lock Screen
                createAcapella = [[SWAcapellaPrefsBridge valueForKey:@"ls_enabled" defaultValue:@YES] boolValue];
            }
            
        }
        
        
        if (createAcapella){
            
            [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view
                                                          preInitializeAction:^(SWAcapella *a){
                                                              a.owner = self;
                                                              a.titles = self.mediaControlsView.trackInformationView;
                                                          }]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
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
        
        if (![[SWAcapellaPrefsBridge valueForKey:@"progressSlider_enabled" defaultValue:@YES] boolValue]){
            self.mediaControlsView.timeInformationView.layer.opacity = 0.0;
        } else {
            self.mediaControlsView.timeInformationView.layer.opacity = 1.0;
        }
        if (![[SWAcapellaPrefsBridge valueForKey:@"volumeSlider_enabled" defaultValue:@YES] boolValue]){
            self.mediaControlsView.volumeView.layer.opacity = 0.0;
        } else {
            self.mediaControlsView.volumeView.layer.opacity = 1.0;
        }
        
    } else { //restore original state
        
        for (UIView *v in self.acapella.titles.subviews){ //button that handles titles tap
            if ([v isKindOfClass:[UIButton class]]){
                UIButton *b = (UIButton *)v;
                b.enabled = YES;
            }
        }
        
        self.mediaControlsView.timeInformationView.layer.opacity = 1.0;
        self.mediaControlsView.volumeView.layer.opacity = 1.0;
        
    }
    
    [self.mediaControlsView layoutSubviews];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
//    [self.mediaControlsView.transportControlsView performSelector:@selector(_reloadSortedVisibleControlsWithBlanks)
//                                                       withObject:nil
//                                                       afterDelay:0.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    
//    [self.mediaControlsView.transportControlsView performSelector:@selector(setAvailableTransportControls:)
//                                                       withObject:nil
//                                                       afterDelay:0.0];
    
    %orig(animated);
}

%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.acapella){
        
        if (self.acapella.pan == gestureRecognizer || self.acapella.tap == gestureRecognizer){
            return ![touch.view isKindOfClass:[UISlider class]];
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
    //3 play/pause
    //4 forward
    //8 share
    
    if (arg2 == 6 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_heart_enabled" defaultValue:@YES] boolValue]){
        return nil;
    }
    
    if (arg2 == 1 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_skipprevious_enabled" defaultValue:@NO] boolValue]){
        return nil;
    }
    
    if (arg2 == 3 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_play/pause_enabled" defaultValue:@NO] boolValue]){
        return nil;
    }
    
    if (arg2 == 4 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_skipnext_enabled" defaultValue:@NO] boolValue]){
        return nil;
    }
    
    if (arg2 == 8 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_share_enabled" defaultValue:@YES] boolValue]){
        return nil;
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
                
                [self transportControlsView:self.mediaControlsView.transportControlsView longPressBeginOnControlType:1];

                
            } else if (xPercentage > 0.75){
                
                [self transportControlsView:self.mediaControlsView.transportControlsView longPressBeginOnControlType:4];
                
            } else {
                
                id x = [self valueForKey:@"_nowPlayingController"]; //MPUNowPlayingController
                id y = [x valueForKey:@"_currentNowPlayingAppDisplayID"]; //NSString
                [%c(SWAppLauncher) launchAppWithBundleIDLockscreenFriendly:y];
                
            }
            
        } else if (press.state == UIGestureRecognizerStateEnded){
            
            [self transportControlsView:self.mediaControlsView.transportControlsView longPressEndOnControlType:1];
            [self transportControlsView:self.mediaControlsView.transportControlsView longPressEndOnControlType:4];
            
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




