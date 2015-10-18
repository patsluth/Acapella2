
#import "SWAcapella.h"

#import "libsw/libSluthware/libSluthware.h"
#import "libsw/SWPrefs.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"
#import "MusicTabBarController.h"

#import "substrate.h"





@interface MusicMiniPlayerViewController : UIViewController
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;
- (NSString *)acapellaPrefKeyPrefix;

- (UIView *)titlesView;
- (UIView *)playbackProgressView;
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
    
    [self viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
    
    if (!self.acapella){
        
        if (prefKeyPrefix != nil){
            
            NSString *enabledKey = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"enabled"];
            
            if ([[SWPrefs valueForKey:enabledKey fallbackValue:@YES application:@"com.apple.Music"] boolValue]){
                
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
        [self.acapella.press2 addTarget:self action:@selector(onPress:)];
        
        [self.nowPlayingPresentationPanRecognizer requireGestureRecognizerToFail:self.acapella.pan];
        
    }
    
    [self viewDidLayoutSubviews];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    %orig(animated);
}

- (void)viewDidLayoutSubviews
{
    %orig();
    
    CGRect titlesFrame = self.titlesView.frame;
    
    //intelligently calcualate titles frame based on visible transport controls
    if ([self.transportControlsView hidden_acapella]){
        titlesFrame.origin.x = 0.0;
        titlesFrame.size.width = self.secondaryTransportControlsView.frame.origin.x;
    }
    
    if ([self.secondaryTransportControlsView hidden_acapella]){
        titlesFrame.size.width = CGRectGetWidth(self.titlesView.superview.bounds) - titlesFrame.origin.x;
    }
    
    
    self.titlesView.frame = titlesFrame;
    
    
    //show/hide progress slider
    NSString *progressKey = [NSString stringWithFormat:@"%@%@", [self acapellaPrefKeyPrefix], @"progressSlider_enabled"];
    BOOL progressVisible = [[SWPrefs valueForKey:progressKey fallbackValue:@YES application:@"com.apple.Music"] boolValue];
    self.playbackProgressView.layer.opacity = progressVisible ? 1.0 : 0.0;
    
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
        if (arg2 == 1 && ![[SWPrefs valueForKey:key_PrevTrack fallbackValue:@NO application:@"com.apple.Music"] boolValue]){
            return nil;
        }
        
        NSString *key_PlayPause = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_play/pause_enabled"];
        if (arg2 == 3 && ![[SWPrefs valueForKey:key_PlayPause fallbackValue:@NO application:@"com.apple.Music"] boolValue]){
            return nil;
        }
        
        NSString *key_NextTrack = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_nextTrack_enabled"];
        if (arg2 == 4 && ![[SWPrefs valueForKey:key_NextTrack fallbackValue:@NO application:@"com.apple.Music"] boolValue]){
            return nil;
        }
        
        //RIGHT SECTION
        NSString *key_UpNext = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_presentupnext_enabled"];
        if (arg2 == 7 && ![[SWPrefs valueForKey:key_UpNext fallbackValue:@NO application:@"com.apple.Music"] boolValue]){
            return nil;
        }
        
        NSString *key_Contextual = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_contextual_enabled"];
        if (arg2 == 11 && ![[SWPrefs valueForKey:key_Contextual fallbackValue:@NO application:@"com.apple.Music"] boolValue]){
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
            NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_playpause" application:@"com.apple.Music"];
            sel = NSSelectorFromString(selString);
            
        } else if (xPercentage > 0.75){
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapright"];
            NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_playpause" application:@"com.apple.Music"];
            sel = NSSelectorFromString(selString);
            
        } else {
            
            NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_tapcentre"];
            NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_playpause" application:@"com.apple.Music"];
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
                NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_intervalrewind" application:@"com.apple.Music"];
                sel = NSSelectorFromString(selString);
                
            } else if (xPercentage > 0.75){
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_pressright"];
                NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_intervalforward" application:@"com.apple.Music"];
                sel = NSSelectorFromString(selString);
                
            } else {
                
                NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_presscentre"];
                NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_contextual" application:@"com.apple.Music"];
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
        NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_nexttrack" application:@"com.apple.Music"];
        sel = NSSelectorFromString(selString);
        
    } else if ([direction integerValue] > 0){
        
        NSString *key = [NSString stringWithFormat:@"%@%@", self.acapella.prefKeyPrefix, @"gestures_swiperight"];
        NSString *selString = [SWPrefs valueForKey:key fallbackValue:@"action_previoustrack" application:@"com.apple.Music"];
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




