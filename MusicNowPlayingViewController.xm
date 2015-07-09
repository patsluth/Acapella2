
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
    
    [SWAcapella setAcapella:[[SWAcapella alloc] initWithReferenceView:self.view preInitializeAction:^(SWAcapella *a){
        a.owner = self;
        a.titles = self.titlesView;
    }] ForOwner:self];
}

%new
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        if (pan == self.acapella.pan){ //make sure the default music app GR can still pull down vertically
            CGPoint panVelocity = [pan velocityInView:pan.view];
            return (fabs(panVelocity.x) > fabs(panVelocity.y));
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
    if ([self acapella]){
        if (arg2 >= 0 && arg2 <= 5){
            return nil;
        }
    }
    
    return %orig(arg1, arg2);
}

- (void)_handleTapGestureRecognizerAction:(id)arg1
{
    if ([self acapella]){
        
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
        
    } else {
        %orig(arg1);
    }
}

%end





#pragma mark - logos

%ctor
{
}




