
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"

#import "substrate.h"





@interface MusicMiniPlayerViewController : UIViewController <UIGestureRecognizerDelegate>
{
    //MPUTransportControlMediaRemoteController *_transportControlMediaRemoteController;
}

- (SWAcapella *)acapella;
- (NSString *)acapellaPrefKeyPrefix;

- (UIView *)titlesView;
- (UIView *)transportControlsView;

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
    //1 rewind
    //3 play/pause
    //4 forward
    //7 present up next
    //11 contextual
    
    NSString *prefKeyPrefix = [self acapellaPrefKeyPrefix];
    
    
    if (prefKeyPrefix != nil){
        
        NSString *key_SkipPrev = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_skipprevious_enabled"];
        if (arg2 == 1 && ![[SWAcapellaPrefsBridge valueForKey:key_SkipPrev defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_PlayPause = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_play/pause_enabled"];
        if (arg2 == 3 && ![[SWAcapellaPrefsBridge valueForKey:key_PlayPause defaultValue:@NO] boolValue]){
            return nil;
        }
        
        NSString *key_SkipNext = [NSString stringWithFormat:@"%@%@", prefKeyPrefix, @"transport_skipnext_enabled"];
        if (arg2 == 4 && ![[SWAcapellaPrefsBridge valueForKey:key_SkipNext defaultValue:@NO] boolValue]){
            return nil;
        }
        
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
        
        //CGFloat xPercentage = [press locationInView:press.view].x / CGRectGetWidth(press.view.bounds);
        //CGFloat yPercentage = [press locationInView:press.view].y / CGRectGetHeight(press.view.bounds);
        
        if (press.state == UIGestureRecognizerStateBegan){
            
             [self transportControlsView:self.transportControlsView tapOnControlType:11];
            
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




