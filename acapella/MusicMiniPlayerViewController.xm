
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"
#import "MPUTransportControlsView.h"

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
    
    if (!self.acapella){
        
        NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
        
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
    
    if (self.acapella){ //stretch title frame across the entire view
        
        CGRect targetFrame = CGRectMake(0,
                                        self.titlesView.frame.origin.y,
                                        CGRectGetMaxX(self.view.bounds),
                                        self.titlesView.frame.size.width);
        
        if (!CGRectEqualToRect(targetFrame, self.titlesView.frame)){
            self.titlesView.frame = targetFrame;
        }
        
    }
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
        
        [self transportControlsView:self.transportControlsView tapOnControlType:3];
        [self.acapella pulseAnimateView:nil];
        
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
                //[self transportControlsView:self.transportControls longPressBeginOnControlType:1];
                //INTERVAL
                [self transportControlsView:self.transportControlsView tapOnControlType:2];
                
            } else if (xPercentage > 0.75){
                
                //SEEK
                //[self transportControlsView:self.transportControls longPressBeginOnControlType:4];
                //INTERVAL
                [self transportControlsView:self.transportControlsView tapOnControlType:5];
                
            } else {
                
                [self transportControlsView:self.transportControlsView tapOnControlType:11];
                
            }
            
        } else if (press.state == UIGestureRecognizerStateEnded){
            
            //SEEK
            //[self transportControlsView:self.transportControls longPressEndOnControlType:1];
            //[self transportControlsView:self.transportControls longPressEndOnControlType:4];
            
        }
        
    }
}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    if ([direction integerValue] < 0){
        [self transportControlsView:self.transportControlsView tapOnControlType:4];
    } else if ([direction integerValue] > 0){
        [self transportControlsView:self.transportControlsView tapOnControlType:1];
    }
}

%end





#pragma mark - logos

%ctor
{
}




