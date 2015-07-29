
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"

#import "substrate.h"





@interface MusicNowPlayingViewController : UIViewController <UIGestureRecognizerDelegate>
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;

- (UIView *)playbackProgressSliderView;
- (UIView *)titlesView;
- (UIView *)transportControls;
- (UIView *)volumeSlider;

- (UIView *)ratingControl;
- (void)_setRatingsVisible:(BOOL)arg1;

- (void)transportControlsView:(id)arg1 tapOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressBeginOnControlType:(NSInteger)arg2;
- (void)transportControlsView:(id)arg1 longPressEndOnControlType:(NSInteger)arg2;

@end





%hook MusicNowPlayingViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForObject:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    %orig(animated);
    
    if (!self.acapella){
        
        if ([[SWAcapellaPrefsBridge valueForKey:@"ma_nowplaying_enabled" defaultValue:@YES] boolValue]){
            
            [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.titlesView.superview
                                                          preInitializeAction:^(SWAcapella *a){
                                                              a.owner = self;
                                                              a.titles = self.titlesView;
                                                          }]
                          ForObject:self withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
            
        }
        
    }
    
    if (self.acapella){
        
        [self.acapella.tap addTarget:self action:@selector(onTap:)];
        [self.acapella.press addTarget:self action:@selector(onPress:)];
        
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [SWAcapella removeAcapella:[SWAcapella acapellaForObject:self]];
    %orig(animated);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.acapella){
        
        if (self.acapella.pan == gestureRecognizer || self.acapella.tap == gestureRecognizer){
            return ![touch.view isKindOfClass:[UISlider class]];
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
    //THESE CODES ARE DIFFERENT FROM THE MEDIA COMMANDS
    
    //Top Row
    //6 like/ban
    //1 rewind
    //3 play/pause
    //4 forward
    //7 present up next
    
    //Bottom Row
    //8 share
    //10 shuffle
    //9 repeat
    //11 contextual
    
    //Top Row
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
    
    if (arg2 == 7 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_presentupnext_enabled" defaultValue:@NO] boolValue]){
        return nil;
    }
    
    //Bottom Row
    if (arg2 == 8 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_share_enabled" defaultValue:@YES] boolValue]){
        return nil;
    }
    
    if (arg2 == 10 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_shuffle_enabled" defaultValue:@YES] boolValue]){
        return nil;
    }
    
    if (arg2 == 9 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_repeat_enabled" defaultValue:@YES] boolValue]){
        return nil;
    }
    
    if (arg2 == 11 && ![[SWAcapellaPrefsBridge valueForKey:@"transport_contextual_enabled" defaultValue:@YES] boolValue]){
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
            
            id vc = [self.volumeSlider valueForKey:@"volumeController"];
            [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(-1) afterDelay:0.0];
            
        } else if (xPercentage > 0.75){
            
            id vc = [self.volumeSlider valueForKey:@"volumeController"];
            [vc performSelector:@selector(incrementVolumeInDirection:) withObject:@(1) afterDelay:0.0];
            
        } else {
            
            if (!self.ratingControl.hidden){
                [self _setRatingsVisible:NO];
            } else {
                
                MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
                [t handlePushingMediaRemoteCommand:(t.playing) ? 1 : 0];
                
                [self.acapella pulseAnimateView:self.view];
                
            }
            
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
                
                [self transportControlsView:self.transportControls longPressBeginOnControlType:1];
                
                
            } else if (xPercentage > 0.75){
                
                [self transportControlsView:self.transportControls longPressBeginOnControlType:4];
                
            } else {
                
                self.acapella.titlesCloneContainer = nil;
                [self _setRatingsVisible:self.ratingControl.hidden];
                
            }
            
        } else if (press.state == UIGestureRecognizerStateEnded){
            
            [self transportControlsView:self.transportControls longPressEndOnControlType:1];
            [self transportControlsView:self.transportControls longPressEndOnControlType:4];
            
        }
        
    }
}

- (void)_handleTapGestureRecognizerAction:(id)arg1 //tap on artwork
{
    //if (!self.acapella){
        %orig(arg1);
    //}
}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    if ([direction integerValue] < 0){
        [self transportControlsView:self.transportControls tapOnControlType:4];
    } else if ([direction integerValue] > 0){
        [self transportControlsView:self.transportControls tapOnControlType:1];
    }
}

%end





#pragma mark - logos

%ctor
{
}




