
#import "SWAcapella.h"
#import "SWAcapellaPrefsBridge.h"

#import "libSluthware.h"

#import "MPUTransportControlMediaRemoteController.h"

#import "substrate.h"





@interface MusicNowPlayingViewController : UIViewController
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

@end





%hook MusicNowPlayingViewController

%new
- (SWAcapella *)acapella
{
    return [SWAcapella acapellaForOwner:self];
}

- (void)viewDidLoad
{
    %orig();
    
    //if ([[SWAcapellaPrefsBridge valueForKey:@"ma_enabled" defaultValue:@YES] boolValue]){
        
        [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view preInitializeAction:^(SWAcapella *a){
            a.owner = self;
            a.titles = self.titlesView;
        }] ForOwner:self];
        
    //}
    
    if (self.acapella){
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onTap:)];
        //tap.delegate = self;
        tap.cancelsTouchesInView = YES;
        [self.acapella.titles.superview addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(onPress:)];
        //press.delegate = self;
        press.minimumPressDuration = 0.7;
        [self.acapella.titles.superview addGestureRecognizer:press];
        
    }
}

%new
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.acapella){
        
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
            
            UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
            
            if (pan == self.acapella.pan){ //make sure the default music app GR can still pull down vertically
                CGPoint panVelocity = [pan velocityInView:pan.view];
                return (fabs(panVelocity.x) > fabs(panVelocity.y));
            }
            
        }
        
    }
    
    return YES;
}

- (id)transportControlsView:(id)arg1 buttonForControlType:(NSInteger)arg2
{
    //0 Play
    //1 Pause
    //2 Stop
    //3 TogglePlayPause
    //4 Skip Forward
    //5 Skip Backwards
    if (self.acapella){
        if (arg2 >= 0 && arg2 <= 5){
            return nil;
        }
    }
    
    return %orig(arg1, arg2);
}

%new
- (void)onTap:(UITapGestureRecognizer *)tap
{
    if (self.acapella){
        
        if (!self.ratingControl.hidden){
            [self _setRatingsVisible:NO];
        } else {
            
            MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
            
            [t handlePushingMediaRemoteCommand:(t.playing) ? 1 : 0];
            
            [UIView animateWithDuration:0.1
                             animations:^{
                                 self.view.transform = CGAffineTransformMakeScale(1.05, 1.05);
                             } completion:^(BOOL finished){
                                 [UIView animateWithDuration:0.1
                                                  animations:^{
                                                      self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  } completion:^(BOOL finished){
                                                      self.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                                  }];
                             }];
            
        }
    }
}

%new
- (void)onPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan){
        [self _setRatingsVisible:self.ratingControl.hidden];
    }
}

- (void)_handleTapGestureRecognizerAction:(id)arg1
{
    //if (!self.acapella){
        %orig(arg1);
    //}
}

%new
- (void)onAcapellaWrapAround:(NSNumber *)direction
{
    MPUTransportControlMediaRemoteController *t = MSHookIvar<MPUTransportControlMediaRemoteController *>(self, "_transportControlMediaRemoteController");
    
    //Disable frame changes. See MusicNowPlayingTitlesView.xm
    self.acapella.titles.tag = 696969;
    
    if ([direction integerValue] == 0){
        [t handlePushingMediaRemoteCommand:4];
    } else if ([direction integerValue] == 1){
        [t handlePushingMediaRemoteCommand:5];
    }
}

%end





#pragma mark - logos

%ctor
{
}




