
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"
#import "MusicTabBarController.h"

#import "substrate.h"





@interface MusicMiniPlayerViewController : UIViewController <UIGestureRecognizerDelegate>
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;
- (NSString *)acapellaPrefKeyPrefix;

- (UIView *)titlesView;
- (MPUTransportControlsView *)transportControlsView;
- (MPUTransportControlsView *)secondaryTransportControlsView;

- (UIPanGestureRecognizer *)nowPlayingPresentationPanRecognizer;

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2;

@end





%hook MusicMiniPlayerViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

%new
- (NSString *)acapellaPrefKeyPrefix
{
    return @"ma_mini_";
}

- (void)viewWillAppear:(BOOL)animated
{
    %orig(animated);
    
    //Reload our transport buttons
    //See [self transportControlsView:arg1 buttonForControlType:arg2];
    
    //LEFT SECTION
    [self.transportControlsView reloadTransportButtonWithControlType:1];
    [self.transportControlsView reloadTransportButtonWithControlType:3];
    [self.transportControlsView reloadTransportButtonWithControlType:4];
    
    //RIGHT SECTION
    [self.secondaryTransportControlsView reloadTransportButtonWithControlType:7];
    [self.secondaryTransportControlsView reloadTransportButtonWithControlType:11];
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
        
        [self.nowPlayingPresentationPanRecognizer requireGestureRecognizerToFail:self.acapella.pan];
        
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
    
    if (self.acapella){
        
        self.titlesView.frame = CGRectMake(0, //stretch title frame across the entire view
                                           self.titlesView.frame.origin.y,
                                           CGRectGetMaxX(self.view.bounds),
                                           CGRectGetHeight(self.titlesView.bounds));
        
    }
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
    
    //LEFT SECTION
    //1 rewind (IPAD)
    //3 play/pause
    //4 forward (IPAD)
    
    //RIGHT SECTION
    //7 present up next (IPAD)
    //11 contextual
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
    
    
    if (prefKeyPrefix != nil){
        
        //LEFT SECTION
        NSString *key_PrevTrack = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_previoustrack_enabled"];
        if (arg2 == 1 && ![[SWAcapellaPrefsBridge valueForKey:key_PrevTrack defaultValue:@NO] boolValue]){
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
        
        //RIGHT SECTION
        NSString *key_UpNext = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_presentupnext_enabled"];
        if (arg2 == 7 && ![[SWAcapellaPrefsBridge valueForKey:key_UpNext defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_Contextual = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_contextual_enabled"];
        if (arg2 == 11 && ![[SWAcapellaPrefsBridge valueForKey:key_Contextual defaultValue:@NO] boolValue]){
            return nil;
        }
        
    }
    
    
    return %orig(arg1, arg2);
}

- (void)_tapRecognized:(id)arg1
{
    if (!self.acapella){
        %orig(arg1);
    }
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
            NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_playpause"];
            sel = NSSelectorFromString(selString);
            
        } else if (xPercentage > 0.75){
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapright"];
            NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_playpause"];
            sel = NSSelectorFromString(selString);
            
        } else {
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapcentre"];
            NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_playpause"];
            sel = NSSelectorFromString(selString);
            
        }
        
        
        //perform the original tap action if our action is nil
        if (!sel || (sel && [NSStringFromSelector(sel) isEqualToString:@"action_nil"])){
            [(MusicTabBarController *)self.parentViewController presentNowPlayingViewController];
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
                NSString *selString = [SWAcapellaPrefsBridge valueForKey:key defaultValue:@"action_contextual"];
                sel = NSSelectorFromString(selString);
                
            }
            
        }
        
        
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



#pragma mark - Actions

%new
- (void)action_none
{
}

%new
- (void)action_heart
{
}

%new
- (void)action_previoustrack
{
    [self transportControlsView:self.transportControlsView tapOnControlType:1];
}

%new
- (void)action_intervalrewind
{
     [self transportControlsView:self.transportControlsView tapOnControlType:2];
}

%new
- (void)action_playpause
{
    [self transportControlsView:self.transportControlsView tapOnControlType:3];
    [self.acapella pulseAnimateView:nil];
}

%new
- (void)action_nexttrack
{
    [self transportControlsView:self.transportControlsView tapOnControlType:4];
}

%new
- (void)action_intervalforward
{
     [self transportControlsView:self.transportControlsView tapOnControlType:5];
}

%new
- (void)action_upnext
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        
        [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:7];
        
    } else {
        
        id nowPlaying = [(MusicTabBarController *)self.parentViewController nowPlayingViewController];
        
        [(MusicTabBarController *)self.parentViewController presentViewController:nowPlaying
                                                                         animated:YES
                                                                       completion:^(BOOL finished){
                                                                           
                                                                           SEL upNext = NSSelectorFromString(@"action_upnext");
                                                                           if ([nowPlaying respondsToSelector:upNext]){
                                                                               [nowPlaying performSelector:upNext];
                                                                           }
                                                                           
                                                                       }];
        
    }
}

%new
- (void)action_share
{
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
    [self transportControlsView:self.secondaryTransportControlsView tapOnControlType:11];
}

%new
- (void)action_openapp
{
}

%new
- (void)action_showratings
{
}

%new
- (void)action_increasevolume
{
}

%new
- (void)action_decreasevolume
{
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




