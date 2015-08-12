
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"

#import "substrate.h"





@interface MusicNowPlayingViewController : UIViewController <UIGestureRecognizerDelegate>
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;
- (NSString *)acapellaPrefKeyPrefix;

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

@end





%hook MusicNowPlayingViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

%new
- (NSString *)acapellaPrefKeyPrefix
{
    return @"ma_nowplaying_";
}

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
    //these will cache sometimes, so make sure we clear them out before we reload them
    //so we can correctly see if there are any visible controls in viewDidLayoutSubviews
    //where we modify the titles centre
    for (UIView *subview in self.transportControls.subviews){
        [subview removeFromSuperview];
    }
    for (UIView *subview in self.secondaryTransportControls.subviews){
        [subview removeFromSuperview];
    }
    
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

//- (void)setVolumeSlider:(UIView *)arg1
//{
//    %orig(arg1);
//    arg1.layer.opacity = 0.0;
//    arg1.hidden = YES;
//}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
    
    if (!self.acapella){
        
        if (prefKeyPrefix != nil){
            
            NSString *enabledKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"enabled"];
            
            if ([[SWAcapellaPrefsBridge valueForKey:enabledKey defaultValue:@YES] boolValue]){
                
                [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.titlesView.superview
                                                              preInitializeAction:^(SWAcapella *a){
                                                                  a.owner = self;
                                                                  a.titles = self.titlesView;
                                                              }]
                              ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
                
            }
            
        }
        
    }
    
    if (self.acapella){
        
        self.acapella.prefKeyPrefix = prefKeyPrefix;
        
        [self.acapella.tap addTarget:self action:@selector(onTap:)];
        [self.acapella.press addTarget:self action:@selector(onPress:)];
        
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
    
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];;
    
    
    NSString *progressKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"progressSlider_enabled"];
    NSString *volumeKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"volumeSlider_enabled"];
    
    BOOL progressVisible = [[SWAcapellaPrefsBridge valueForKey:progressKey defaultValue:@YES] boolValue];
    BOOL volumeVisible = [[SWAcapellaPrefsBridge valueForKey:volumeKey defaultValue:@YES] boolValue];
    
    //show/hide sliders
    self.playbackProgressSliderView.layer.opacity = progressVisible ? 1.0 : 0.0;
    self.volumeSlider.layer.opacity = volumeVisible ? 1.0 : 0.0;
    
    //Pinnning views responsible for drawing knobs
    for (UIView *subview in self.vibrantEffectView.subviews){
        if (%c(MPUPinningView) && [subview isKindOfClass:%c(MPUPinningView)]){
            
            id pinningSourceLayer = [subview valueForKey:@"pinningSourceLayer"];
            id progressLayer = [[self.playbackProgressSliderView valueForKey:@"_playbackProgressSlider"] valueForKey:@"layer"];
            
            if (pinningSourceLayer == progressLayer){
                subview.hidden = !progressVisible;
            } else if (pinningSourceLayer == self.volumeSlider.layer){
                subview.hidden = !volumeVisible;
            }
            
        }
    }
    
    
    
    //intelligently calcualate centre based on visible controls, which we dont want to do on iPAD
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)){ return; }
    
    
    CGFloat topGuideline = CGRectGetMinY(self.playbackProgressSliderView.frame);
    
    if (self.playbackProgressSliderView.layer.opacity > 0.0){ //visible
        topGuideline += CGRectGetHeight(self.playbackProgressSliderView.bounds);
    }
    
    
    CGFloat bottomGuideline = CGRectGetMinY(self.transportControls.frame); //top of primary transport controls
    
    if (self.transportControls.subviews.count <= 0){ //hidden
        
        bottomGuideline = CGRectGetMinY(self.volumeSlider.frame); //top of volume slider
        
        if (self.volumeSlider.layer.opacity <= 0.0){ //hidden
            
            bottomGuideline = CGRectGetMinY(self.secondaryTransportControls.frame); //top of transport secondary controls
            
            if (self.secondaryTransportControls.subviews.count <= 0){ //hidden
                bottomGuideline = CGRectGetMaxY(self.titlesView.superview.bounds); //bottom of screen
            }
            
        }
        
    }
    
    //the midpoint between the currently visible views. This is where we will place our titles
    NSInteger midPoint = (topGuideline + (fabs(topGuideline - bottomGuideline) / 2.0));
    self.titlesView.center = CGPointMake(self.titlesView.center.x, midPoint);
    
}

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
    
    return %orig(gestureRecognizer, touch);
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
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
    
    if (prefKeyPrefix != nil){
     
        //TOP ROW
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
        
        NSString *key_UpNext = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_presentupnext_enabled"];
        if (arg2 == 7 && ![[SWAcapellaPrefsBridge valueForKey:key_UpNext defaultValue:@YES] boolValue]){
            return nil;
        }
        
        //BOTTOM ROW
        NSString *key_Share = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_share_enabled"];
        if (arg2 == 8 && ![[SWAcapellaPrefsBridge valueForKey:key_Share defaultValue:@YES] boolValue]){
            return nil;
        }
        
        NSString *key_Shuffle = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_shuffle_enabled"];
        if (arg2 == 10 && ![[SWAcapellaPrefsBridge valueForKey:key_Shuffle defaultValue:@YES] boolValue]){
            return nil;
        }
        
        NSString *key_Repeat = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_repeat_enabled"];
        if (arg2 == 9 && ![[SWAcapellaPrefsBridge valueForKey:key_Repeat defaultValue:@YES] boolValue]){
            return nil;
        }
        
        NSString *key_Contextual = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_contextual_enabled"];
        if (arg2 == 11 && ![[SWAcapellaPrefsBridge valueForKey:key_Contextual defaultValue:@YES] boolValue]){
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
            NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_decreasevolume"];
            sel = NSSelectorFromString(selString);
            
        } else if (xPercentage > 0.75){
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapright"];
            NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_increasevolume"];
            sel = NSSelectorFromString(selString);
            
        } else {
            
            if (!self.ratingControl.hidden){
                [self _setRatingsVisible:NO];
            } else {
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapcentre"];
                NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_playpause"];
                sel = NSSelectorFromString(selString);
                
            }
            
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
                NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_intervalrewind"];
                sel = NSSelectorFromString(selString);
                
            } else if (xPercentage > 0.75){
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_pressright"];
                NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_intervalforward"];
                sel = NSSelectorFromString(selString);
                
            } else {
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_presscentre"];
                NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_showratings"];
                sel = NSSelectorFromString(selString);
                
            }
            
        }
        
        
        if (sel && [self respondsToSelector:sel]){
            [self performSelectorOnMainThread:sel withObject:nil waitUntilDone:NO];
        }
        
    }
}

//- (void)_handleTapGestureRecognizerAction:(id)arg1 //tap on artwork
//{
//    //if (!self.acapella){
//        %orig(arg1);
//    //}
//}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    SEL sel = nil;
    
    if ([direction integerValue] < 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_swipeleft"];
        NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_nexttrack"];
        sel = NSSelectorFromString(selString);
        
    } else if ([direction integerValue] > 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_swiperight"];
        NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_previoustrack"];
        sel = NSSelectorFromString(selString);
        
    }
    
    
    if (sel && [self respondsToSelector:sel]){
        [self performSelectorOnMainThread:sel withObject:nil waitUntilDone:NO];
    }
}

- (void)_showUpNext
{
    if (self.acapella){
        self.acapella.titlesCloneContainer = nil;
    }
    
    %orig();
}

- (void)_showUpNext:(id)arg1
{
    if (self.acapella){
        self.acapella.titlesCloneContainer = nil;
    }
    
    %orig(arg1);
}



#pragma mark - Actions

%new
- (void)action_none
{
}

%new
- (void)action_heart
{
    [self transportControlsView:self.transportControls tapOnControlType:6];
}

%new
- (void)action_previoustrack
{
    [self transportControlsView:self.transportControls tapOnControlType:1];
}

%new
- (void)action_intervalrewind
{
    [self transportControlsView:self.transportControls tapOnControlType:2];
}

%new
- (void)action_playpause
{
    [self transportControlsView:self.transportControls tapOnControlType:3];
    [self.acapella pulseAnimateView:self.view];
}

%new
- (void)action_nexttrack
{
    [self transportControlsView:self.transportControls tapOnControlType:4];
}

%new
- (void)action_intervalforward
{
    [self transportControlsView:self.transportControls tapOnControlType:5];
}

%new
- (void)action_upnext
{
    [self transportControlsView:self.transportControls tapOnControlType:7];
}

%new
- (void)action_share
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:8];
}

%new
- (void)action_toggleshuffle
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:10];
}

%new
- (void)action_togglerepeat
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:9];
}

%new
- (void)action_contextual
{
    [self transportControlsView:self.secondaryTransportControls tapOnControlType:11];
}

%new
- (void)action_openapp
{
}

%new
- (void)action_showratings
{
    self.acapella.titlesCloneContainer = nil;
    [self _setRatingsVisible:self.ratingControl.hidden];
}

%new
- (void)action_increasevolume
{
    id vc = [self.volumeSlider valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(1) afterDelay:0.0];
}

%new
- (void)action_decreasevolume
{
    id vc = [self.volumeSlider valueForKey:@"volumeController"];
    [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(-1) afterDelay:0.0];
}

%new
- (void)action_equalizereverywhere
{
}

%end





#pragma mark - logos

%ctor
{
}




